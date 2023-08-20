# terraform alicloud mns

## 创建一个 mns 主题和队列

```terraform
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
  alias  = "cn-beijing"
}

data "alicloud_regions" "regions" {
  current = true
}

data "alicloud_account" "account" {}

resource "alicloud_mns_topic" "test-topic" {
  name                 = "tf-test-mns-topic"
  maximum_message_size = 65536
  logging_enabled      = false
}

resource "alicloud_mns_queue" "test-queue" {
  name                     = "tf-test-mns-queue"
  delay_seconds            = 0
  maximum_message_size     = 65536
  message_retention_period = 345600
  visibility_timeout       = 30
  polling_wait_seconds     = 0
}

resource "alicloud_mns_topic_subscription" "test-subscription" {
  topic_name            = alicloud_mns_topic.test-topic.name
  name                  = "tf-test-mns-subscription"
  endpoint              = "acs:mns:${data.alicloud_regions.regions.regions[0].id}:${data.alicloud_account.account.id}:queues/${alicloud_mns_queue.test-queue.name}"
  notify_strategy       = "BACKOFF_RETRY"
  notify_content_format = "JSON"
}

output "topic" {
  value = {
    name     = alicloud_mns_topic.test-topic.name
    endpoint = "http://${data.alicloud_account.account.id}.mns.${data.alicloud_regions.regions.regions[0].id}.aliyuncs.com/"
  }
}
```

## 参考链接

- [terraform-alicloud-mns](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/mns_topic)
- [源码地址](../code/alicloud/mns/mns.tf)

