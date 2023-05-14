terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.204.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "alicloud" {
  region = "cn-chengdu"
}

provider "random" {}

resource "alicloud_vpc" "vpc" {
  vpc_name   = "tf_test_vpc"
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_vswitch" "vsw" {
  vpc_id     = alicloud_vpc.vpc.id
  cidr_block = "172.16.0.0/21"
  zone_id    = "cn-chengdu-a"
}

resource "alicloud_security_group" "security_group" {
  name   = "tf-test-security-group-internet"
  vpc_id = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow_all_tcp_internet" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.security_group.id
  cidr_ip           = "123.113.105.30/32"
}

data "alicloud_instance_types" "ecs_4c8g" {
  cpu_core_count = 4
  memory_size    = 8
}

resource "random_password" "password" {
  length = 16
}

resource "alicloud_instance" "instance" {
  availability_zone          = "cn-chengdu-a"
  security_groups            = alicloud_security_group.security_group.*.id
  #  instance_type              = data.alicloud_instance_types.ecs_4c8g.instance_types[0].id
  instance_type              = "ecs.vgn7i-vws-m4.xlarge"
  system_disk_category       = "cloud_efficiency"
  image_id                   = "ubuntu_22_04_x64_20G_alibase_20230208.vhd"
  instance_name              = "tf-test-ecs"
  vswitch_id                 = alicloud_vswitch.vsw.id
  internet_max_bandwidth_out = 5
  password                   = random_password.password.result

  connection {
    type     = "ssh"
    user     = "root"
    password = random_password.password.result
    host     = self.public_ip
  }

  provisioner "file" {
    source      = "init.sh"
    destination = "/root/init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "/bin/bash /root/init.sh",
    ]
  }
}

output "ecs" {
  value = "ssh root@${alicloud_instance.instance.public_ip}"
}

output "password" {
  value = nonsensitive(alicloud_instance.instance.password)
}
