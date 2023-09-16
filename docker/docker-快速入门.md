# docker 快速入门

## 安装

### ubuntu

```sh
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
```

运行一个最简单的 hello world 容器，正常会下载镜像，并运行容器，输出问候语。

```sh
docker run hello-world
```

## 快速入门

busybox 是一个非常小的 linux 发行版，只有几 M 左右，可以用来做一些简单的测试。

```sh
# 拉取 busybox 镜像,默认从 docker.io 拉取
docker pull busybox

# 查看本地镜像
docker images

# 运行一个 busybox 容器
docker run busybox echo "hello world"

# 查看正在运行的容器
docker ps

# 查看所有容器
docker ps -a

# 启动容器，并以交互式进入容器
docker run -it busybox sh

# 删除容器
# docker rm <container id>
docker rm 18cc81c2af5f b31dd8e9cfb2

# 删除已退出的容器
docker rm $(docker ps -a -q -f status=exited)

# 删除已退出的容器（新版本）
docker container prune
```

## 参考链接

- [docker 官网安装教程](https://docs.docker.com/engine/install/)
- [docker for beginners](https://docker-curriculum.com/)
