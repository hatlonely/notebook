variable "key1" {
  type = string
}

variable "key2" {
  type = number
}

output "out" {
  value = {
    key1 = var.key1
    key2 = var.key2
  }
}