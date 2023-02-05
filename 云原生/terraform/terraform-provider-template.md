# terraform provider template

template 提供模板渲染能力，`data "template_file"` 渲染单个文件，`resource template_dir` 渲染整个目录

## 参考代码

```terraform
provider "template" {}

data "template_file" "test_tpl" {
  template = file("tpl/test.tpl")
  vars     = {
    key1 = "val1"
    key2 = "val2"
    key3 = jsonencode({
      key4 = "val4"
      key4 = [1, 2, 3]
    })
  }
}

output "test_tpl" {
  value = data.template_file.test_tpl.rendered
}

resource "template_dir" "tpls" {
  destination_dir = "${path.cwd}/cfg"
  source_dir      = "${path.module}/tpl"
  vars            = {
    key1 = "val1"
    key2 = "val2"
    key3 = jsonencode({
      key4 = "val4"
      key4 = [1, 2, 3]
    })
  }
}
```

## 参考链接

- [api 文档](https://registry.terraform.io/providers/hashicorp/template/latest/docs)
- [完整代码](code/template/main.tf)
