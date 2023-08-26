# terraform 阿里云最佳实践 ecs web 服务

使用 terraform 在阿里云上部署一个 web 服务。服务部署在封闭的 vpc 中，通过 slb 对外提供服务。日志自动收集到 sls 中。

## 创建 vpc

```terraform
data "alicloud_zones" "zones" {
  available_resource_creation = "VSwitch"
}

# 创建VPC
resource "alicloud_vpc" "tf-test-vpc" {
  vpc_name   = "tf-test-vpc"
  cidr_block = "172.16.0.0/16"
}

# 创建交换机
resource "alicloud_vswitch" "tf-test-vswitch" {
  for_each = {
    for idx, zone in data.alicloud_zones.zones.zones : idx => zone
  }

  zone_id    = each.value.id
  vpc_id     = alicloud_vpc.tf-test-vpc.id
  cidr_block = cidrsubnet(alicloud_vpc.tf-test-vpc.cidr_block, 8, each.key)
}

# 创建NAT网关
resource "alicloud_nat_gateway" "tf-test-nat-gateway" {
  vpc_id           = alicloud_vpc.tf-test-vpc.id
  nat_gateway_name = "tf-test-nat-gateway"
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.tf-test-vswitch.0.id
  nat_type         = "Enhanced"
}

# 创建公网IP
resource "alicloud_eip_address" "tf-test-eip" {
  bandwidth            = "5"
  internet_charge_type = "PayByTraffic"
  payment_type         = "PayAsYouGo"
  netmode              = "public"
  isp                  = "BGP"
  address_name         = "tf-test-eip"
}

# 绑定公网IP
resource "alicloud_eip_association" "tf-test-eip-association" {
  allocation_id = alicloud_eip_address.tf-test-eip.id
  instance_id   = alicloud_nat_gateway.tf-test-nat-gateway.id
}

# 创建SNAT条目
resource "alicloud_snat_entry" "tf-test-snat-entry" {
  for_each          = alicloud_vswitch.tf-test-vswitch
  snat_table_id     = alicloud_nat_gateway.tf-test-nat-gateway.snat_table_ids
  source_vswitch_id = each.value.id
  snat_ip           = alicloud_eip_address.tf-test-eip.ip_address
}
```

## 创建 ecs

