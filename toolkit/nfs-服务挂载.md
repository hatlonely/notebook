# nfs 服务挂载

## ubuntu

```shell
apt apt update -y
apt install -y nfs-common

mkdir -p $HOME/share
mount 192.168.0.102:/nfs/share $HOME/share
```

## mac

```shell
mkdir -p $HOME/share

sudo mount -t nfs -o hard,nfsvers=3 192.168.0.102:/nfs/data $HOME/nfs
```
