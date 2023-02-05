provider "time" {}
provider "null" {}

resource "time_static" "create_time" {}

resource "time_offset" "a_week_later" {
  base_rfc3339 = time_static.create_time.rfc3339
  offset_days  = 7
}

resource "time_rotating" "every_week" {
  rotation_minutes = 1
}

output "time" {
  value = {
    create_time  = time_static.create_time.rfc3339
    a_week_later = time_offset.a_week_later.rfc3339
    every_week   = time_rotating.every_week.rfc3339
  }
}

// next 在 prev 创建完成 1s 之后再创建
resource "null_resource" "prev" {}

resource "time_sleep" "wait_1s" {
  depends_on      = [null_resource.prev]
  create_duration = "1s"
}

resource "null_resource" "next" {
  depends_on = [time_sleep.wait_1s]
}
