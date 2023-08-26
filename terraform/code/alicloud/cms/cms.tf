terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.209.0"
    }
  }
}

resource "alicloud_cms_alarm_contact" "hatlonely" {
  alarm_contact_name = "hatlonely"
  describe           = "hatlonely"
  channels_mail      = "hatlonely@foxmail.com"
  channels_sms       = "13112341234"
  lang               = "zh-cn"
}

resource "alicloud_cms_alarm_contact_group" "tf-test-cms-alarm-contact-group" {
  alarm_contact_group_name = "tf-test-cms-alarm-contact-group"
  contacts                 = [
    alicloud_cms_alarm_contact.hatlonely.id,
  ]
}
