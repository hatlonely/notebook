FROM ubuntu:22.04

RUN apt update -y && apt install -y wget git python3 python3-venv
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
  dpkg -i cuda-keyring_1.1-1_all.deb && \
  apt update -y && \
  apt install -y cuda
RUN apt install wget git python3 python3-venv libgl1 libglib2.0-0
RUN curl https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/webui.sh -O webui.sh
RUN bash webui.sh -f
