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
resource "alicloud_fc_function" "foo" {
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
}
