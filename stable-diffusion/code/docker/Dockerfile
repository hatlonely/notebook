FROM ubuntu:22.04

RUN apt-get update && apt install -y wget git python3 python3-venv
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb && \
  dpkg -i cuda-keyring_1.0-1_all.deb && \
  apt-get update && \
  apt-get -y install cuda
