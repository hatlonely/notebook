# sam lambda 命令行工具简介

sam 是 lambda 命令行工具

## 安装

### Mac

```shell
brew tap aws/tap
brew install aws-sam-cli
```

## 配置凭证

aws 命令需要先配置访问凭证。访问凭证通过 [IAM 控制台](https://us-east-1.console.aws.amazon.com/iamv2/home)获取

```shell
aws configure

AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-west-2
Default output format [None]: json
```

## 快速入门

1. 创建项目

```shell
sam init
```

2. 构建应用程序

```shell
sam build
```

3. 本地测试

```shell
sam local start-api

curl http://127.0.0.1:3000/hello
```

4. 部署到 aws

```shell
sam deploy --guided
```

5. 删除函数

```shell
sam delete
```

## 参考链接

- [sam 快速入门](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-getting-started.html)
- [sam web 应用适配](https://github.com/awslabs/aws-lambda-web-adapter/tree/main/examples/gin)
