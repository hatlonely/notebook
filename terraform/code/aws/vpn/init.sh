#!/usr/bin/env bash

# 更新系统
sudo apt update && sudo apt upgrade && sudo apt autoremove

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
    "server_port": 12674,
    "password": "abc123",
    "timeout": 300,
    "method": "aes-256-gcm",
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
