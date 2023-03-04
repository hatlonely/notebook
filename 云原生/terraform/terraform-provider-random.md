# terraform provider random

random 提供一些随机资源，用于产生一些随机数。

terraform 中的在多次运行中应该保持幂等，随机函数在每次运行中都会修改属性，在 terraform 中不是一种好的实践。
random provider 提供一种 keepers 机制，当 keepers 发生变化时，随机资源才会重新创建，这样很好地解决了幂等的问题。

- `random_id`: 随机二进制流
- `random_integer`: 随机数
- `random_string`: 随机字符串
- `random_password`: 随机密码，和 `random_string` 区别在于，其结果是敏感信息
- `random_shuffle`: 随机洗牌
- `random_uuid`: 随机 uuid
- `random_pet`: 随机名字

## 参考代码

```terraform
provider "random" {}

resource "random_id" "id" {
  keepers = {
    hello = "world"
  }
  byte_length = 16
}

resource "random_integer" "integer" {
  max = 100
  min = 0
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()[]{}_-=+/?<>"
}

resource "random_pet" "pet" {}

resource "random_shuffle" "shuffle" {
  input        = ["apple", "orange", "banana"]
  result_count = 2
}

resource "random_string" "string" {
  length           = 16
  special          = true
  override_special = "-_"
}

resource "random_uuid" "uuid" {}

output "random" {
  value = {
    random_id      = random_id.id.hex
    random_integer = random_integer.integer.result
    random_pet     = random_pet.pet.id
    random_string  = random_string.string.result
    random_uuid    = random_uuid.uuid.result
  }
}

output "password" {
  sensitive = true
  value     = {
    random_password = random_password.password.result
  }
}
```

## 参考链接

- [api 文档](https://registry.terraform.io/providers/hashicorp/random/latest/docs)
- [完整代码](code/random/main.tf)
