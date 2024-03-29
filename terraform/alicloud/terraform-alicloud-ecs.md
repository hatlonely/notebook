# terraform alicloud ecs

## 配置依赖项

```terraform
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
```

## 创建实例

```terraform
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

output "connection" {
  value = <<EOF
  ssh root@${alicloud_instance.tf-test-ecs.public_ip}
  ${nonsensitive(alicloud_instance.tf-test-ecs.password)}
EOF
}
```

## 参考链接

- [terraform-alicloud-ecs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance)
- [源码地址](../code/alicloud/ecs/ecs.tf)
