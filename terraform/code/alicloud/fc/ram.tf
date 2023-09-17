resource "alicloud_ram_role" "ram_role_fc" {
  name        = "${var.name}-fcservicerole"
  document    = <<EOF
  {
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Effect": "Allow",
          "Principal": {
            "Service": [
              "fc.aliyuncs.com"
            ]
          }
        }
      ],
      "Version": "1"
  }
  EOF
  description = "${var.name} role"
  force       = true
}

resource "alicloud_ram_role_policy_attachment" "ram_role_policy_attachment_fc_log" {
  role_name   = alicloud_ram_role.ram_role_fc.name
  policy_name = "AliyunLogFullAccess"
  policy_type = "System"
}

resource "alicloud_ram_role_policy_attachment" "ram_role_policy_attachment_fc_acr" {
  role_name   = alicloud_ram_role.ram_role_fc.name
  policy_name = "AliyunContainerRegistryReadOnlyAccess"
  policy_type = "System"
}
