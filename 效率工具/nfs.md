# nfs

## ubuntu

```shell
apt apt update -y
apt install -y nfs-common

mkdir -p $HOME/k8s
mount 192.168.0.101:/nfs/k8s $HOME/k8s
```

## mac

```shell
mkdir -p $HOME/k8s

mount -t nfs -o hard,nfsvers=3 192.168.0.101:/nfs/k8s $HOME/k8s
```