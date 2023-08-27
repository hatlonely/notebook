# 创建日志服务项目
resource "alicloud_log_project" "log-project" {
  name = "${var.name}-project"
}

# 创建日志服务日志库
resource "alicloud_log_store" "log-store-access-log" {
  name                  = "${var.name}-access-log"
  project               = alicloud_log_project.log-project.name
  shard_count           = 3
  auto_split            = true
  max_split_shard_count = 60
  append_meta           = true
}

# 创建日志服务索引
resource "alicloud_log_store_index" "log-store-index-access-log" {
  logstore = alicloud_log_store.log-store-access-log.name
  project  = alicloud_log_project.log-project.name
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
  field_search {
    name             = "status"
    enable_analytics = true
    type             = "long"
  }
}

# 创建日志服务机器组
resource "alicloud_log_machine_group" "log-machine-group" {
  name          = "${var.name}-machine-group"
  project       = alicloud_log_project.log-project.name
  identify_type = "userdefined"
  topic         = "${var.name}-machine-group-topic"
  identify_list = [var.name]
}

# 创建日志库配置
resource "alicloud_logtail_config" "logtail-config-access-log" {
  name         = "${var.name}-logtail-config"
  project      = alicloud_log_project.log-project.name
  logstore     = alicloud_log_store.log-store-access-log.name
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
resource "alicloud_logtail_attachment" "logtail-attachment-access-log" {
  logtail_config_name = alicloud_logtail_config.logtail-config-access-log.name
  machine_group_name  = alicloud_log_machine_group.log-machine-group.name
  project             = alicloud_log_project.log-project.name
}

# 创建 dashboard
# 不建议使用 terraform 创建 dashboard，因为 dashboard 的配置比较复杂，不如 gui 配置简单
resource "alicloud_log_dashboard" "log-dashboard" {
  project_name   = alicloud_log_project.log-project.name
  dashboard_name = "log-dashboard"
  display_name   = "log-dashboard"
  attribute      = "{\"type\":\"grid\"}"
  char_list      = <<EOF
  [
    {
      "action": {},
      "title": "${var.name}-pv",
      "type": "linepro",
      "search": {
        "chartQueries": [
          {
            "datasource": "logstore",
            "logstore": "${alicloud_log_store.log-store-access-log.name}",
            "project": "${alicloud_log_project.log-project.name}",
            "query": "* | SELECT date_trunc('minute', __time__) AS t, COUNT(*) AS pv GROUP BY t",
            "tokenQuery": "* | SELECT date_trunc('minute', __time__) AS t, COUNT(*) AS pv GROUP BY t"
          }
        ],
        "logstore": "${alicloud_log_store.log-store-access-log.name}",
        "topic": "",
        "query": "@",
        "start": "-3600s",
        "end": "now"
      },
      "display": {
        "xAxis": [
          "time"
        ],
        "yAxis": [
          "pv"
        ],
        "xPos": 0,
        "yPos": 0,
        "width": 20,
        "height": 10,
        "displayName": "${var.name} pv"
      }
    }
  ]
EOF
}

resource "alicloud_log_alert" "log-alert-status-not-200" {
  alert_displayname = "status-not-200"
  alert_name        = "status-not-200"
  project_name      = alicloud_log_project.log-project.name
  auto_annotation   = true
  mute_until        = 0
  no_data_fire      = false
  no_data_severity  = 6
  send_resolved     = false
  threshold         = 1
  type              = "default"
  version           = "2.0"

  annotations {
    key   = "title"
    value = "$${alert_name}告警触发"
  }
  annotations {
    key   = "desc"
    value = "$${alert_name}告警触发"
  }

  group_configuration {
    fields = []
    type   = "no_group"
  }

  policy_configuration {
    action_policy_id = "sls.builtin"
    alert_policy_id  = "sls.builtin.dynamic"
    repeat_interval  = "1m"
  }

  query_list {
    end            = "now"
    power_sql_mode = "disable"
    project        = alicloud_log_project.log-project.name
    query          = "* | SELECT date_trunc('minute', __time__) AS t, COUNT(*) AS pv GROUP BY t"
    region         = "cn-beijing"
    start          = "-300s"
    store          = alicloud_log_store.log-store-access-log.name
    store_type     = "log"
    time_span_type = "Relative"
  }

  schedule {
    day_of_week     = 0
    delay           = 0
    hour            = 0
    interval        = "1m"
    run_immediately = true
    type            = "FixedRate"
  }

  severity_configurations {
    eval_condition = {
      "condition"       = ""
      "count_condition" = ""
    }
    severity = 6
  }
}
