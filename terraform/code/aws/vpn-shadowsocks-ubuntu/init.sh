#!/usr/bin/env bash

# 安装 shadowsocks-libev
# https://github.com/shadowsocks/shadowsocks-libev
sudo apt update -y
sudo apt install -y shadowsocks-libev

sudo mkdir -p /etc/shadowsocks-libev
ss_port=123
for encryption_method in aes-256-gcm aes-256-ctr; do
  # 配置文件
  sudo bash -c "cat > /etc/shadowsocks-libev/config.${encryption_method}.json <<EOF
{
    "server": "0.0.0.0",
    "server_port": ${ss_port},
    "password": "kMjdyUzXJeVWDZoq",
    "timeout": 300,
    "method": "aes-256-gcm",
    "fast_open": false,
    "workers": 1,
    "prefer_ipv6": false
}
EOF
"
  ((ss_port++))

  # 配置服务
  sudo bash -c "cat > /etc/systemd/system/shadowsocks-libev-${encryption_method}.service <<EOF
[Unit]
Description=Shadowsocks-libev Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/ss-server -c /etc/shadowsocks-libev/config.${encryption_method}.json -u
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF
"

  # 启动服务
  sudo systemctl start shadowsocks-libev-${encryption_method}
  sudo systemctl enable shadowsocks-libev-${encryption_method}

done