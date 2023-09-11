# chaosblade 混沌实验工具入门

chaosblade 是阿里开源的混沌实验工具

## 安装

```shell
wget https://github.com/chaosblade-io/chaosblade/releases/download/v1.7.2/chaosblade-1.7.2-linux-amd64.tar.gz
tar -zxvf chaosblade-1.7.2-linux-amd64.tar.gz
```

## 快速入门

```shell
# 创建一个 cpu 负载 50% 持续 20s 的实验
./blade create cpu load --timeout 20 --cpu-percent=50

# 查看当前 cpu 的值
top

# 销毁刚刚创建的实验，其中 d94164c3f6f4001c 为实验 id，在创建时返回
./blade destroy d94164c3f6f4001c
```

## 查看帮助

```shell
# 查看 create 命令帮助文档
blade create -h

# 查看如何创建 cpu 混沌实验
blade create cpu -h

# 查看如何创建 cpu 满载实验
blade create cpu fullload -h

# 创建 cpu 满载实验
blade create cpu fullload --cpu-count 1
```

# 参考链接

- [项目地址](https://github.com/chaosblade-io/chaosblade/blob/master/README_CN.md)
- [中文文档地址](https://chaosblade.io/docs/)
- [blade 工具中文文档地址](https://chaosblade-io.gitbook.io/chaosblade-help-zh-cn/)
- [安装包下载](https://github.com/chaosblade-io/chaosblade/releases)
