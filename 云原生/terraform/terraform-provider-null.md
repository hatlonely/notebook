# terraform provider null

null 是 terraform 的空资源，空资源可以和 `provisioner` 结合起来执行一些任务，比如运行 `local-exec` 和 `remote-exec`

## 参考代码

```terraform
provider "null" {}

resource "null_resource" "echo" {
  triggers = {
    hello = "world"
  }

  provisioner "local-exec" {
    command = <<EOF
echo "hello world"
EOF
  }
}

resource "null_resource" "py" {
  provisioner "local-exec" {
    interpreter = ["python3", "-c"]
    command     = <<EOF
print("hello world")
EOF
  }
}
```

## 参考链接

- [api 参考](https://registry.terraform.io/providers/hashicorp/null/latest/docs)
- [local-exec 参考](https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec)
- [完整代码](code/null/main.tf)
