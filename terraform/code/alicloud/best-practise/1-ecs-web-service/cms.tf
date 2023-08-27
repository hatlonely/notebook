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
  for_each = alicloud_instance.instances

  group_id = alicloud_cms_monitor_group.cms-monitor-group.id
  instances {
    instance_id   = each.value.id
    instance_name = each.value.instance_name
    region_id     = "cn-beijing"
    category      = "ecs"
  }
}