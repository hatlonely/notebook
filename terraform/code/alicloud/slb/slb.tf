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

variable "name" {
  type    = string
  default = "tf-test-slb"
}

variable "instance_number" {
  type    = number
  default = 1
}

provider "alicloud" {
  region = "cn-beijing"
  alias  = "cn-beijing"
}

## 创建 VPC

data "alicloud_zones" "zones_vswitch" {
  available_resource_creation = "VSwitch"
}

resource "alicloud_vpc" "vpc" {
  vpc_name   = "${var.name}-vpc"
  cidr_block = "172.16.0.0/16"
}

resource "alicloud_vswitch" "vswitchs" {
  for_each = {for idx, zone in data.alicloud_zones.zones_vswitch.zones : idx => zone}

  zone_id    = each.value.id
  vpc_id     = alicloud_vpc.vpc.id
  cidr_block = cidrsubnet(alicloud_vpc.vpc.cidr_block, 8, each.key)
}

## 创建 SLB

resource "alicloud_slb_load_balancer" "slb_load_balancer" {
  load_balancer_name   = "tf-test-load-balancer"
  address_type         = "internet"
  load_balancer_spec   = "slb.s1.small"
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_slb_server_group" "slb_server_group" {
  name             = "${var.name}-server-group"
  load_balancer_id = alicloud_slb_load_balancer.slb_load_balancer.id
}

resource "alicloud_slb_server_group_server_attachment" "slb_server_group_server_attachment" {
  count           = var.instance_number
  server_group_id = alicloud_slb_server_group.slb_server_group.id
  server_id       = alicloud_instance.instance[count.index].id
  port            = 80
}

resource "alicloud_slb_listener" "slb_listener" {
  load_balancer_id = alicloud_slb_load_balancer.slb_load_balancer.id
  backend_port     = 80
  frontend_port    = 80
  protocol         = "tcp"
  bandwidth        = 1
  server_group_id  = alicloud_slb_server_group.slb_server_group.id
}

output "slb_connection" {
  value = <<EOF
curl http://${alicloud_slb_load_balancer.slb_load_balancer.address}:8000
EOF
}

## 创建一台 ecs

data "alicloud_instance_types" "instance_types_1c1g" {
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

resource "alicloud_security_group" "security_group" {
  name   = "${var.name}-security-group"
  vpc_id = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "security_group_rule" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.security_group.id
  cidr_ip           = "123.113.97.7/32"
}

resource "alicloud_instance" "instance" {
  count           = var.instance_number
  image_id        = data.alicloud_images.ubuntu_22.images[0].id
  instance_type   = data.alicloud_instance_types.instance_types_1c1g.instance_types[0].id
  security_groups = [
    alicloud_security_group.security_group.id,
  ]
  vswitch_id                 = alicloud_vswitch.vswitchs[count.index % length(alicloud_vswitch.vswitchs)].id
  internet_max_bandwidth_out = 5
  internet_charge_type       = "PayByTraffic"
  instance_name              = "${var.name}-instance"
  host_name                  = "${var.name}-instance"
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
  value = alicloud_instance.instance.*.public_ip
}
