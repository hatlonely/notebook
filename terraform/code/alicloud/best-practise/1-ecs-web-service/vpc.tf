data "alicloud_zones" "zones-available-vswitch" {
  available_resource_creation = "VSwitch"
}

# 创建VPC
resource "alicloud_vpc" "vpc" {
  vpc_name   = "${var.name}-vpc"
  cidr_block = "172.16.0.0/16"
}

# 创建交换机
resource "alicloud_vswitch" "vswitchs" {
  for_each = {
    for idx, zone in data.alicloud_zones.zones-available-vswitch.zones : idx => zone
  }

  zone_id    = each.value.id
  vpc_id     = alicloud_vpc.vpc.id
  cidr_block = cidrsubnet(alicloud_vpc.vpc.cidr_block, 8, each.key)
}

# 创建NAT网关
resource "alicloud_nat_gateway" "nat-gateway" {
  vpc_id           = alicloud_vpc.vpc.id
  nat_gateway_name = "${var.name}-nat-gateway"
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.vswitchs.0.id
  nat_type         = "Enhanced"
}

# 创建公网IP
resource "alicloud_eip_address" "eip-outbounds" {
  bandwidth            = "5"
  internet_charge_type = "PayByTraffic"
  payment_type         = "PayAsYouGo"
  netmode              = "public"
  isp                  = "BGP"
  address_name         = "tf-test-eip"
}

# 绑定公网IP
resource "alicloud_eip_association" "eip-association-nat-gateway" {
  allocation_id = alicloud_eip_address.eip-outbounds.id
  instance_id   = alicloud_nat_gateway.nat-gateway.id
}

# 创建SNAT条目
resource "alicloud_snat_entry" "snat-entry" {
  for_each          = alicloud_vswitch.vswitchs
  snat_table_id     = alicloud_nat_gateway.nat-gateway.snat_table_ids
  source_vswitch_id = each.value.id
  snat_ip           = alicloud_eip_address.eip-outbounds.ip_address
}
