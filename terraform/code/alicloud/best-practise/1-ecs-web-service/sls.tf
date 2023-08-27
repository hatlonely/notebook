# 创建日志服务项目
resource "alicloud_log_project" "tf-test-project" {
  name = "tf-test-project"
}

# 创建日志服务日志库
resource "alicloud_log_store" "tf-test-store" {
  name                  = "${var.name}-access-log"
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
    name             = "http_user_agent"
    enable_analytics = true
    type             = "text"
    token            = " #$^*\r\n\t"
  }
  field_search {
    name             = "remote_addr"
    enable_analytics = true
    type             = "text"
    token            = " #$^*\r\n\t"
  }
}

# 创建日志服务机器组
resource "alicloud_log_machine_group" "tf-test-machine-group" {
  name          = "${var.name}-machine-group"
  project       = alicloud_log_project.tf-test-project.name
  identify_type = "userdefined"
  topic         = "${var.name}-machine-group-topic"
  identify_list = [var.name]
}

# 创建日志库配置
resource "alicloud_logtail_config" "tf-test-logtail-config" {
  name         = "${var.name}-logtail-config"
  project      = alicloud_log_project.tf-test-project.name
  logstore     = alicloud_log_store.tf-test-store.name
  input_type   = "file"
  output_type  = "LogService"
  input_detail = <<EOF
  {
    "logPath": "/root/nginx/var/log",
    "filePattern": "access.log",
    "logType": "common_reg_log",
    "topicFormat": "default",
    "discardUnmatch": false,
    "enableRawLog": true,
    "fileEncoding": "utf8",
    "maxDepth": 10,
    "key": [
      "remote_addr", "remote_user", "time_local", "request", "version", "status", "body_bytes_sent",
      "http_referer", "http_user_agent"
    ],
    "logBeginRegex": ".*",
    "regex": "(\\S+)\\s-\\s(\\S+)\\s\\[([^]]+)]\\s\"(\\w+)([^\"]+)\"\\s(\\d+)\\s(\\d+)[^-]+([^\"]+)\"\\s\"([^\"]+).*"
 }
EOF
}

# 关联日志库配置
resource "alicloud_logtail_attachment" "tf-test-logtail-attachment" {
  logtail_config_name = alicloud_logtail_config.tf-test-logtail-config.name
  machine_group_name  = alicloud_log_machine_group.tf-test-machine-group.name
  project             = alicloud_log_project.tf-test-project.name
}
