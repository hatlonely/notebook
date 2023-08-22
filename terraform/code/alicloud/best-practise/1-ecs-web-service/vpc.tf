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

resource "alicloud_nat_gateway" "tf-test-nat-gateway" {
  vpc_id           = alicloud_vpc.tf-test-vpc.id
  nat_gateway_name = "tf-test-nat-gateway"
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.tf-test-vswitch.0.id
  nat_type         = "Enhanced"
}
