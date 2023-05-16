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

  provisioner "file" {
    source = "~/.ssh/id_rsa.pub"
    destination = "/root/id_rsa.pub"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /root/init.sh > /root/vpnclient.txt",
      "cat /root/id_rsa.pub >> /root/.ssh/authorized_keys"
    ]
  }

  provisioner "local-exec" {
    command = <<EOF
    mkdir vpnclient &&
    scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -r root@${self.main_ip}:/root/vpnclient.p12 vpnclient/ &&
    scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -r root@${self.main_ip}:/root/vpnclient.sswan vpnclient/ &&
    scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -r root@${self.main_ip}:/root/vpnclient.mobileconfig vpnclient/ &&
    scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -r root@${self.main_ip}:/root/vpnclient.txt vpnclient/
EOF
  }
}

output "connect" {
  value = "ssh root@${vultr_instance.instance.main_ip}"
}

output "password" {
  value = nonsensitive(vultr_instance.instance.default_password)
}