```terraform
# 服务实例类型
data "alicloud_instance_types" "web-instance-types" {
  cpu_core_count = 1
  memory_size    = 1
}

# 跳板机实例类型
data "alicloud_instance_types" "jump-server-instance-types" {
  cpu_core_count = 1
  memory_size    = 1
}

# 服务基础镜像
data "alicloud_images" "ubuntu_22" {
  name_regex = "^ubuntu_22"
  owners     = "system"
}

# 生成登录秘钥对
resource "tls_private_key" "tf-test-key-pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 保存秘钥
resource "local_file" "tf-test-id-rsa" {
  filename = "id_rsa"
  content  = tls_private_key.tf-test-key-pair.private_key_pem
}

resource "local_file" "tf-test-id-rsa-pub" {
  filename = "id_rsa.pub"
  content  = tls_private_key.tf-test-key-pair.public_key_openssh
}

# 创建秘钥对
resource "alicloud_ecs_key_pair" "tf-test-key-pair" {
  key_pair_name = "tf-test-key-pair"
  public_key    = tls_private_key.tf-test-key-pair.public_key_openssh
}

# 创建安全组
resource "alicloud_security_group" "tf-test-security-group" {
  name   = "tf-test-security-group"
  vpc_id = alicloud_vpc.tf-test-vpc.id
}

resource "alicloud_security_group_rule" "tf-test-security-group-rule" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.tf-test-security-group.id
  cidr_ip           = "123.113.97.7/32"
}

# 创建服务实例（无公网地址）
resource "alicloud_instance" "tf-test-web-service" {
  count           = var.instance_number
  image_id        = data.alicloud_images.ubuntu_22.images[0].id
  instance_type   = data.alicloud_instance_types.web-instance-types.instance_types[0].id
  security_groups = [
    alicloud_security_group.tf-test-security-group.id,
  ]
  vswitch_id           = alicloud_vswitch.tf-test-vswitch[count.index % length(alicloud_vswitch.tf-test-vswitch)].id
  internet_charge_type = "PayByTraffic"
  instance_name        = "tf-test-web-service-${count.index + 1}"
  host_name            = "tf-test-web-service-${count.index + 1}"
  key_name             = alicloud_ecs_key_pair.tf-test-key-pair.key_pair_name
}

# 创建跳板机
resource "alicloud_instance" "tf-test-jump-server" {
  image_id        = data.alicloud_images.ubuntu_22.images[0].id
  instance_type   = data.alicloud_instance_types.jump-server-instance-types.instance_types[0].id
  security_groups = [
    alicloud_security_group.tf-test-security-group.id,
  ]
  vswitch_id                 = alicloud_vswitch.tf-test-vswitch[0].id
  internet_max_bandwidth_out = 5
  internet_charge_type       = "PayByTraffic"
  instance_name              = "tf-test-jump-server"
  host_name                  = "tf-test-jump-server"
  key_name                   = alicloud_ecs_key_pair.tf-test-key-pair.key_pair_name

  connection {
    type        = "ssh"
    user        = "root"
    host        = self.public_ip
    private_key = tls_private_key.tf-test-key-pair.private_key_pem
  }

  provisioner "file" {
    source      = "${path.module}/id_rsa"
    destination = "/root/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /root/id_rsa"
    ]
  }
}

# 输出连接跳板机的命令
output "connection-jump-server" {
  value = "ssh -i id_rsa root@${alicloud_instance.tf-test-jump-server.public_ip}"
}

# 创建 OOS 执行所需的 RAM 角色
resource "alicloud_ram_role" "tf-test-oos-service-role" {
  name     = "tf-test-oos-service-role"
  force    = true
  document = <<EOF
  {
    "Version": "1",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "oos.aliyuncs.com"
          ]
        }
      }
    ]
  }
  EOF
}

resource "alicloud_ram_role_policy_attachment" "tf-test-role-policy-aliyun-ecs-full-access" {
  policy_name = "AliyunECSFullAccess"
  policy_type = "System"
  role_name   = alicloud_ram_role.tf-test-oos-service-role.name
}

resource "alicloud_ram_role_policy_attachment" "tf-test-role-policy-aliyun-log-full-access" {
  policy_name = "AliyunLogFullAccess"
  policy_type = "System"
  role_name   = alicloud_ram_role.tf-test-oos-service-role.name
}

resource "alicloud_oos_execution" "tf-test-web-service-init-logtail" {
  for_each = {
    for idx, instance in alicloud_instance.tf-test-web-service : idx => instance
  }

  template_name = "ACS-LOG-BulkyInstallLogtail"
  parameters    = jsonencode({
    regionId = "cn-beijing"
    targets  = {
      Type        = "ResourceIds"
      ResourceIds = [each.value.id]
      RegionId    = "cn-beijing"
    }
    OOSAssumeRole = alicloud_ram_role.tf-test-oos-service-role.name
  })
}

resource "alicloud_oos_execution" "tf-test-web-service-init" {
  for_each = {
    for idx, instance in alicloud_instance.tf-test-web-service : idx => instance
  }

  template_name = "ACS-ECS-BulkyRunCommand"
  parameters    = jsonencode({
    regionId       = "cn-beijing"
    commandContent = <<EOT
#!/usr/bin/env bash

function install_docker() {
  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo rm -rf /etc/apt/keyrings/docker.gpg
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}


function install_logtail() {
  echo ${var.sls_logtail_user_define} >/etc/ilogtail/user_defined_id
}

function prepare_config() {
  mkdir -p /root/nginx/etc/nginx/conf.d/
  cat > /root/nginx/etc/nginx/conf.d/default.conf <<EOF
server {
    listen       80;
    listen  [::]:80;
    server_name  _;

    access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
}

function start_service() {
  sudo docker run \
    -p 80:80 \
    -v /root/nginx/etc/nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf \
    -v /root/nginx/var/log/nginx:/var/log/nginx \
    nginx &
}

function main() {
  install_docker
  install_logtail
  prepare_config
  start_service
}

main
EOT
    workingDir     = "/root"
    username       = "root"
    targets        = {
      Type        = "ResourceIds"
      ResourceIds = [each.value.id]
      RegionId    = "cn-beijing"
    }
    resourceType  = "ALIYUN::ECS::Instance"
    OOSAssumeRole = alicloud_ram_role.tf-test-oos-service-role.name
  })
}
```

