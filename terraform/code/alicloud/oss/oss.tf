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
  default = "tf-test-oss"
}

provider "alicloud" {
  region = "cn-beijing"
}

resource "alicloud_oss_bucket" "oss_bucket" {
  bucket = "${var.name}-bucket"
  acl    = "private"

  lifecycle_rule {
    id      = "delete after 10 days"
    enabled = true
    prefix  = "logs/"
    expiration {
      days = 10
    }
  }
}
