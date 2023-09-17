# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/mns_topic

terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.209.1"
    }
  }
}

variable "name" {
  type    = string
  default = "tf-test-mns"
}

provider "alicloud" {
  region = "cn-beijing"
  alias  = "cn-beijing"
}

data "alicloud_regions" "regions" {
  current = true
}

data "alicloud_account" "account" {}

resource "alicloud_mns_topic" "mns_topic" {
  name                 = "${var.name}-topic"
  maximum_message_size = 65536
  logging_enabled      = false
}

resource "alicloud_mns_queue" "mns_queue" {
  name                     = "tf-test-mns-queue"
  delay_seconds            = 0
  maximum_message_size     = 65536
  message_retention_period = 345600
  visibility_timeout       = 30
  polling_wait_seconds     = 0
}

resource "alicloud_mns_topic_subscription" "mns_topic_subscription_queue" {
  topic_name            = alicloud_mns_topic.mns_topic.name
  name                  = "${var.name}-subscription-queue"
  endpoint              = "acs:mns:${data.alicloud_regions.regions.regions[0].id}:${data.alicloud_account.account.id}:queues/${alicloud_mns_queue.mns_queue.name}"
  notify_strategy       = "BACKOFF_RETRY"
  notify_content_format = "JSON"
}

output "topic" {
  value = {
    name     = alicloud_mns_topic.mns_topic.name
    endpoint = "http://${data.alicloud_account.account.id}.mns.${data.alicloud_regions.regions.regions[0].id}.aliyuncs.com/"
  }
}
