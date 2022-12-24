# 资源编排工具 Terraform 简介

Terraform 是一个 hashicorp 开源的资源编排工具（infrastructure as code），可以用来创建，修改和删除云资源，支持各种主流的云厂商，
包括 Aws，阿里云，Azure，GCP 等。

Terraform 使用 [HCL](https://github.com/hashicorp/hcl/blob/main/hclsyntax/spec.md) 语法来描述云资源。并且提供命令行交互工具。

## Terraform 安装

### Mac 安装

```shell
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew update
brew upgrade hashicorp/tap/terraform
terraform -help
```

## Terraform 语法

关于 hcl 的介绍可以参考 [hashicorp-hcl-简介](https://github.com/hatlonely/notebook/blob/master/golang/%E4%B8%89%E6%88%BF%E5%BA%93/hashicorp-hcl/hashicorp-hcl-%E9%85%8D%E7%BD%AE%E7%AE%80%E4%BB%8B.md)

- `provider`: 云资源
- `resource`:
  - 

## 阿里云实践

通过如下步骤在阿里云创建一台 ECS

1. 编写资源描述文件 `ecs.tf`

```hcl
provider "alicloud" {}

resource "alicloud_vpc" "vpc" {
  vpc_name   = "tf_test_foo"
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_vswitch" "vsw" {
  vpc_id     = alicloud_vpc.vpc.id
  cidr_block = "172.16.0.0/21"
  zone_id    = "cn-beijing-b"
}

resource "alicloud_security_group" "default" {
  name   = "default"
  vpc_id = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "instance" {
  # cn-beijing
  availability_zone = "cn-beijing-b"
  security_groups   = alicloud_security_group.default.*.id

  # series III
  instance_type              = "ecs.n2.small"
  system_disk_category       = "cloud_efficiency"
  image_id                   = "ubuntu_18_04_64_20G_alibase_20190624.vhd"
  instance_name              = "test_foo"
  vswitch_id                 = alicloud_vswitch.vsw.id
  internet_max_bandwidth_out = 10
}
```

2. 初始化项目，获取依赖模块

```shell
terraform init
```

执行之后会生成 `.terraform.lock.hcl` 文件，该文件保存了依赖模块的版本信息

3. 设置阿里云凭证

```shell
export ALICLOUD_ACCESS_KEY="LTAIUrZCw3********"
export ALICLOUD_SECRET_KEY="zfwwWAMWIAiooj14GQ2*************"
export ALICLOUD_REGION="cn-beijing"
```

关于阿里云凭证的获取，可参考[创建RAM用户](https://help.aliyun.com/document_detail/93720.html)

4. 查看资源操作计划

```shell
terraform plan
```

5. 执行资源操作

```shell
terraform apply
```

执行之后会生成 `terraform.tfstate` 保存了创建的资源信息

6. 查看资源

```shell
terraform show
```

7. 释放资源

```shell
terraform destroy
```

## 参考链接

- Terraform 官网: <https://www.terraform.io>
- Terraform 官网教程: <https://developer.hashicorp.com/terraform/tutorials>
- Terraform 官网文档: <https://developer.hashicorp.com/terraform/docs>
- 阿里云文档-什么是Terraform: <https://help.aliyun.com/document_detail/95820.html>
- Terraform alicloud provider: <https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance>
- Terraform 阿里云资源索引: <https://help.aliyun.com/document_detail/335111.html>
- hcl 简介: <https://github.com/hatlonely/notebook/blob/master/golang/%E4%B8%89%E6%88%BF%E5%BA%93/hashicorp-hcl/hashicorp-hcl-%E9%85%8D%E7%BD%AE%E7%AE%80%E4%BB%8B.md>
