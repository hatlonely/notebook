# win11 开发工具集合

## 安装 cygwin

<win11-cygwin-终端.md>


## 安装 Scoop

打开终端

```shell
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
irm get.scoop.sh | iex
```

## 安装 helm

1. 安装 helm

```shell
scoop bucket add main
scoop install helm
```

2. 安装 helm diff

```shell
helm plugin install https://github.com/databus23/helm-diff
```

3. 安装报 `file does not exist` 错参考，<https://github.com/databus23/helm-diff/issues/316>。手动下载[二进制文件](https://github.com/databus23/helm-diff/releases/download/v3.1.3/helm-diff-windows.tgz)，解压后，拷贝到报错目录
4. 安装完成后需要设置环境变量

```shell
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=/cygdrive/c/Users/hatlo/scoop/shims:$PATH
export APPDATA=C:\\Users\\hatlo\\AppData\\Roaming
```

5. 执行 `helm diff` 查看是否成功

## 安装 docker

下载 [Docker Desktop](https://www.docker.com/) 之后安装即可
