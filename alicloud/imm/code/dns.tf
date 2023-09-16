#域名: cn-beijing.office-static.aliyunpds.com
#记录类型: CNAME
#解析记录: office-static-imm-cn-beijing.oss-cn-beijing-internal.aliyuncs.com
#
#域名: office-imm-tmp-cn-beijing.oss-cn-beijing.aliyuncs.com
#记录类型: CNAME
#解析记录: office-imm-tmp-cn-beijing.oss-cn-beijing-internal.aliyuncs.com

resource "alicloud_pvtz_zone" "office_static" {
  zone_name = "office-static.aliyunpds.com"
  proxy_pattern = "RECORD"
}

resource "alicloud_pvtz_zone" "office_tmp" {
  zone_name = "oss-cn-beijing.aliyuncs.com"
  proxy_pattern = "RECORD"
}

resource "alicloud_pvtz_zone_record" "office_static_cname" {
  zone_id = alicloud_pvtz_zone.office_static.id
  rr      = "cn-beijing"
  type    = "CNAME"
  value   = "office-static-imm-cn-beijing.oss-cn-beijing-internal.aliyuncs.com"
  ttl     = 60
}

resource "alicloud_pvtz_zone_record" "office_tmp_cname" {
  zone_id = alicloud_pvtz_zone.office_tmp.id
  rr      = "office-imm-tmp-cn-beijing"
  type    = "CNAME"
  value   = "office-imm-tmp-cn-beijing.oss-cn-beijing-internal.aliyuncs.com"
  ttl     = 60
}

resource "alicloud_pvtz_zone_attachment" "office_static_attachment" {
  zone_id = alicloud_pvtz_zone.office_static.id
  vpc_ids = [alicloud_vpc.vpc.id]
}

resource "alicloud_pvtz_zone_attachment" "office_tmp_attachment" {
  zone_id = alicloud_pvtz_zone.office_tmp.id
  vpc_ids = [alicloud_vpc.vpc.id]
}
