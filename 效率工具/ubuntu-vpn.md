# ubuntu vpn

[IPsec VPN 服务器一键安装脚本](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/README-zh.md)
[Docker 上的 IPsec VPN 服务器](https://github.com/hwdsl2/docker-ipsec-vpn-server/blob/master/README-zh.md)
[OpenVPN 服务器一键安装脚本](https://github.com/hwdsl2/openvpn-install/blob/master/README-zh.md)
[](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-ikev2-vpn-server-with-strongswan-on-ubuntu-20-04)
[](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/ikev2-howto-zh.md#%E9%85%8D%E7%BD%AE-ikev2-vpn-%E5%AE%A2%E6%88%B7%E7%AB%AF)


```shell
# 服务器修改安全组，入站规则。所有流量接受所有IPv4请求。所有流量接受所有IPv6请求。
sudo apt update && sudo apt upgrade -y && \
sudo apt install -y lrzsz && \
wget https://get.vpnsetup.net -O vpn.sh && sudo sh vpn.sh

# 命令行
sudo apt install -y network-manager-l2tp-gnome network-manager-strongswan
# 新增/etc/NetworkManager/system-connections下的文件
nmcli c show
nmcli c up [vpnname]
nmcli c down [vpnname]


sudo yum -y update && \
sudo yum install -y lrzsz && \
wget https://get.vpnsetup.net -O vpn.sh && sudo sh vpn.sh
```

1. 安装 nmcli

```shell
sudo apt install -y network-manager-l2tp


sudo nmcli connection add connection.id hl con-name hl type VPN vpn-type l2tp ifname -- connection.autoconnect no ipv4.method auto vpn.data "gateway = 108.61.54.109, ipsec-enabled = yes, ipsec-psk = 0s"$(base64 <<<'[PSK]' | rev | cut -c2- | rev)"=, mru = 1400, mtu = 1400, password-flags = 0, refuse-chap = yes, refuse-mschap = yes, refuse-pap = yes, require-mppe = yes, user = [user]" vpn.secrets password=xxxx

```

2. 在目录 `/etc/NetworkManager/system-connections` 下新建文件 `l2tp.nmconnection`

```shell
cat > l2tp.nmconnection <<EOF
[connection]
id=l2tp
uuid=522439ee-2e82-48b0-b39d-e725c983e793
type=vpn
autoconnect=false
permissions=user:hatlonely:;

[vpn]
gateway=108.61.54.109
ipsec-enabled=yes
ipsec-esp=aes128-sha1
ipsec-ike=aes128-sha1-modp2048
machine-auth-type=psk
password-flags=1
user=vpnuser
user-auth-type=qqWmTKXhgZAM7673
service-type=org.freedesktop.NetworkManager.l2tp

[vpn-secrets]
ipsec-psk=yqjuzsP6xuUh759wXprk

[ipv4]
method=auto

[ipv6]
addr-gen-mode=stable-privacy
method=auto

[proxy]
EOF
sudo mv l2tp.nmconnection /etc/NetworkManager/system-connections/
sudo chown root:root /etc/NetworkManager/system-connections/l2tp.nmconnection
```

3. 

```
sudo nmcli c show
```
