terraform {
  required_providers {
    myfile = {
      source = "hatlonely.com/test/myfile"
      version = "0.0.1"
    }
  }
}

provider "myfile" {
  key1 = "val1"
  key2 = 2
}

resource "myfile" "myfile" {
  name = "1.txt"
  content = "hello world"
}

output "myfile" {
  value = myfile.myfile
}