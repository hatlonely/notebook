# terraform 阿里云后端

terraform 支持将资源栈存储在阿里云的对象存储中，并使用表格存储来存储操作锁。

## 部署后端

1. 创建 `main.tf`，创建 oss，ots 资源，并输出 terraform 配置
    ```terraform
    variable "access_key_id" {
      type = string
    }
    
    variable "access_key_secret" {
      type = string
    }
    
    variable "region" {
      type    = string
      default = "cn-hangzhou"
    }
    
    variable "name" {
      type = string
    }
    
    provider "alicloud" {
      access_key = var.access_key_id
      secret_key = var.access_key_secret
      region     = var.region
    }
    
    resource "alicloud_oss_bucket" "oss-tf-state" {
      bucket = "${var.name}-tf-state"
    }
    
    resource "alicloud_ots_instance" "ots-tf-remote" {
      name = "${var.name}-tf-remote"
    }
    
    resource "alicloud_ots_table" "ots-tf-remote-table" {
      instance_name = alicloud_ots_instance.ots-tf-remote.name
      max_version   = 1
      table_name    = "statelock"
      time_to_live  = -1
      primary_key {
        name = "LockID"
        type = "String"
      }
    }
    
    output "description" {
      value = <<EOT
    terraform {
      backend "oss" {
        bucket              = "${alicloud_oss_bucket.oss-tf-state.bucket}"
        prefix              = ""
        key                 = ""
        region              = "${var.region}"
        tablestore_endpoint = "https://${alicloud_ots_instance.ots-tf-remote.name}.${var.region}.ots.aliyuncs.com"
        tablestore_table    = "${alicloud_ots_table.ots-tf-remote-table.table_name}"
      }
    }
    EOT
    }
    ```
2. 创建 `default.tfvars`
    ```terraform
    access_key_id     = "xx"
    access_key_secret = "xx"
    region            = "cn-hangzhou"
    name              = "test"
    ```
3. 部署 terraform 后端
    ```shell
    terraform apply -var-file default.tfvars -auto-approve
    ```

## 测试后端

1. 创建测试代码 `main.tf`
   ```terraform
   variable "key1" {
     type = string
   }
   
   variable "key2" {
     type = number
   }
   
   terraform {
     backend "oss" {
       bucket              = "test-tf-state"
       prefix              = "backend-oss-test"
       region              = "cn-hangzhou"
       tablestore_endpoint = "https://test-tf-remote.cn-hangzhou.ots.aliyuncs.com"
       tablestore_table    = "statelock"
     }
   }
   
   output "out" {
     value = {
       key1 = var.key1
       key2 = var.key2
     }
   }
   ```
2. 配置阿里云访问凭证
   ```shell
   export ALICLOUD_REGION="cn-hangzhou"
   export ALICLOUD_ACCESS_KEY="xxx"
   export ALICLOUD_SECRET_KEY="xxx"
   ```
3. 执行 terraform 命令

```shell
terraform init
terraform plan -var key1=val0 -var key2=0
terraform apply -auto-approve -var key1=val0 -var key2=0

terraform workspace new workspace1
terraform apply -auto-approve -var key1=val1 -var key2=1
```

## 参考链接

- [terraform oss 后端](https://developer.hashicorp.com/terraform/language/settings/backends/oss)
- [backend 部署代码](code/backend-oss/main.tf)
- [backend 测试代码](code/backend-oss-test/main.tf)
