terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.209.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "alicloud" {
  region = "cn-beijing"
  alias  = "cn-beijing"
}

# 创建告警人
resource "alicloud_cms_alarm_contact" "hatlonely" {
  alarm_contact_name = "hatlonely"
  describe           = "hatlonely"
  channels_mail      = "hatlonely@foxmail.com"
}

# 创建告警联系组
resource "alicloud_cms_alarm_contact_group" "tf-test-cms-alarm-contact-group" {
  alarm_contact_group_name = "tf-test-cms-alarm-contact-group"
  contacts                 = [
    alicloud_cms_alarm_contact.hatlonely.id,
  ]
}

# 创建告警监控组
resource "alicloud_cms_monitor_group" "tf-test-cms-monitor-group" {
  monitor_group_name = "tf-test-cms-monitor-group"
  contact_groups     = [
    alicloud_cms_alarm_contact_group.tf-test-cms-alarm-contact-group.id,
  ]
}

# 创建告警监控组实例
resource "alicloud_cms_monitor_group_instances" "tf-test-cms-monitor-group-instances" {
  group_id = alicloud_cms_monitor_group.tf-test-cms-monitor-group.id
  instances {
    instance_id   = alicloud_instance.tf-test-ecs.id
    instance_name = alicloud_instance.tf-test-ecs.instance_name
    region_id     = "cn-beijing"
    category      = "ecs"
  }
}

# 创建告警监控组规则
resource "alicloud_cms_group_metric_rule" "tf-test-cms-group-metric-rule-cpu-total" {
  group_id               = alicloud_cms_monitor_group.tf-test-cms-monitor-group.id
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

## 创建一个 ECS 实例用于上面的告警

# 生成密码
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()[]{}_-=+/?<>"
}

# 自动获取实例类型
data "alicloud_instance_types" "type-1c1g" {
  cpu_core_count = 1
  memory_size    = 1
}

# 自动获取镜像
data "alicloud_images" "ubuntu_22" {
  name_regex = "^ubuntu_22"
  owners     = "system"
}

# 创建 VPC
resource "alicloud_vpc" "tf-test-vpc" {
  vpc_name   = "tf-test-vpc"
  cidr_block = "172.16.0.0/16"
}

# 创建 VSwitch
resource "alicloud_vswitch" "tf-test-vswitch" {
  zone_id    = "cn-beijing-b"
  vpc_id     = alicloud_vpc.tf-test-vpc.id
  cidr_block = "172.16.0.0/24"
}

# 创建安全组，现在安全组只能创建在 VPC 内，但其规则可以是公网或内网
resource "alicloud_security_group" "tf-test-security-group" {
  name   = "tf-test-security-group"
  vpc_id = alicloud_vpc.tf-test-vpc.id
}

# 创建安全组规则，nic_type 必须为 intranet，但其规则对公网同样有效
resource "alicloud_security_group_rule" "tf-test-security-group-rule" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.tf-test-security-group.id
  cidr_ip           = "123.113.97.7/32"
}

# 创建一台带公网 ip 密码登录的 ECS
resource "alicloud_instance" "tf-test-ecs" {
  instance_name   = "tf-test-ecs"
  image_id        = data.alicloud_images.ubuntu_22.images[0].id
  instance_type   = data.alicloud_instance_types.type-1c1g.instance_types[0].id
  security_groups = [
    alicloud_security_group.tf-test-security-group.id,
  ]
  vswitch_id                 = alicloud_vswitch.tf-test-vswitch.id
  internet_max_bandwidth_out = 5
  internet_charge_type       = "PayByTraffic"
  host_name                  = "tf-test-ecs"
  password                   = random_password.password.result
}
