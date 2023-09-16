# git 配置

## 显示中文字符

```shell
git config --global core.quotepath off
```

## 代理

访问 github.com 比较慢，本地设置 ss 之后，wsl 可以通过设置本地代理加速访问

```shell
git config --global http.proxy 172.26.16.1:7080
git config --global https.proxy 172.26.16.1:7080
```

## 参考链接

- [git config](https://git-scm.com/docs/git-config)
