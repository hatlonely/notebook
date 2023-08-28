# 服务实例类型
data "alicloud_instance_types" "instance_types" {
  cpu_core_count = 1
  memory_size    = 1
}

# 跳板机实例类型
data "alicloud_instance_types" "instance_types_jump_server" {
  cpu_core_count = 1
  memory_size    = 1
}

# 服务基础镜像
data "alicloud_images" "images_ubuntu_22" {
  name_regex = "^ubuntu_22"
  owners     = "system"
}

# 生成登录秘钥对
resource "tls_private_key" "tls_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 保存秘钥
resource "local_file" "file_id_rsa" {
  filename        = "id_rsa"
  content         = tls_private_key.tls_private_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "file_id_rsa_pub" {
  filename = "id_rsa.pub"
  content  = tls_private_key.tls_private_key.public_key_openssh
}

# 创建秘钥对
resource "alicloud_ecs_key_pair" "ecs_key_pair" {
  key_pair_name = "${var.name}-key-pair"
  public_key    = tls_private_key.tls_private_key.public_key_openssh
}

# 创建安全组
resource "alicloud_security_group" "security_group" {
  name   = "${var.name}-security-group"
  vpc_id = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "security-group-rule-allow-ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.security_group.id
  cidr_ip           = "123.113.97.7/32"
}

# 创建服务实例（无公网地址）
resource "alicloud_instance" "instances" {
  count           = var.instance_number
  image_id        = data.alicloud_images.images_ubuntu_22.images[0].id
  instance_type   = data.alicloud_instance_types.instance_types.instance_types[0].id
  security_groups = [
    alicloud_security_group.security_group.id,
  ]
  vswitch_id           = alicloud_vswitch.vswitchs[count.index % length(alicloud_vswitch.vswitchs)].id
  internet_charge_type = "PayByTraffic"
  instance_name        = "${var.name}-${count.index + 1}"
  host_name            = "${var.name}-${count.index + 1}"
  key_name             = alicloud_ecs_key_pair.ecs_key_pair.key_pair_name
}

# 等待实例创建完成
resource "null_resource" "after_30_seconds_instance" {
  depends_on = [
    alicloud_instance.instances
  ]

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

# 创建跳板机
resource "alicloud_instance" "instance_jump_server" {
  image_id        = data.alicloud_images.images_ubuntu_22.images[0].id
  instance_type   = data.alicloud_instance_types.instance_types_jump_server.instance_types[0].id
  security_groups = [
    alicloud_security_group.security_group.id,
  ]
  vswitch_id                 = alicloud_vswitch.vswitchs[0].id
  internet_max_bandwidth_out = 5
  internet_charge_type       = "PayByTraffic"
  instance_name              = "${var.name}-jump-server"
  host_name                  = "${var.name}-jump-server"
  key_name                   = alicloud_ecs_key_pair.ecs_key_pair.key_pair_name

  connection {
    type        = "ssh"
    user        = "root"
    host        = self.public_ip
    private_key = tls_private_key.tls_private_key.private_key_pem
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
output "connection_jump_server" {
  value = "ssh -i id_rsa root@${alicloud_instance.instance_jump_server.public_ip}"
}

# 创建 OOS 执行所需的 RAM 角色
resource "alicloud_ram_role" "ram-role-oos-service" {
  name     = "${var.name}-oos-service-role"
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

resource "alicloud_ram_role_policy_attachment" "ram_role_policy_attachment_aliyun_ecs_full_access" {
  policy_name = "AliyunECSFullAccess"
  policy_type = "System"
  role_name   = alicloud_ram_role.ram-role-oos-service.name
}

# 安装日志服务 agent
resource "alicloud_oos_execution" "oos_execution_install_log_agent" {
  depends_on = [null_resource.after_30_seconds_instance]

  for_each = {for idx, instance in alicloud_instance.instances : idx => instance}

  template_name = "ACS-ECS-BulkyInstallLogAgent"
  parameters    = jsonencode({
    regionId = "cn-beijing"
    targets  = {
      Type        = "ResourceIds"
      ResourceIds = [each.value.id]
      RegionId    = "cn-beijing"
    }
    OOSAssumeRole = alicloud_ram_role.ram-role-oos-service.name
  })
}

# 安装云监控 agent
resource "alicloud_oos_execution" "oos_execution_install_cms_agent" {
  depends_on = [null_resource.after_30_seconds_instance]

  for_each = {for idx, instance in alicloud_instance.instances : idx => instance}

  template_name = "ACS-ECS-ConfigureCloudMonitorAgent"
  parameters    = jsonencode({
    regionId = "cn-beijing"
    action   = "install"
    targets  = {
      Type        = "ResourceIds"
      ResourceIds = [each.value.id]
      RegionId    = "cn-beijing"
    }
    OOSAssumeRole = alicloud_ram_role.ram-role-oos-service.name
  })
}

# 启动服务
resource "alicloud_oos_execution" "oos_execution_start_service" {
  depends_on = [null_resource.after_30_seconds_instance]

  for_each = {for idx, instance in alicloud_instance.instances : idx => instance}

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
  echo ${var.name} >/etc/ilogtail/user_defined_id
}

function prepare_config() {
  mkdir -p /root/nginx/etc/nginx/conf.d/
  cat > /root/nginx/etc/nginx/conf.d/default.conf <<EOF
server {
    listen       80;
    listen  [::]:80;
    server_name  _;

    access_log  /var/log/nginx/access.log  main;

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
    OOSAssumeRole = alicloud_ram_role.ram-role-oos-service.name
  })
}
