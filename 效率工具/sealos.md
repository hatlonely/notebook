# sealos

## 主机互连

1. 登录所有主机，切换到 root 用户，设置密码

```
sudo su root
passwd
```

2. 设置 sshd_config，配置允许 root 用户密码登录 `vi /etc/ssh/sshd_config`

```
PermitRootLogin yes
```

3. 重启 ssh 服务，生效配置

```shell
service ssh restart
```

## 安装 sealos 工具

方案一: 直接通过网络下载，github 的网络比较慢

```shell
wget  https://github.com/labring/sealos/releases/download/v4.1.4/sealos_4.1.4_linux_amd64.tar.gz  && \
    tar -zxvf sealos_4.1.4_linux_amd64.tar.gz sealos &&  chmod +x sealos && mv sealos /usr/bin
```

方案二：通过本地下载的 nas 安装

```shell
apt apt update
apt install -y nfs-common

mkdir -p /data
mount 192.168.0.101:/nfs/data /data

tar -zxvf /data/sealos_4.1.4_linux_amd64.tar.gz sealos &&  chmod +x sealos && mv sealos /usr/bin
```

## 安装 k8s

```shell
sealos run labring/kubernetes:v1.25.0 labring/helm:v3.8.2 labring/calico:v3.24.1 \
     --masters 192.168.0.10,192.168.0.11,192.168.64.12 \
     --nodes 192.168.0.20,192.168.0.21 -p [your-ssh-passwd]
```