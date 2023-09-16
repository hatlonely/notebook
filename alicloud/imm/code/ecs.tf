provider "alicloud" {}

resource "alicloud_vpc" "vpc" {
  vpc_name   = "tf-imm-document-preview-test-vpc"
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_vswitch" "vsw" {
  vpc_id     = alicloud_vpc.vpc.id
  cidr_block = "172.16.0.0/21"
  zone_id    = "cn-beijing-b"
}

resource "alicloud_security_group" "default" {
  name   = "default"
  vpc_id = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

data "alicloud_instance_types" "ecs_4c8g" {
  cpu_core_count = 4
  memory_size    = 8
}

resource "random_password" "password" {
  length           = 20
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

resource "alicloud_instance" "instance" {
  availability_zone = "cn-beijing-b"
  security_groups   = alicloud_security_group.default.*.id

  instance_type              = data.alicloud_instance_types.ecs_4c8g.instance_types[0].id
  instance_charge_type       = "PostPaid"
  system_disk_category       = "cloud_efficiency"
  image_id                   = "win2012r2_9600_x64_dtc_zh-cn_40G_alibase_20221219.vhd"
  instance_name              = "tf-imm-document-preview-test"
  vswitch_id                 = alicloud_vswitch.vsw.id
  internet_max_bandwidth_out = 0
  password                   = random_password.password.result
}
