data "alicloud_instance_types" "web-instance-types" {
  cpu_core_count = 1
  memory_size    = 1
}

data "alicloud_images" "ubuntu_22" {
  name_regex = "^ubuntu_22"
  owners     = "system"
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

#resource "alicloud_instance" "tf-test-ecs" {
#  count           = var.instance_number
#  image_id        = data.alicloud_images.ubuntu_22.images[0].id
#  instance_type   = data.alicloud_instance_types.web-instance-types.instance_types[0].id
#  security_groups = [
#    alicloud_security_group.tf-test-security-group.id,
#  ]
#  vswitch_id                 = alicloud_vswitch.tf-test-vswitch[count.index % length(alicloud_vswitch.tf-test-vswitch)].id
#  internet_max_bandwidth_out = 5
#  internet_charge_type       = "PayByTraffic"
#  host_name                  = "tf-test-ecs"
#  user_data                  = base64encode(file("${path.module}/init.sh"))
#
#  connection {
#    type     = "ssh"
#    user     = "root"
#    password = random_password.password.result
#    host     = self.public_ip
#  }
#
#  provisioner "remote-exec" {
#    inline = [
#      "bash -c \"$(curl -fsSL http://100.100.100.200/latest/user-data)\""
#    ]
#  }
#}