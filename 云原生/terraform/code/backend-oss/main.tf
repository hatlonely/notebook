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

resource "alicloud_oss_bucket" "oss-bucket" {
  bucket = "${name}-tf-state"
}

resource "alicloud_ots_instance" "ots-instance" {
  name = "${name}-tf-remote"
}
