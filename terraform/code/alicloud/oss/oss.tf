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
}

resource "alicloud_oss_bucket" "tf-hatlonely-test-oss-bucket" {
  bucket = "tf-hatlonely-test-oss-bucket"
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
