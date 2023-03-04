variable "access_key_id" {
  type = string
}

variable "access_key_secret" {
  type = string
}

variable "region" {
  type    = string
  default = "cn-hangzhou"
}

variable "name" {
  type = string
}

provider "alicloud" {
  access_key = var.access_key_id
  secret_key = var.access_key_secret
  region     = var.region
}

resource "alicloud_oss_bucket" "oss-tf-state" {
  bucket = "${var.name}-tf-state"
}

resource "alicloud_ots_instance" "ots-tf-remote" {
  name = "${var.name}-tf-remote"
}

resource "alicloud_ots_table" "ots-tf-remote-table" {
  instance_name = alicloud_ots_instance.ots-tf-remote.name
  max_version   = 1
  table_name    = "statelock"
  time_to_live  = -1
  primary_key {
    name = "LockID"
    type = "String"
  }
}

output "description" {
  value = <<EOT
terraform {
  backend "oss" {
    bucket              = "${alicloud_oss_bucket.oss-tf-state.bucket}"
    prefix              = ""
    key                 = ""
    region              = "${var.region}"
    tablestore_endpoint = "https://${alicloud_ots_instance.ots-tf-remote.name}.${var.region}.ots.aliyuncs.com"
    tablestore_table    = "${alicloud_ots_table.ots-tf-remote-table.table_name}"
  }
}
EOT
}
