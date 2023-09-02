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

resource "alicloud_oss_bucket" "oss_bucket_tf_state" {
  bucket = "${var.name}-tf-state"
}

resource "alicloud_ots_instance" "ots_instance_tf_remote" {
  name = "${var.name}-tf-remote"
}

resource "alicloud_ots_table" "ots_table_statelock" {
  instance_name = alicloud_ots_instance.ots_instance_tf_remote.name
  max_version   = 1
  table_name    = "statelock"
  time_to_live  = -1
  primary_key {
    name = "LockID"
    type = "String"
  }
}

output "description" {
  value = <<EOF
terraform {
  backend "oss" {
    bucket              = "${alicloud_oss_bucket.oss_bucket_tf_state.bucket}"
    prefix              = ""
    key                 = ""
    region              = "${var.region}"
    tablestore_endpoint = "https://${alicloud_ots_instance.ots_instance_tf_remote.name}.${var.region}.ots.aliyuncs.com"
    tablestore_table    = "${alicloud_ots_table.ots_table_statelock.table_name}"
  }
}
EOF
}
