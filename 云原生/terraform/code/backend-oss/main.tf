provider "alicloud" {
  access_key = var.access_key_id
  secret_key = var.access_key_secret
  region     = var.region
}

variable "access_key_id" {
  type = "string"
}

variable "access_key_secret" {
  type = "string"
}

variable "region" {
  type    = "string"
  default = "cn-hangzhou"
}

variable "name" {
  type = string
}

resource "alicloud_oss_bucket" "oss-bucket" {
  bucket = "${name}-tf-backend"
}

resource "alicloud_ots_instance" "ots-instance" {
  name = "${name}-tf-backend-lock"
}
