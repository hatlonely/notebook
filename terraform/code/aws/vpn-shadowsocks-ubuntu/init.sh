#!/usr/bin/env bash

# 网络优化
# https://github.com/shadowsocks/shadowsocks/wiki/Optimizing-Shadowsocks
sudo bash -c "cat > /etc/sysctl.d/local.conf <<EOF
# max open files
fs.file-max = 51200
# max read buffer
net.core.rmem_max = 67108864
# max write buffer
net.core.wmem_max = 67108864
# default read buffer
net.core.rmem_default = 65536
# default write buffer
net.core.wmem_default = 65536
# max processor input queue
net.core.netdev_max_backlog = 4096
# max backlog
net.core.somaxconn = 4096

# resist SYN flood attacks
net.ipv4.tcp_syncookies = 1
# reuse timewait sockets when safe
net.ipv4.tcp_tw_reuse = 1
# turn off fast timewait sockets recycling
net.ipv4.tcp_tw_recycle = 0
# short FIN timeout
net.ipv4.tcp_fin_timeout = 30
# short keepalive time
net.ipv4.tcp_keepalive_time = 1200
# outbound port range
net.ipv4.ip_local_port_range = 10000 65000
# max SYN backlog
net.ipv4.tcp_max_syn_backlog = 4096
# max timewait sockets held by system simultaneously
net.ipv4.tcp_max_tw_buckets = 5000
# turn on TCP Fast Open on both client and server side
net.ipv4.tcp_fastopen = 3
# TCP receive buffer
net.ipv4.tcp_rmem = 4096 87380 67108864
# TCP write buffer
net.ipv4.tcp_wmem = 4096 65536 67108864
# turn on path MTU discovery
net.ipv4.tcp_mtu_probing = 1

# for high-latency network
net.ipv4.tcp_congestion_control = hybla

# for low-latency network, use cubic instead
# net.ipv4.tcp_congestion_control = cubic
EOF
"

sudo sysctl --system

# 安装 shadowsocks-libev
# https://github.com/shadowsocks/shadowsocks-libev
sudo apt update -y
sudo apt install -y shadowsocks-libev
# 关闭默认服务
sudo systemctl disable shadowsocks-libev
sudo systemctl stop shadowsocks-libev

sudo mkdir -p /etc/shadowsocks-libev
ss_port=58598
for encryption_method in aes-256-gcm aes-256-ctr chacha20-ietf-poly1305; do
  # 配置文件
  sudo bash -c "cat > /etc/shadowsocks-libev/config.${encryption_method}.json <<EOF
{
    \"server\": \"0.0.0.0\",
    \"server_port\": ${ss_port},
    \"password\": \"kGav68qTsr5IGYOV\",
    \"timeout\": 300,
    \"method\": \"${encryption_method}\",
    \"fast_open\": false,
    \"workers\": 1,
    \"prefer_ipv6\": false
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
