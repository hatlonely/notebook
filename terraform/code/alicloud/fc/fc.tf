# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/fc_service
resource "alicloud_fc_service" "fc_service" {
  name        = var.name
  description = var.name
  role        = alicloud_ram_role.ram_role_fc.arn
  log_config {
    project                 = alicloud_log_project.log_project.name
    logstore                = alicloud_log_store.log_store.name
    enable_instance_metrics = true
    enable_request_metrics  = true
  }
}

# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/fc_function
# https://www.alibabacloud.com/help/zh/fc/developer-reference/api-fc-open-2021-04-06-struct-httptriggerconfig
resource "alicloud_fc_function" "fc_function" {
  depends_on = [
    alicloud_ram_role_policy_attachment.ram_role_policy_attachment_fc_acr,
    alicloud_ram_role_policy_attachment.ram_role_policy_attachment_fc_log,
  ]

  service     = alicloud_fc_service.fc_service.name
  name        = var.name
  description = var.name
  memory_size = "512"
  runtime     = "custom-container"
  handler     = "index.handler"
  custom_container_config {
    image = var.image
  }
  ca_port = 8000
}

resource "alicloud_fc_trigger" "fc_trigger" {
  service  = alicloud_fc_service.fc_service.name
  function = alicloud_fc_function.fc_function.name
  name     = var.name
  type     = "http"
  config = jsonencode({
    authType = "anonymous"
    methods  = ["GET", "POST", "PUT", "DELETE"]
  })
}

output "trigger" {
  value = alicloud_fc_trigger.fc_trigger
}
