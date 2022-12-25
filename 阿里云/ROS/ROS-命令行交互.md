## ROS 命令行交互

ROS 没有提供专门的类似 terraform 的命令行交互工具。只提供了阿里云通用的 api 交互工具，可以使用该工具完成资源的部署和更新

## 工具安装

### Mac 安装

```shell
wget https://aliyuncli.alicdn.com/aliyun-cli-macosx-3.0.32-amd64.tgz?file=aliyun-cli-macosx-3.0.32-amd64.tgz -O aliyun-cli-macosx-3.0.32-amd64.tgz
tar -xzvf aliyun-cli-macosx-3.0.32-amd64.tgz && chmod +x aliyun && rm aliyun-cli-macosx-3.0.32-amd64.tgz
mv aliyun /usr/local/bin/
```

## 快速入门

1. 创建资源栈

```shell
aliyun ros CreateStack help
```