## 创建 slb

```terraform
resource "alicloud_slb_load_balancer" "tf-test-load-balancer" {
  load_balancer_name   = "tf-test-load-balancer"
  address_type         = "internet"
  load_balancer_spec   = "slb.s1.small"
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_slb_server_group" "tf-test-server-group" {
  name             = "tf-test-server-group"
  load_balancer_id = alicloud_slb_load_balancer.tf-test-load-balancer.id
}

resource "alicloud_slb_server_group_server_attachment" "tf-test-server-group-server-attachment" {
  count           = var.instance_number
  server_group_id = alicloud_slb_server_group.tf-test-server-group.id
  server_id       = alicloud_instance.tf-test-web-service[count.index].id
  port            = 80
}

resource "alicloud_slb_listener" "tf-test-listener" {
  load_balancer_id = alicloud_slb_load_balancer.tf-test-load-balancer.id
  backend_port     = 80
  frontend_port    = 80
  protocol         = "tcp"
  bandwidth        = 1
  server_group_id  = alicloud_slb_server_group.tf-test-server-group.id
}

output "slb_connection" {
  value = <<EOF
curl http://${alicloud_slb_load_balancer.tf-test-load-balancer.address}
EOF
}
```

## 创建 sls

```terraform
# 创建日志服务项目
resource "alicloud_log_project" "tf-test-project" {
  name = "tf-test-project"
}

# 创建日志服务日志库
resource "alicloud_log_store" "tf-test-store" {
  name                  = "tf-test-store"
  project               = alicloud_log_project.tf-test-project.name
  shard_count           = 3
  auto_split            = true
  max_split_shard_count = 60
  append_meta           = true
}

# 创建日志服务索引
resource "alicloud_log_store_index" "tf-test-store-index" {
  logstore = alicloud_log_store.tf-test-store.name
  project  = alicloud_log_project.tf-test-project.name
  full_text {
    case_sensitive = true
    token          = "#$^*\r\n\t"
  }
  field_search {
    name             = "http_user_agent"
    enable_analytics = true
    type             = "text"
    token            = " #$^*\r\n\t"
  }
  field_search {
    name             = "remote_addr"
    enable_analytics = true
    type             = "text"
    token            = " #$^*\r\n\t"
  }
}

# 创建日志服务机器组
resource "alicloud_log_machine_group" "tf-test-machine-group" {
  name          = "tf-test-machine-group"
  project       = alicloud_log_project.tf-test-project.name
  identify_type = "userdefined"
  topic         = "tf-test-machine-group-topic"
  identify_list = [var.sls_logtail_user_define]
}

# 创建日志库配置
resource "alicloud_logtail_config" "tf-test-logtail-config" {
  name         = "tf-test-logtail-config"
  project      = alicloud_log_project.tf-test-project.name
  logstore     = alicloud_log_store.tf-test-store.name
  input_type   = "file"
  output_type  = "LogService"
  input_detail = <<EOF
  {
    "logPath": "/root/nginx/var/log",
    "filePattern": "access.log",
    "logType": "common_reg_log",
    "topicFormat": "default",
    "discardUnmatch": false,
    "enableRawLog": true,
    "fileEncoding": "utf8",
    "maxDepth": 10,
    "key": [
      "remote_addr", "remote_user", "time_local", "request", "version", "status", "body_bytes_sent",
      "http_referer", "http_user_agent"
    ],
    "logBeginRegex": ".*",
    "regex": "(\\S+)\\s-\\s(\\S+)\\s\\[([^]]+)]\\s\"(\\w+)([^\"]+)\"\\s(\\d+)\\s(\\d+)[^-]+([^\"]+)\"\\s\"([^\"]+).*"
 }
EOF
}

# 关联日志库配置
resource "alicloud_logtail_attachment" "tf-test-logtail-attachment" {
  logtail_config_name = alicloud_logtail_config.tf-test-logtail-config.name
  machine_group_name  = alicloud_log_machine_group.tf-test-machine-group.name
  project             = alicloud_log_project.tf-test-project.name
}
```

## 参考链接

- [源码地址](../code/alicloud/best-practise/1-ecs-web-service)
