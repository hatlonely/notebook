#!/usr/bin/env bash

# 防火墙里面默认有些规则，把这些规则清理掉
function ClearFirewall() {
  nft flush ruleset
}

function InstallVPN() {
  wget https://get.vpnsetup.net -O vpn.sh && sudo sh vpn.sh
}

function main() {
  ClearFirewall
  InstallVPN
}

main
