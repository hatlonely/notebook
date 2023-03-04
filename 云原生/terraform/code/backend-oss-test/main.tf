variable "key1" {
  type = string
}

variable "key2" {
  type = number
}

terraform {
  backend "oss" {
    bucket              = "test-tf-state"
    prefix              = "backend-oss-test"
    region              = "cn-hangzhou"
    tablestore_endpoint = "https://test-tf-remote.cn-hangzhou.ots.aliyuncs.com"
    tablestore_table    = "statelock"
  }
}

output "out" {
  value = {
    key1 = var.key1
    key2 = var.key2
  }
}
