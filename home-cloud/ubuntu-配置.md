# ubuntu 配置

## 显卡驱动

```shell
wget -qO - https://repositories.intel.com/graphics/intel-graphics.key | apt-key add -
apt-add-repository 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main'
apt update
apt install -y intel-media-va-driver-non-free
apt install -y vainfo
```
