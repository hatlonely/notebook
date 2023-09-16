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

## apt

```shell
apt install tree
```

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

## 字体安装


1. 从 <https://fonts.google.com> 下载字体
2. 解压字体文件到 `/usr/share/fonts/truetype` 即可

```shell
#!/usr/bin/env bash

for i in $(ls fonts); do
  sudo unzip -o -d "/usr/share/fonts/truetype/${i%.*}" "fonts/$i"
done

fc-cache -f -v
```

## go 环境安装

1. 从 go 官网下载安装包 <https://go.dev/dl/>
2. 安装到 `/usr/local` 目录下
## albert

参考链接：<https://albertlauncher.github.io/installing/>

1. 查看操作系统: `cat /etc/debian_version`
2. 下载对应安装包: <https://software.opensuse.org/download.html?project=home:manuelschneid3r&package=albert>
3. 安装 `CopyQ`

```shell
sudo add-apt-repository ppa:hluk/copyq
sudo apt update
sudo apt install copyq

whereis albert
sudo mkdir -p /usr/share/albert/external
sudo curl "https://gist.githubusercontent.com/BarbUk/d443d09c6649b4b1225c1d6b96d9c7fd/raw/f300b1b88c2088ea0b4f3822b2d2a073e878a380/copyq" -o /usr/share/albert/external/copyq
sudo chmod +x /usr/share/albert/external/copyq
```

## mac 快捷键

参考链接: <https://github.com/rbreaves/kinto>

```shell
/bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/rbreaves/kinto/HEAD/install/linux.sh || curl -fsSL https://raw.githubusercontent.com/rbreaves/kinto/HEAD/install/linux.sh)"
pip3 install vte
sudo apt install -y vte-2.91
```

## 参考链接

- alfred 替代方案: <https://medium.com/curiouscaloo/macos-to-ubuntu-part1-alfred-replacement-7864b4d26397>
- albert: <https://albertlauncher.github.io/using/>
- albert github: <https://github.com/albertlauncher/albert>
- copyq: <https://github.com/hluk/CopyQ>
