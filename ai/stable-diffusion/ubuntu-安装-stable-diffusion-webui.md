# ubuntu 安装 stable diffision webui

```sh
sudo apt update -y && sudo apt install -y wget git python3 python3-venv

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
  dpkg -i cuda-keyring_1.1-1_all.deb && \
  apt update -y && \
  apt install -y cuda

sudo apt install wget git python3 python3-venv libgl1 libglib2.0-0

curl https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/webui.sh -O webui.sh
webui.sh -f
```
