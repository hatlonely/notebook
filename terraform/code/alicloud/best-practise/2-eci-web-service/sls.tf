# 创建日志服务项目
resource "alicloud_log_project" "log_project" {
  name = "${var.name}-project"
}

## 创建日志服务日志库
resource "alicloud_log_store" "log_store_access_log" {
  name                  = "${var.name}-access-log"
  project               = alicloud_log_project.log_project.name
  shard_count           = 3
  auto_split            = true
  max_split_shard_count = 60
  append_meta           = true
  retention_period      = 90
}

# 创建日志库配置
# TODO 目前不支持解析日志格式，只有单行日志
resource "alicloud_logtail_config" "logtail_config_access_log" {
  name        = "${var.name}-access-log"
  project     = alicloud_log_project.log_project.name
  logstore    = alicloud_log_store.log_store_access_log.name
  input_type  = "plugin"
  output_type = "LogService"

  input_detail = jsonencode(
    {
      adjustTimezone  = false
      delayAlarmBytes = 0
      discardNonUtf8  = false
      enableRawLog    = false
      enableTag       = false
      filterKey       = []
      filterRegex     = []
      localStorage    = true
      logTimezone     = ""
      maxSendRate     = -1
      mergeType       = "topic"
      plugin          = {
        inputs = [
          {
            detail = {
              IncludeEnv = {
                "aliyun_logs_${var.name}-access-log" = "stdout"
              }
              Stderr = true
              Stdout = true
            }
            type = "service_docker_stdout"
          },
        ]
      }
      priority       = 0
      sendRateExpire = 0
      sensitive_keys = []
    }
  )
}
