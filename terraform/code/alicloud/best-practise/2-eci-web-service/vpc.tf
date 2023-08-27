locals {
  ecs_available_zone_cn_beijing = [
    "cn-beijing-l",
    "cn-beijing-k",
    "cn-beijing-j",
    "cn-beijing-i",
    "cn-beijing-h",
    "cn-beijing-g",
    "cn-beijing-f",
    "cn-beijing-e",
    "cn-beijing-d",
    "cn-beijing-c",
  ]
}

# 创建VPC
resource "alicloud_vpc" "tf-test-vpc" {
  vpc_name   = "tf-test-vpc"
  cidr_block = "172.16.0.0/16"
}

# 创建交换机
resource "alicloud_vswitch" "tf-test-vswitch" {
  for_each = {
    for idx, zone in local.ecs_available_zone_cn_beijing : idx => zone
  }

  zone_id    = each.value
  vpc_id     = alicloud_vpc.tf-test-vpc.id
  cidr_block = cidrsubnet(alicloud_vpc.tf-test-vpc.cidr_block, 8, each.key)
}
