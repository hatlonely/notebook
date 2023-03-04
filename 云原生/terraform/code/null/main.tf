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
