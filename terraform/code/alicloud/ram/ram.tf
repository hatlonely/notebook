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
  }
}

variable "name" {
  type    = string
  default = "tf-test-ram"
}

## 创建一个 RAM 用户

# 1. 创建一个 RAM 用户
resource "alicloud_ram_user" "ram_user" {
  name  = "${var.name}-user"
  force = true
}

# 2. 为用户创建一个 AccessKey
resource "alicloud_ram_access_key" "ram_access_key" {
  user_name = alicloud_ram_user.ram_user.name
}

# 3. 给用户添加 AliyunECSFullAccess 策略
resource "alicloud_ram_user_policy_attachment" "ram_user_policy_attachment_aliyun_ecs_full_access" {
  policy_name = "AliyunECSFullAccess"
  policy_type = "System"
  user_name   = alicloud_ram_user.ram_user.name
}


# 4. 添加自定义策略
resource "alicloud_ram_policy" "ram_policy_custom_oss" {
  policy_name     = "${var.name}-custom-policy"
  description     = "${var.name} custom policy"
  force           = true
  policy_document = <<EOF
  {
    "Version": "1",
    "Statement": [
      {
        "Action": [
          "oss:List*",
          "oss:Get*"
        ],
        "Resource": "*",
        "Effect": "Allow"
      }
    ]
  }
  EOF
}

# 5. 给用户添加 OSS 自定义策略
resource "alicloud_ram_user_policy_attachment" "ram_user_policy_attachment_custom_oss" {
  policy_name = alicloud_ram_policy.ram_policy_custom_oss.name
  policy_type = "Custom"
  user_name   = alicloud_ram_user.ram_user.name
}

# 6. 生成一个秘钥文件
resource "local_file" "file_secret" {
  filename = "${var.name}-secret.yaml"
  content  = <<EOF
credential:
  tf-test-user:
    accessKeyId: ${alicloud_ram_access_key.ram_access_key.id}
    accessKeySecret: ${alicloud_ram_access_key.ram_access_key.secret}
EOF
}

## 创建一个 RAM 角色

# 1. 创建一个 RAM 角色，允许 ECS 服务扮演该角色
resource "alicloud_ram_role" "ram_role_service_ecs" {
  name     = "${var.name}-role"
  force    = true
  document = <<EOF
  {
    "Version": "1",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "ecs.aliyuncs.com"
          ]
        }
      }
    ]
  }
  EOF
}

# 2. 给角色添加 AliyunECSFullAccess 策略
resource "alicloud_ram_role_policy_attachment" "ram_role_policy_attachment_aliyun_ecs_full_access" {
  policy_name = "AliyunECSFullAccess"
  policy_type = "System"
  role_name   = alicloud_ram_role.ram_role_service_ecs.name
}
