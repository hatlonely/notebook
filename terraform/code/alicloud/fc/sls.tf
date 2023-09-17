resource "alicloud_log_project" "log_project" {
  name = var.name
}

resource "alicloud_log_store" "log_store" {
  name                  = var.name
  project               = alicloud_log_project.log_project.name
  shard_count           = 3
  max_split_shard_count = 60
  auto_split            = true
}

locals {
  sls_default_token = ", '\";=()[]{}?@&<>/:\n\t\r"
}

resource "alicloud_log_store_index" "log_store_index" {
  project  = alicloud_log_project.log_project.name
  logstore = alicloud_log_store.log_store.name
  full_text {
    case_sensitive = false
    token          = local.sls_default_token
  }
  field_search {
    name             = "aggPeriodSeconds"
    enable_analytics = true
    type             = "long"
    token            = local.sls_default_token
  }
  field_search {
    name             = "concurrentRequests"
    enable_analytics = true
    type             = "long"
    token            = local.sls_default_token
  }
  field_search {
    name             = "cpuPercent"
    enable_analytics = true
    type             = "double"
    token            = local.sls_default_token
  }
  field_search {
    name             = "cpuQuotaPercent"
    enable_analytics = true
    type             = "double"
    token            = local.sls_default_token
  }
  field_search {
    name             = "functionName"
    enable_analytics = true
    type             = "text"
    token            = local.sls_default_token
    case_sensitive   = true
  }
  field_search {
    name             = "hostname"
    enable_analytics = true
    type             = "text"
    token            = local.sls_default_token
  }
  field_search {
    name             = "instanceID"
    enable_analytics = true
    type             = "text"
    token            = local.sls_default_token
  }
  field_search {
    name             = "ipAddress"
    enable_analytics = true
    type             = "text"
    token            = local.sls_default_token
  }
  field_search {
    name             = "memoryLimitMB"
    enable_analytics = true
    type             = "double"
    token            = local.sls_default_token
  }
  field_search {
    name             = "memoryUsageMB"
    enable_analytics = true
    type             = "double"
    token            = local.sls_default_token
  }
  field_search {
    name             = "memoryUsagePercent"
    enable_analytics = true
    type             = "double"
    token            = local.sls_default_token
  }
  field_search {
    name             = "operation"
    enable_analytics = true
    type             = "text"
    token            = local.sls_default_token
  }
  field_search {
    name             = "qualifier"
    enable_analytics = true
    type             = "text"
    token            = local.sls_default_token
    case_sensitive   = true
  }
  field_search {
    name             = "rxBytes"
    enable_analytics = true
    type             = "long"
    token            = local.sls_default_token
  }
  field_search {
    name             = "rxTotalBytes"
    enable_analytics = true
    type             = "long"
    token            = local.sls_default_token
  }
  field_search {
    name             = "serviceName"
    enable_analytics = true
    type             = "text"
    token            = local.sls_default_token
    case_sensitive   = true
  }
  field_search {
    name             = "txBytes"
    enable_analytics = true
    type             = "long"
    token            = local.sls_default_token
  }
  field_search {
    name             = "txTotalBytes"
    enable_analytics = true
    type             = "long"
    token            = local.sls_default_token
  }
  field_search {
    name             = "versionId"
    enable_analytics = true
    type             = "text"
    token            = local.sls_default_token
  }
  field_search {
    name             = "events"
    enable_analytics = true
    type             = "json"
    token            = local.sls_default_token
  }
  field_search {
    name             = "isColdStart"
    enable_analytics = true
    type             = "text"
    token            = local.sls_default_token
  }
  field_search {
    name             = "hasFunctionError"
    enable_analytics = true
    type             = "text"
    token            = local.sls_default_token
  }
  field_search {
    name             = "errorType"
    enable_analytics = true
    type             = "text"
    token            = local.sls_default_token
  }
  field_search {
    name             = "triggerType"
    enable_analytics = true
    type             = "text"
    token            = local.sls_default_token
  }
  field_search {
    name             = "durationMs"
    enable_analytics = true
    type             = "double"
    token            = local.sls_default_token
  }
  field_search {
    name             = "statusCode"
    enable_analytics = true
    type             = "long"
    token            = local.sls_default_token
  }
}
