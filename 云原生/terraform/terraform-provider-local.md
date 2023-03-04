# terraform local provider

local provider 提供本地文件资源

- `filename`: 文件名
- `content`: 文件内容
- `directory_permission`: 文件夹权限，默认 `0777`
- `file_permission`: 文件权限，默认 `0777`

## 参考代码

```terraform
provider "local" {}

resource "local_file" "helloworld" {
  filename             = "${path.module}/helloworld.txt"
  content              = "hello world"
  directory_permission = "0755"
  file_permission      = "0644"
}

resource "local_file" "helloworld-base64" {
  filename             = "${path.module}/helloworld-base64.txt"
  content_base64       = base64encode("hello world")
  directory_permission = "0755"
  file_permission      = "0644"
}

resource "local_file" "multiline" {
  filename = "${path.module}/multiline.txt"
  content  = <<EOT
hello world
hello world
EOT
}

resource "local_sensitive_file" "sensitive" {
  filename             = "${path.module}/sensitive.txt"
  content              = "hello world"
  directory_permission = "0755"
  file_permission      = "0644"
}
```

## 参考链接

- [api 文档](https://registry.terraform.io/providers/hashicorp/local/latest/docs)
- [完整代码](code/local/main.tf)
