terraform {
  cloud {
    organization = "hatlonely"

    workspaces {
      name = "vultr-shadowsocks"
    }
  }

  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.15.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

variable "os" {
  type = string
  default = "win"
}

provider "vultr" {}

# 创建防火墙
resource "vultr_firewall_group" "firewall_group" {
  description = "shadowsocks firewall group"
}

resource "vultr_firewall_rule" "firewall_rule_ssh" {
  firewall_group_id = vultr_firewall_group.firewall_group.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = "22"
  notes             = "ssh"
}

resource "vultr_firewall_rule" "firewall_rule_ss" {
  firewall_group_id = vultr_firewall_group.firewall_group.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = "${random_integer.ss_port.result}"
  notes             = "shadowsocks"
}

# 获取操作系统镜像
data vultr_os "ubuntu_22" {
  filter {
    name   = "name"
    values = ["Ubuntu 22.04 LTS x64"]
  }
}

# 获取地区
data vultr_region "us" {
  filter {
    name   = "city"
    values = ["Silicon Valley"]
  }
}

# 生成登录秘钥对
resource "tls_private_key" "tls_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 保存秘钥
resource "local_file" "file_id_rsa" {
  filename = "id_rsa"
  content  = tls_private_key.tls_private_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "file_id_rsa_pub" {
  filename = "id_rsa.pub"
  content  = tls_private_key.tls_private_key.public_key_openssh
}

# 创建秘钥对
resource "vultr_ssh_key" "vultr_ssh_key" {
  name   = "ss-key"
  ssh_key = tls_private_key.tls_private_key.public_key_openssh
}

# 生成密码
resource "random_password" "ss_password" {
  length  = 16
  special = false
}

# 随机端口
resource "random_integer" "ss_port" {
  max = 60000
  min = 20000
}

# 创建启动脚本
resource "vultr_startup_script" "startup_script_shadowsocks_init" {
  name   = "init_shadowsocks_ubuntu_22"
  script = base64encode(<<EOT
#!/usr/bin/env bash

# 更新系统
sudo apt update -y

# 安装工具链
sudo apt install -y --no-install-recommends build-essential autoconf libtool \
  libssl-dev gawk debhelper init-system-helpers pkg-config asciidoc \
  xmlto apg libpcre3-dev zlib1g-dev libev-dev libudns-dev libsodium-dev \
  libmbedtls-dev libc-ares-dev automake

# 编译安装
sudo apt install -y git
git clone https://github.com/shadowsocks/shadowsocks-libev.git
cd shadowsocks-libev
git submodule update --init
./autogen.sh && ./configure --disable-documentation && make
sudo make install

# 配置
sudo mkdir -p /etc/shadowsocks-libev
sudo bash -c 'cat > /etc/shadowsocks-libev/config.json <<EOF
{
    "server": "0.0.0.0",
    "server_port": ${random_integer.ss_port.result},
    "password": "${random_password.ss_password.result}",
    "timeout": 300,
    "method": "${var.os == "win" ? "aes-256-gcm" : "aes-256-ctr"}",
    "fast_open": false,
    "workers": 1,
    "prefer_ipv6": false
}
EOF
'

# 配置服务
sudo bash -c 'cat > /etc/systemd/system/shadowsocks-libev.service <<EOF
[Unit]
Description=Shadowsocks-libev Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ss-server -c /etc/shadowsocks-libev/config.json -u
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF
'

# 启动服务
sudo systemctl start shadowsocks-libev
sudo systemctl enable shadowsocks-libev

# 关闭防火墙
sudo ufw disable
EOT
  )
}

# 创建实例
resource "vultr_instance" "instance" {
  plan              = "vc2-1c-1gb"
  region            = data.vultr_region.us.id
  os_id             = data.vultr_os.ubuntu_22.id
  script_id         = vultr_startup_script.startup_script_shadowsocks_init.id
  backups           = "disabled"
  hostname          = "shadowsocks"
  ssh_key_ids       = [vultr_ssh_key.vultr_ssh_key.id]
  firewall_group_id = vultr_firewall_group.firewall_group.id
}

output "connect" {
  value = <<EOT
conn: ssh -i id_rsa root@${vultr_instance.instance.main_ip}
host: ${vultr_instance.instance.main_ip}
port: ${random_integer.ss_port.result}
password: ${nonsensitive(random_password.ss_password.result)}
EOT
}
