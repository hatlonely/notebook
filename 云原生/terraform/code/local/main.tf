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
