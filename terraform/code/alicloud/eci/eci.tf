terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.209.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
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

# 创建 VPC
resource "alicloud_vpc" "tf-test-vpc" {
  vpc_name   = "tf-test-vpc"
  cidr_block = "172.16.0.0/16"
}

# 创建 VSwitch
resource "alicloud_vswitch" "tf-test-vswitch" {
  zone_id    = "cn-beijing-i"
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

resource "alicloud_eci_container_group" "tf-test-eci-container-group" {
  container_group_name = "tf-test-eci-container-group"
  security_group_id    = alicloud_security_group.tf-test-security-group.id
  vswitch_id           = alicloud_vswitch.tf-test-vswitch.id
  restart_policy       = "OnFailure"
  cpu                  = 1
  memory               = 1
  auto_create_eip      = true
  eip_bandwidth        = 5

  containers {
    image             = "registry-vpc.cn-beijing.aliyuncs.com/eci_open/nginx"
    name              = "nginx"
    image_pull_policy = "IfNotPresent"
    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}
