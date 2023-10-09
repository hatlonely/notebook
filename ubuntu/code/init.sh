#!/usr/bin/env bash

# https://docs.docker.com/engine/install/ubuntu/
# 安装 docker
function install_docker() {
  which docker 1>/dev/null 2>&1 && echo "skip docker" || {
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    rm -rf /etc/apt/keyrings/docker.gpg
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
      tee /etc/apt/sources.list.d/docker.list >/dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  }
}

function install_python3() {
  which python3 1>/dev/null 2>&1 &&echo "skip" python3 || {
    apt install -y python3
    apt install -y python3-pip
  }
}

function install_python3_libs() {
  cat > requirements.txt <<EOF
selenium~=4.12.0
playwright~=1.37.0
tk~=0.1.0
pytest~=7.4.2
pytest-base-url~=2.0.0
pytest-html~=4.0.2
pytest-metadata~=3.0.0
pytest-playwright~=0.4.2
pyquery~=2.0.0
numpy~=1.25.2
pandas~=2.1.0
EOF
  pip3 install -r requirements.txt
  rm -rf requirements.txt
}

function install_unzip() {
  which unzip 1>/dev/null 2>&1 && echo "skip unzip" || {
    apt install -y unzip
  }
}

function install_sysstat() {
  which iostat 1>/dev/null 2>&1 && echo "skip sysstat" || {
    apt install -y sysstat
  }
}

function install_google_chrome() {
  which google-chrome 1>/dev/null 2>&1 && echo "skip google-chrome" || {
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    apt install -y xdg-utils
    dpkg -i google-chrome-stable_current_amd64.deb
  }
}

function install_aliyun() {
  which aliyun 1>/dev/null 2>&1 && echo "skip aliyun" || {
    wget https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-amd64.tgz -O aliyun-cli-linux-latest-amd64.tgz
    tar -xzvf aliyun-cli-linux-latest-amd64.tgz && chmod +x aliyun && rm aliyun-cli-linux-latest-amd64.tgz
    mv aliyun /usr/local/bin/
  }
}

function install_nodejs() {
  which node 1>/dev/null 2>&1 && echo "skip node" || {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    source ~/.bashrc
    nvm install v18.18.0
  }
}

function install_serverless_dev() {
  which s 1>/dev/null 2>&1 && echo "skip serverless-dev" || {
    npm install @serverless-devs/s -g
  }
}

function main() {
  install_docker
  install_unzip
  install_python3
  install_python3_libs
}

main
