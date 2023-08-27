# 创建安全组，现在安全组只能创建在 VPC 内，但其规则可以是公网或内网
resource "alicloud_security_group" "security-group" {
  name   = "${var.name}-security-group"
  vpc_id = alicloud_vpc.vpc.id
}

# 创建安全组规则，nic_type 必须为 intranet，但其规则对公网同样有效
resource "alicloud_security_group_rule" "security-group-rule" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.security-group.id
  cidr_ip           = "123.113.97.7/32"
}

resource "alicloud_eci_container_group" "eci-container-group" {
  count = var.instance_number

  container_group_name = "tf-test-eci-container-group"
  security_group_id    = alicloud_security_group.security-group.id
  vswitch_id           = alicloud_vswitch.vswitchs[count.index % length(alicloud_vswitch.vswitchs)].id
  restart_policy       = "OnFailure"
  cpu                  = 1
  memory               = 2
  auto_create_eip      = false
  #  sls_enable           = true

  containers {
    image             = "registry-vpc.cn-beijing.aliyuncs.com/eci_open/nginx"
    name              = "nginx"
    image_pull_policy = "IfNotPresent"
    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_vars {
      key   = "aliyun_logs_stdout"
      value = "stdout"
    }

    environment_vars {
      key   = "aliyun_logs_stdout_project"
      value = alicloud_log_project.tf-test-project.name
    }

    environment_vars {
      key   = "aliyun_logs_stdout_machinegroup"
      value = "tf-test-eci-machinegroup"
    }
  }
}
