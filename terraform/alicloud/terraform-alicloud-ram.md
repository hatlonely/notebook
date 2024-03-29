# terraform alicloud ram

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
  }
}
```

## 创建一个 RAM 用户

```terraform
# 1. 创建一个 RAM 用户
resource "alicloud_ram_user" "tf-test-user" {
  name  = "tf-test-user"
  force = true
}

# 2. 为用户创建一个 AccessKey
resource "alicloud_ram_access_key" "tf-test-user-ak" {
  user_name   = alicloud_ram_user.tf-test-user.name
  secret_file = "tf-test-user-ak.secret"
}

# 3. 给用户添加 AliyunECSFullAccess 策略
resource "alicloud_ram_user_policy_attachment" "tf-test-user-policy-aliyun-ecs-full-access" {
  policy_name = "AliyunECSFullAccess"
  policy_type = "System"
  user_name   = alicloud_ram_user.tf-test-user.name
}


# 4. 添加自定义策略
resource "alicloud_ram_policy" "tf-test-policy" {
  name        = "tf-test-policy"
  description = "tf-test-policy"
  force       = true
  document    = <<EOF
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
resource "alicloud_ram_user_policy_attachment" "tf-test-user-policy-oss-custom" {
  policy_name = alicloud_ram_policy.tf-test-policy.name
  policy_type = "Custom"
  user_name   = alicloud_ram_user.tf-test-user.name
}

# 6. 生成一个秘钥文件
resource "local_file" "secret" {
  filename = "secret.yaml"
  content  = <<EOF
credential:
  tf-test-user:
    accessKeyId: ${alicloud_ram_access_key.tf-test-user-ak.id}
    accessKeySecret: ${alicloud_ram_access_key.tf-test-user-ak.secret}
EOF
}
```

## 创建一个 RAM 角色

```terraform
# 1. 创建一个 RAM 角色，允许 ECS 服务扮演该角色
resource "alicloud_ram_role" "tf-test-role" {
  name     = "tf-test-role"
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
resource "alicloud_ram_role_policy_attachment" "tf-test-role-policy-aliyun-ecs-full-access" {
  policy_name = "AliyunECSFullAccess"
  policy_type = "System"
  role_name   = alicloud_ram_role.tf-test-role.name
}
```

## 参考链接

- [terraform alicloud ram](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_user)
- [源码地址](../code/alicloud/ram/ram.tf)