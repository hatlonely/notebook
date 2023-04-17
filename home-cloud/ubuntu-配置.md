# ubuntu 配置

## 显卡驱动

```shell
wget -qO - https://repositories.intel.com/graphics/intel-graphics.key | sudo apt-key add -
sudo apt-add-repository 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main'
sudo apt update
sudo apt install -y intel-media-va-driver-non-free
sudo apt install -y vainfo

sudo echo LIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri >> /etc/environment
sudo echo LIBVA_DRIVER_NAME=iHD >> /etc/environment
```
