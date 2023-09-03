terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.209.0"
    }
  }
}

variable "name" {
  type    = string
  default = "tf-test"
}

provider "alicloud" {
  region = "cn-beijing"
  alias  = "cn-beijing"
}

resource "alicloud_ots_instance" "ots_instance" {
  name = "${var.name}-ots"
}

output "connection" {
  value = {
    endpoint : "https://${alicloud_ots_instance.ots_instance.name}.cn-beijing.ots.aliyuncs.com"
    endpointVpc : "https://${alicloud_ots_instance.ots_instance.name}.cn-beijing.vpc.tablestore.aliyuncs.com"
  }
}
