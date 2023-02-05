# terraform workspace

有时我们希望同样的基础设施在多个环境中部署。即同一份代码，多次部署。

workspace 能很好满足这个需求。每个 workspace 可以使用不同的 var，资源状态会保存在新的完全独立空间中。

## workspace 命令

- `terraform workspace list`: 列出 workspace，terraform 总会运行在一个 workspace 下，默认为 `default`
- `terraform workspace new <workspace>`

## 操作实践

### 编写代码

1. 创建 `main.tf`
    ```terraform
    variable "key1" {
      type = string
    }
    
    variable "key2" {
      type = number
    }
    
    output "out" {
      value = {
        key1 = var.key1
        key2 = var.key2
      }
    }
    ```
2. 初始化 `terraform init`

### 在默认空间中部署

```shell
terraform apply -auto-approve -var key1=val0 -var key2=0
```

### 在新的 workspace 中部署

```shell
terraform workspace new workspace1
terraform apply -auto-approve -var key1=val1 -var key2=1

terraform workspace new workspace2
terraform apply -auto-approve -var-file=workspace2.tfvars
```

### workspace 管理

1. 切换 workspace，并清理资源
   ```shell
   terraform workspace select workspace1
   terraform destroy -var key1=val1 -var key2=1
   
   terraform workspace select workspace2
   terraform destroy -auto-approve -var-file=workspace2.tfvars
   ```
2. 删除 workspace
   ```shell
   terraform workspace select default
   terraform workspace delete workspace1
   terraform workspace delete workspace2
   ```

## 参考链接

- [terraform workspace](https://developer.hashicorp.com/terraform/cli/workspaces)
- [测试代码](code/workspace/main.tf)
