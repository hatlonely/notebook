provider "random" {}

resource "random_id" "id" {
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