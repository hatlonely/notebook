# terraform alicloud ots

## 创建一个 ots 实例

```terraform
terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.209.0"
    }
  }
}

provider "alicloud" {
  region = "cn-beijing"
  alias  = "cn-beijing"
}


resource "alicloud_ots_instance" "tf-test-ots-instance" {
  name = "tf-test"
}

output "connection" {
  value = {
    endpoint : "https://${alicloud_ots_instance.tf-test-ots-instance.name}.cn-beijing.ots.aliyuncs.com"
    endpointVpc : "https://${alicloud_ots_instance.tf-test-ots-instance.name}.cn-beijing.vpc.tablestore.aliyuncs.com"
  }
}
```

## 参考链接

- [terraform-alicloud-ots](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ots_instance)
- [源码地址](../code/alicloud/ots/ots.tf)
