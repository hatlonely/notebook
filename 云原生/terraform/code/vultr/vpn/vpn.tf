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

resource "vultr_firewall_group" "firewall_group" {
  description = "base firewall"
}

resource "vultr_firewall_rule" "firewall_rule_ssh" {
  firewall_group_id = vultr_firewall_group.firewall_group.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = "22"
  notes             = "shadowsocks"
}

resource "vultr_firewall_rule" "firewall_rule_tcp" {
  firewall_group_id = vultr_firewall_group.firewall_group.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = "14053"
  notes             = "shadowsocks"
}

resource "vultr_instance" "instance" {
  plan              = "vc2-1c-1gb"
  region            = "ewr"
  os_id             = 477
  backups           = "disabled"
  hostname          = "vpn-hl"
  firewall_group_id = vultr_firewall_group.firewall_group.id

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
