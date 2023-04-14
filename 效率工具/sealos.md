# sealos

## 安装依赖

```shell
apt apt update -y
apt install -y nfs-common
apt install -y socat
```

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
wget https://github.com/labring/sealos/releases/download/v4.1.7/sealos_4.1.7_linux_amd64.tar.gz && \
  tar -zxvf sealos_4.1.7_linux_amd64.tar.gz sealos &&  chmod +x sealos && mv sealos /usr/bin
```

方案二：通过本地下载的 nas 安装

```shell
mkdir -p /data
mount 192.168.0.101:/nfs/data /data

tar -zxvf /data/sealos_4.1.7_linux_amd64.tar.gz sealos &&  chmod +x sealos && mv sealos /usr/bin
```

## 安装 k8s

1. 生成集群文件

```shell
sealos gen labring/kubernetes:v1.24.0 labring/calico:v3.22.1 \
     --masters 192.168.0.10,192.168.0.11,192.168.0.12 \
     --nodes 192.168.0.20 -p [passowrd] > Clusterfile
```

2. 执行安装

```shell
sealos apply -f Clusterfile
```


常见命令

```shell
sealos reset
sealos delete masters 192.168.64.12
```

## 参考链接

- sealos 项目: <https://github.com/labring/sealos>
- 中文教程: <https://sealos.io/zh-Hans/docs/getting-started/customize-cluster>
