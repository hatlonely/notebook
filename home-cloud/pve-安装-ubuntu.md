# pve 安装 ubuntu

1. 上传镜像 iso 到 pve 服务器。选择【节点】->【local】->【ISO 镜像】-【上传】，上传镜像 iso 文件。
2. 创建虚拟机。选择【节点】->【右键】->【创建虚拟机】
    - 设置名称: ubuntu
    - SCSI 控制器，选择【VirtIO SCSI】
3. 安装 ubuntu 24
    - 选择虚拟机，点击【开始】->【控制台】
    - 磁盘选项，取消 【Set up this disk as an LVM group】
    - 安装 ssh 服务，选择【Install OpenSSH server】
4. 固定 IP 网卡，编辑 /etc/netplan/50-cloud-init.yaml，之后应用网络配置即可 `sudo netplan apply`

```yaml
network:
version: 2
renderer: networkd
ethernets:
    ens18:
    dhcp4: no
    addresses:
        - 192.168.0.20/24
    routes:
        - to: default
        via: 192.168.0.1
    nameservers:
        addresses:
        - 8.8.8.8
        - 8.8.4.4
```
