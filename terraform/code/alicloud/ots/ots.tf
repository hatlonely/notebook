terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.209.0"
    }
  }
}

provider "alicloud" {
  region = "cn-beijing"
  alias  = "cn-beijing"
}


resource "alicloud_ots_instance" "tf-test-ots-instance" {
  name = "tf-test"
}

output "connection" {
  value = {
    endpoint : "https://${alicloud_ots_instance.tf-test-ots-instance.name}.cn-beijing.ots.aliyuncs.com"
    endpointVpc : "https://${alicloud_ots_instance.tf-test-ots-instance.name}.cn-beijing.vpc.tablestore.aliyuncs.com"
  }
}
