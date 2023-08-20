# terraform alicloud sls

## 创建一个日志服务

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

# 创建日志服务项目
resource "alicloud_log_project" "tf-test-project" {
  name = "tf-test-project"
}

# 创建日志服务日志库
resource "alicloud_log_store" "tf-test-store" {
  name                  = "tf-test-store"
  project               = alicloud_log_project.tf-test-project.name
  shard_count           = 3
  auto_split            = true
  max_split_shard_count = 60
  append_meta           = true
}

# 创建日志服务索引
resource "alicloud_log_store_index" "tf-test-store-index" {
  logstore = alicloud_log_store.tf-test-store.name
  project  = alicloud_log_project.tf-test-project.name
  full_text {
    case_sensitive = true
    token          = "#$^*\r\n\t"
  }
  field_search {
    name             = "requestId"
    enable_analytics = true
    type             = "text"
    token            = " #$^*\r\n\t"
  }
}

# 创建日志服务机器组
resource "alicloud_log_machine_group" "tf-test-machine-group" {
  name          = "tf-test-machine-group"
  project       = alicloud_log_project.tf-test-project.name
  identify_type = "userdefined"
  topic         = "tf-test-machine-group-topic"
  identify_list = ["tf-test-machine-group-identify"]
}

# 创建日志库配置
resource "alicloud_logtail_config" "tf-test-logtail-config" {
  name         = "tf-test-logtail-config"
  project      = alicloud_log_project.tf-test-project.name
  logstore     = alicloud_log_store.tf-test-store.name
  input_type   = "file"
  output_type  = "LogService"
  input_detail = <<EOF
  {
    "logPath": "/work/app",
    "filePattern": "grpc.log",
    "logType": "json_log",
    "topicFormat": "default",
    "discardUnmatch": false,
    "enableRawLog": true,
    "fileEncoding": "utf8",
    "maxDepth": 10
 }
EOF
}

# 关联日志库配置
resource "alicloud_logtail_attachment" "tf-test-logtail-attachment" {
  logtail_config_name = alicloud_logtail_config.tf-test-logtail-config.name
  machine_group_name  = alicloud_log_machine_group.tf-test-machine-group.name
  project             = alicloud_log_project.tf-test-project.name
}
```

## 参考链接

- [terraform-alicloud-sls](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/log_project)
- [源码地址](../code/alicloud/sls/sls.tf)

