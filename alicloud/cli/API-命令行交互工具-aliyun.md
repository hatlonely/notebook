# API 命令行交互工具

阿里云提供了 API 命令行交互工具，方便通过命令行与阿里云交互，管理阿里云资源

## 安装

### Mac 安装

```shell
wget https://aliyuncli.alicdn.com/aliyun-cli-macosx-3.0.32-amd64.tgz?file=aliyun-cli-macosx-3.0.32-amd64.tgz -O aliyun-cli-macosx-3.0.32-amd64.tgz
tar -xzvf aliyun-cli-macosx-3.0.32-amd64.tgz && chmod +x aliyun && rm aliyun-cli-macosx-3.0.32-amd64.tgz
mv aliyun /usr/local/bin/
```

### Ubuntu 安装

```shell
wget https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-amd64.tgz -O aliyun-cli-linux-latest-amd64.tgz
tar -xzvf aliyun-cli-linux-latest-amd64.tgz && chmod +x aliyun && rm aliyun-cli-linux-latest-amd64.tgz
mv aliyun /usr/local/bin/
```

## 访问凭证

1. 配置访问凭证

```shell
aliyun configure set \
  --profile hatlonely \
  --mode AK \
  --region cn-beijing \
  --access-key-id AccessKeyId \
  --access-key-secret AccessKeySecret
```

2. 获取和查看访问凭证

```shell
aliyun configure list
aliyun configure get --profile hatlonely
```

## 调用 API

命令格式 `aliyun <product> <api-name> [--parameter1 value1 --parameter2 value2 ...]`

- `product`: 产品名称，可通过 `aliyun help` 查看支持的产品
- `api-name`: API 名称，可以通过 `aliyun <product> help` 查看产品支持的 API，比如 `aliyun ecs help`
- `parameter`: 通过 `aliyun <product> <api-name> help` 可以查看支持的参数

阿里云服务的 API 有两种风格，分别是 RPC 风格和 RESTful 风格，不同的服务有不同的风格，不同的风格有不同的调用形式

### 调用 RPC API

如下命令，调用 ecs 的 DescribeInstances 方法查看当前 region 的服务器资源

```shell
aliyun ecs DescribeInstances
```

### 调用 RESTful API

获取容器服务集群信息

```shell
aliyun cs GET /clusters
```

### 指定凭证

如果环境中有多份凭证信息，可以通过 `--profile` 参数指定凭证

```shell
aliyun --profile hatlonely ecs DescribeInstances
```

### 模拟调用

通过 `--dryrun` 参数可以模拟调用，仅输出将要发送的请求信息，不实际发送请求

```shell
aliyun ecs DescribeInstances --dryrun
```

## 参考链接

- [阿里云 CLI 官网](https://help.aliyun.com/product/29991.html)
