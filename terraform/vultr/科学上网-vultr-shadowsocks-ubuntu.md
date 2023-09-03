# 科学上网 vultr shadowsocks ubuntu

vultr 的网速比较快（最便宜机器），家庭宽带测试基本可以达到 20MB/s（偶尔能到 30MB/s）而且相对稳定，费用上 6$/月，还算划算，流量
1TB 足够

1. 登录 <https://my.vultr.com/> 账号
2. Account -> API 获取 API key
3. 将 API key 导入到环境变量中 `export VULTR_API_KEY="xxx"`
4. 安装 terraform，<https://developer.hashicorp.com/terraform/downloads>
5. 执行 `terraform apply` 一键安装

```terraform
terraform {
  cloud {
    organization = "hatlonely"

    workspaces {
      tags = ["vultr-vpn-shadowsocks-ubuntu"]
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

variable "encryption_method" {
  type    = list(string)
  default = ["aes-256-gcm", "aes-256-ctr", "chacha20-ietf-poly1305"]
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
  for_each = {
    for idx, method in var.encryption_method : idx => method
  }
  firewall_group_id = vultr_firewall_group.firewall_group.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = random_integer.ss_port.result + each.key
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
  filename        = "id_rsa"
  content         = tls_private_key.tls_private_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "file_id_rsa_pub" {
  filename = "id_rsa.pub"
  content  = tls_private_key.tls_private_key.public_key_openssh
}

# 创建秘钥对
resource "vultr_ssh_key" "vultr_ssh_key" {
  name    = "ss-key"
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

# 安装 shadowsocks-libev
# https://github.com/shadowsocks/shadowsocks-libev
sudo apt update -y
sudo apt install -y shadowsocks-libev
# 关闭默认服务
sudo systemctl disable shadowsocks-libev
sudo systemctl stop shadowsocks-libev

sudo mkdir -p /etc/shadowsocks-libev
ss_port=${random_integer.ss_port.result}
for encryption_method in ${join(" ", var.encryption_method)}; do
  # 配置文件
  sudo bash -c "cat > /etc/shadowsocks-libev/config.$${encryption_method}.json <<EOF
{
    \"server\": \"0.0.0.0\",
    \"server_port\": $${ss_port},
    \"password\": \"${random_password.ss_password.result}\",
    \"timeout\": 300,
    \"method\": \"$${encryption_method}\",
    \"fast_open\": true,
    \"workers\": 1,
    \"prefer_ipv6\": false
}
EOF
"
  ((ss_port++))

  # 配置服务
  sudo bash -c "cat > /etc/systemd/system/shadowsocks-libev-$${encryption_method}.service <<EOF
[Unit]
Description=Shadowsocks-libev Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/ss-server -c /etc/shadowsocks-libev/config.$${encryption_method}.json -u
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF
"

  # 启动服务
  sudo systemctl start shadowsocks-libev-$${encryption_method}
  sudo systemctl enable shadowsocks-libev-$${encryption_method}

done

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

output "ssh_connection" {
  value = chomp(<<EOF
ssh -i id_rsa root@${vultr_instance.instance.main_ip}
EOF
  )
}

output "ss_connection" {
  value = chomp(join("\n", [
    for idx, method in var.encryption_method : <<EOF
host: ${vultr_instance.instance.main_ip}
port: ${random_integer.ss_port.result + idx}
password: ${nonsensitive(random_password.ss_password.result)}
method: ${method}
EOF
  ]))
}
```

# 参考链接

- [vultra 官网](https://my.vultr.com/)
- [terraform vultr 资源](https://registry.terraform.io/providers/vultr/vultr/latest/docs/resources/instance)
- [vultr 服务连接问题排查](https://www.vultr.com/docs/troubleshooting-vultr-server-connections/)
