# cdk python 入门

## 安装

1.  安装 CDK

```shell
npm install -g aws-cdk
cdk --version
```

2. 安装 python 包

```shell
python3 -m pip install aws-cdk-lib
```

3. 开通 cdk 服务

```shell
aws configure
cdk bootstrap
```

## hello world

1. 创建项目

```shell
mkdir hello-world && cd hello-world
cdk init app --language python

source .venv/bin/activate
python -m pip install -r requirements.txt
```

2. 部署

```shell
cdk deploy
```

## 参考链接

- [AWS CDK 入门](https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html)
- [AWS CDK在 Python 中使用](https://docs.aws.amazon.com/zh_cn/cdk/v2/guide/work-with-cdk-python.html)
