#!/usr/bin/env bash

function InstallPython() {
  apt install -y python
}

function InstallBBR() {
  wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh && chmod +x bbr.sh && ./bbr.sh
}

function InstallShadowsocks() {
  wget --no-check-certificate -O shadowsocks.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks.sh && \
  chmod +x shadowsocks.sh && \
  ./shadowsocks.sh
}

# 防火墙里面默认有些规则，把这些规则清理掉
function ClearFirewall() {
  nft flush ruleset
}

function main() {
  ClearFirewall
  InstallPython
  InstallBBR
  InstallShadowsocks
}

main
