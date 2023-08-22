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
  user_data            = base64encode(file("${path.module}/init.sh"))
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
}


# 输出连接跳板机的命令
output "connection-jump-server" {
  value = "ssh -i id_rsa root@${alicloud_instance.tf-test-jump-server.public_ip}"
}
