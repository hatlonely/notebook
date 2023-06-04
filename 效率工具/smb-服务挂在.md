# smb 服务挂载

## ubuntu

```shell
apt install -y cifs-utils

mkdir -p /root/nas3
mount -t cifs //192.168.0.103/hatlonely_nas3 /root/nas3 -o username=hatlonely,password=keaiduo1,iocharset=utf8
mount -t cifs //192.168.0.101/k8s /root/k8s -o username=hatlonely,password=keaiduo1,iocharset=utf8
```
