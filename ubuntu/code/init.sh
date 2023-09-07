#!/usr/bin/env bash

# https://docs.docker.com/engine/install/ubuntu/
# 安装 docker
function install_docker() {
  which docker 1>/dev/null 2>&1 && echo "skip docker" || {
    sudo apt-get update -y
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo rm -rf /etc/apt/keyrings/docker.gpg
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
      sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  }
}

function install_python3() {
  which python3 1>/dev/null 2>&1 &&echo "skip" python3 || {
    sudo apt install -y python3
    sudo apt install -y python3-pip
  }
}

function install_python3_libs() {
  cat > requirements.txt <<EOF
selenium~=4.12.0
EOF
  pip3 install -r requirements.txt
  rm -rf requirements.txt
}

function install_unzip() {
  which unzip 1>/dev/null 2>&1 && echo "skip unzip" || {
    sudo apt install -y unzip
  }
}

function main() {
  install_docker
  install_unzip
  install_python3
  install_python3_libs
}

main
