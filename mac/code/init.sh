#!/usr/bin/env bash

function install_python3() {
  which python3 >/dev/null 2>&1 && echo "skip python3" || {
    brew install python3
  }
}

function install_python3_libs() {
  cat >requirements.txt <<EOF
selenium~=4.12.0
webdriver-manager~=4.0.0
EOF
  pip3 install -r requirements.txt
  rm -rf requirements.txt
}

function main() {
  install_python3
  install_python3_libs
}

main
