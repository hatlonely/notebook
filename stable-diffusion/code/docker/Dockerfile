FROM ubuntu:22.04

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb && \
  sudo dpkg -i cuda-keyring_1.0-1_all.deb && \
  sudo apt-get update && \
  sudo apt-get -y install cuda
RUN sudo apt install -y wget git python3 python3-venv
