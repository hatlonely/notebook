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
