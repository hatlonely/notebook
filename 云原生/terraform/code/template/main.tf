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
