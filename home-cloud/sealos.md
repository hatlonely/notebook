# sealos

1. 安装 sealos

```bash
wget https://github.com/labring/sealos/releases/download/v5.0.1/sealos_5.0.1_linux_amd64.tar.gz \
  && tar zxvf sealos_5.0.1_linux_amd64.tar.gz sealos && chmod +x sealos && mv sealos /usr/bin
```

2. 集群安装

```bash
sealos run registry.cn-shanghai.aliyuncs.com/labring/kubernetes:v1.27.7 registry.cn-shanghai.aliyuncs.com/labring/helm:v3.9.4 registry.cn-shanghai.aliyuncs.com/labring/cilium:v1.13.4 \
     --masters 192.168.0.20,192.168.0.21,192.168.0.22 \
     --nodes 192.168.0.23 -i ~/.ssh/id_ed25519
```
