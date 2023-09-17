terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.209.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

variable "name" {
  type    = string
  default = "tf-test-fc"
}

variable "image" {
  type    = string
  default = "registry.cn-beijing.aliyuncs.com/hatlonely/flask-demo:latest"
}
