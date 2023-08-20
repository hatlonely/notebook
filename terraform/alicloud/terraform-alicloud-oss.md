# terraform alicoud oss

OSS 是阿里云提供的对象存储服务，可以存储任意类型的文件，支持 HTTP/HTTPS 协议访问，支持多种 API 调用方式。

定价：https://www.aliyun.com/price/product?#/oss/detail

- 存储费用：120￥/TB/月
- 公网流量费用： 500￥/TB

## 配置依赖

```terraform
terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.209.0"
    }
  }
}
```

## 创建 bucket

```terraform
resource "alicloud_oss_bucket" "tf-hatlonely-test-oss-bucket" {
  bucket = "tf-hatlonely-test-oss-bucket"
  acl    = "private"

  lifecycle_rule {
    id      = "delete after 10 days"
    enabled = true
    prefix  = "logs/"
    expiration {
      days = 10
    }
  }
}
```

## 参考链接

- [alicloud_oss_bucket](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/oss_bucket)
- [源码地址](../code/alicloud/oss/oss.tf)
