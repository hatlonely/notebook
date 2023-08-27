# 创建告警人
resource "alicloud_cms_alarm_contact" "hatlonely" {
  alarm_contact_name = "${var.name}-hatlonely"
  describe           = "${var.name} hatlonely"
  channels_mail      = "hatlonely@foxmail.com"
}

# 创建告警联系组
resource "alicloud_cms_alarm_contact_group" "cms-alarm-contact-group" {
  alarm_contact_group_name = "${var.name}-cms-alarm-contact-group"
  contacts                 = [
    alicloud_cms_alarm_contact.hatlonely.id,
  ]
}

# 创建告警监控组
resource "alicloud_cms_monitor_group" "cms-monitor-group" {
  monitor_group_name = "${var.name}-cms-monitor-group"
  contact_groups     = [
    alicloud_cms_alarm_contact_group.cms-alarm-contact-group.id,
  ]
}

# 创建告警监控组实例
resource "alicloud_cms_monitor_group_instances" "cms-monitor-group-instances" {
  for_each = {for idx, instance in alicloud_instance.instances : idx => instance}

  group_id = alicloud_cms_monitor_group.cms-monitor-group.id
  instances {
    instance_id   = each.value.id
    instance_name = each.value.instance_name
    region_id     = "cn-beijing"
    category      = "ecs"
  }
}

# 创建告警监控组规则
resource "alicloud_cms_group_metric_rule" "cms-group-metric-rule-cpu-total" {
  group_id               = alicloud_cms_monitor_group.cms-monitor-group.id
  group_metric_rule_name = "cpu-total 超过阈值"
  rule_id                = "acs_ecs_dashboard:cpu_total"
  category               = "ecs"
  metric_name            = "cpu_total"
  namespace              = "acs_ecs_dashboard"
  period                 = 60
  interval               = 3600
  silence_time           = 85800
  no_effective_interval  = "00:00-05:30"

  escalations {
    critical {
      comparison_operator = "GreaterThanOrEqualToThreshold"
      statistics          = "Average"
      threshold           = 80
      times               = 3
    }

    warn {
      comparison_operator = "GreaterThanOrEqualToThreshold"
      statistics          = "Average"
      threshold           = 70
      times               = 3
    }

    info {
      comparison_operator = "GreaterThanOrEqualToThreshold"
      statistics          = "Average"
      threshold           = 60
      times               = 3
    }
  }
}
