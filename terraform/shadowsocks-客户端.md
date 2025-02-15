# shadowsocks 客户端

## Ubuntu

安装

```bash
sudo apt-get install shadowsocks-libev
```

启用

```bash
ss-local -s 47.128.229.167 -p 29212 -l 1080 -k Mlutz5c0BNVRhE4Z -m chacha20-ietf-poly1305 -v
```

配置文件

```bash
alias ssup="ss-local -s 47.128.229.167 -p 29212 -l 1080 -k Mlutz5c0BNVRhE4Z -m chacha20-ietf-poly1305 -v"

function proxyon() {
  export http_proxy="socks5h://127.0.0.1:1080"
  export https_proxy="socks5h://127.0.0.1:1080"
}

function proxyoff() {
  unset http_proxy
  unset https_proxy
}
```

## 链接

- [shadowsocks 客户端下载](https://shadowsocks5.github.io/en/download/clients.html)
