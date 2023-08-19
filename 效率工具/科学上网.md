# 科学上网

## 账号注册

1. 进入[网站](https://my.vultr.com/)注册
2. **Account** -> **Api** 获取 api key，用于下面的 terraform 脚本

## 创建机器

创建 `vpn.tf`

```terraform
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
```

创建 `init.sh`

```shell
#!/usr/bin/env bash

function InstallPython() {
  apt install -y python
}

function InstallBBR() {
  wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh && chmod +x bbr.sh && ./bbr.sh
}

function InstallShadowsocks() {
  wget --no-check-certificate -O shadowsocks.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks.sh && \
  chmod +x shadowsocks.sh && \
  ./shadowsocks.sh
}

# 防火墙里面默认有些规则，把这些规则清理掉
function ClearFirewall() {
  nft flush ruleset
}

function main() {
  ClearFirewall
  InstallPython
  InstallBBR
  InstallShadowsocks
}

main
```

## 搭建服务

根据输出登录机器

```shell
ssh root@64.237.50.148
```

执行脚本安装

```shell
bash init.sh
```

## 检查网络

登录机器执行，检查本地服务是否启动

```shell
telnet <server-ip> <port>
```

本机执行，检查网络是否通

```shell
telnet <server-ip> <port>
```

正常会有类似输出

```shell
Trying 146.12.12.19...
Connected to 146.12.12.19.vultrusercontent.com.
Escape character is '^]'.
```

## 多用户配置

```shell
cat > /etc/shadowsocks.json <<EOF
{
    "server":"0.0.0.0",
    "local_address":"127.0.0.1",
    "local_port":1080,
    "timeout":300,
    "method":"aes-256-gcm",
    "fast_open":false,
    "port_password":{
         "12681":"xxx",
         "12682":"xxx",
         "12684":"xxx"
    }
}
EOF

/etc/init.d/shadowsocks restart
```

## 命令行中使用

```shell
export HTTP_PROXY=http://127.0.0.1:7080
export HTTPS_PROXY=http://127.0.0.1:7080
```

大部分命令行工具都支持这种方式。其中端口号（7080）在 shadowsocks 客户端中配置

## 客户端

win: <https://github.com/shadowsocks/shadowsocks-windows/releases>
mac: <https://github.com/qinyuhang/ShadowsocksX-NG-R/releases>
android: <https://github.com/shadowsocks/shadowsocks-android/releases>

## 参考链接

- [科学上网：Vultr VPS 搭建 by Jackme](https://jackmezone.medium.com/%E7%A7%91%E5%AD%A6%E4%B8%8A%E7%BD%91-vultr-vps-%E6%90%AD%E5%BB%BA-shadowsocks-ss-%E6%95%99%E7%A8%8B-%E6%96%B0%E6%89%8B%E5%90%91-968613081aae)
- [vultr 防火墙](https://www.vultr.com/docs/firewall-quickstart-for-vultr-cloud-servers/)
