# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/fc_service
resource "alicloud_fc_service" "default" {
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


