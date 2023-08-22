terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.209.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "alicloud" {
  region = "cn-beijing"
  alias  = "cn-beijing"
}

variable "instance_number" {
  type    = number
  default = 1
}