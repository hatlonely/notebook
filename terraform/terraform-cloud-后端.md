# terraform cloud 后端

## terraform 配置语法

```terraform
terraform {
  cloud {
    organization = "hatlonely"

    workspaces {
      tags = ["networking", "source:cli"]
    }
  }
}
```

- `organization`：组织名称，一般是用户名
- `workspaces`: 对应一份 terraform 代码
    - `name`: workspace 唯一标识，使用后不允许使用 `terraform workspace` 命令
    - `tags`: 标签，和 `name` 两者使用一个即可，tags 允许使用 `terraform workspace` 命令
- `hostname`: terraform cloud 地址，默认是 `app.terraform.io`

## terraform cloud 配置

进入 [terraform cloud 官网](https://app.terraform.io/app/hatlonely/workspaces) 选择对应的 workspace 后，
可以进入 **Setting** 页面进行设置

在 **General** 页面可以选择 Execution Mode (执行模式)

- Remote: 在 terraform cloud 上执行。是默认的执行模式
- Local: 在本地执行，但是使用 terraform cloud 的后端
- Agent: 企业版支持功能，没有试过，可能有单独的稳定的部署机器

## 参考链接

- [Terraform Cloud 官网](https://app.terraform.io/app/hatlonely/workspaces)
- [Terraform Cloud Settings](https://developer.hashicorp.com/terraform/cli/cloud/settings)
