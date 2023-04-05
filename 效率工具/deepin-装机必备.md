# deepin 装机必备

## deepin 安装

## vpn

参考链接: <https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients-zh.md#linux>

【设置】->【网络】->【VPN】->【+】

- VPN 类型: L2TP
- VPN
  - 网关: Server IP
  - 用户名: Username
  - 密码: Password
- VPN IPsec
  - 预共享: IPsec PSK
  - 秘钥交换协议: aes128-sha1-modp2048
  - 安全封装协议: aes128-sha1

## zsh

```shell
sudo apt install -y zsh
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s /bin/zsh
```

## git

```shell
sudo apt install git
git config --global user.email hatlonely@gmail.com
git config --global user.name hatlonely

ssh-keygen -t rsa -b 4096 -C "hatlonely@foxmail.com"
cat ~/.ssh/id_rsa.pub
```

[github.com](https://github.com/settings/keys)->【New SSH Key】添加 ssh key

## 