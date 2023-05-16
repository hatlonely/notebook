terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.15.1"
    }
  }
}

provider "vultr" {
  api_key     = "xxx"
  rate_limit  = 100
  retry_limit = 3
}

resource "vultr_instance" "instance" {
  plan     = "vc2-1c-1gb"
  region   = "ewr"
  os_id    = 477
  backups  = "disabled"
  hostname = "vpn-hl"

  connection {
    type     = "ssh"
    user     = "root"
    password = self.default_password
    host     = self.main_ip
  }

  provisioner "file" {
    source      = "init.sh"
    destination = "/root/init.sh"
  }
}

output "connect" {
  value = "ssh root@${vultr_instance.instance.main_ip}"
}

output "password" {
  value = nonsensitive(vultr_instance.instance.default_password)
}
