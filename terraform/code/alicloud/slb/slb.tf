terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.209.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}


provider "alicloud" {
  region = "cn-beijing"
  alias  = "cn-beijing"
}

## 创建 VPC

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

## 创建 SLB

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
  server_group_id = alicloud_slb_server_group.tf-test-server-group.id
  server_id       = alicloud_instance.tf-test-ecs.id
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

## 创建一台 ecs

# 自动获取实例类型
data "alicloud_instance_types" "type-1c1g" {
  cpu_core_count = 1
  memory_size    = 1
}

# 自动获取镜像
data "alicloud_images" "ubuntu_22" {
  name_regex = "^ubuntu_22"
  owners     = "system"
}

# 生成密码
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()[]{}_-=+/?<>"
}

# 创建安全组，现在安全组只能创建在 VPC 内，但其规则可以是公网或内网
resource "alicloud_security_group" "tf-test-security-group" {
  name   = "tf-test-security-group"
  vpc_id = alicloud_vpc.tf-test-vpc.id
}

# 创建安全组规则，nic_type 必须为 intranet，但其规则对公网同样有效
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

# 创建一台带公网 ip 密码登录的 ECS
resource "alicloud_instance" "tf-test-ecs" {
  image_id        = data.alicloud_images.ubuntu_22.images[0].id
  instance_type   = data.alicloud_instance_types.type-1c1g.instance_types[0].id
  security_groups = [
    alicloud_security_group.tf-test-security-group.id,
  ]
  vswitch_id                 = alicloud_vswitch.tf-test-vswitch[0].id
  internet_max_bandwidth_out = 5
  internet_charge_type       = "PayByTraffic"
  host_name                  = "tf-test-ecs"
  password                   = random_password.password.result
  user_data                  = base64encode(file("${path.module}/init.sh"))

  provisioner "remote-exec" {
    inline = [
      "bash -c \"$$(curl -fsSL http://100.100.100.200/latest/user-data)\""
    ]
  }
}

output "ecs_connection" {
  value = <<EOF
ssh root@${alicloud_instance.tf-test-ecs.public_ip}
${nonsensitive(alicloud_instance.tf-test-ecs.password)}
EOF
}
