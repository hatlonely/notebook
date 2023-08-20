# terraform alicloud slb

## 配置依赖

```terraform
terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.209.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}
```

## 创建 vpc

```terraform
data "alicloud_zones" "zones" {
  available_resource_creation = "VSwitch"
}

resource "alicloud_vpc" "tf-test-vpc" {
  vpc_name   = "tf-test-vpc"
  cidr_block = "172.16.0.0/16"
}

resource "alicloud_vswitch" "tf-test-vswitch" {
  for_each = {
    for idx, zone in data.alicloud_zones.zones.zones : idx => zone
  }

  zone_id    = each.value.id
  vpc_id     = alicloud_vpc.tf-test-vpc.id
  cidr_block = cidrsubnet(alicloud_vpc.tf-test-vpc.cidr_block, 8, each.key)
}
```

## 创建 ecs 部署服务

```terraform
data "alicloud_instance_types" "type-1c1g" {
  cpu_core_count = 1
  memory_size    = 1
}

data "alicloud_images" "ubuntu_22" {
  name_regex = "^ubuntu_22"
  owners     = "system"
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()[]{}_-=+/?<>"
}

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

resource "alicloud_instance" "tf-test-ecs" {
  count           = var.instance_number
  image_id        = data.alicloud_images.ubuntu_22.images[0].id
  instance_type   = data.alicloud_instance_types.type-1c1g.instance_types[0].id
  security_groups = [
    alicloud_security_group.tf-test-security-group.id,
  ]
  vswitch_id                 = alicloud_vswitch.tf-test-vswitch[count.index % length(alicloud_vswitch.tf-test-vswitch)].id
  internet_max_bandwidth_out = 5
  internet_charge_type       = "PayByTraffic"
  host_name                  = "tf-test-ecs"
  password                   = random_password.password.result
  user_data                  = base64encode(file("${path.module}/init.sh"))

  connection {
    type     = "ssh"
    user     = "root"
    password = random_password.password.result
    host     = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "bash -c \"$(curl -fsSL http://100.100.100.200/latest/user-data)\""
    ]
  }
}

output "ecs_connection" {
  value = alicloud_instance.tf-test-ecs.*.public_ip
}
```

创建 `init.sh` 文件，用于初始化 ecs，通过 `user_data` 传给 ecs

```shell
#!/usr/bin/env bash

function install_docker() {
  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
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
    nginx &
}

function main() {
  install_docker
  prepare_config
  start_service
}

main
```

## 创建 SLB

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
  server_id       = alicloud_instance.tf-test-ecs[count.index].id
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
curl http://${alicloud_slb_load_balancer.tf-test-load-balancer.address}:8000
EOF
}
```

## 参考链接

- [terraform-alicloud-slb](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/slb_load_balancer)
- [源码地址](../code/alicloud/slb/slb.tf)
- [ecs 使用自定义数据 user_data](https://help.aliyun.com/zh/ecs/user-guide/manage-the-user-data-of-linux-instances)
