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

## docker

参考链接：<https://docs.docker.com/engine/install/ubuntu/>

```shell
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
    
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update

#sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo service docker start
```