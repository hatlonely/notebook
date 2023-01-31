# 容器镜像服务 ECR 简介

ECR 是 aws 提供的容器镜像服务

## 快速入门

1. 安装命令行工具 `aws`，[参考链接](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

```shell
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
aws --version
```

2. 获取用户 ID 和地区

其中用户 ID 在 [IAM 控制台](https://us-east-1.console.aws.amazon.com/iamv2/home#/home)可以看到

```shell
export AWS_ACCOUNT_ID=354292498874
export AWS_REGION_ID=ap-southeast-1
```

3. 获取 docker 访问密码，并登录

- 镜像地址: `${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION_ID}.amazonaws.com`
- 用户名: `AWS`
- 密码: 通过如下命令获取 `aws ecr get-login-password --region "${AWS_REGION_ID}"`

```shell
aws ecr get-login-password --region "${AWS_REGION_ID}" | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION_ID}.amazonaws.com
```

4. 创建镜像仓库

```shell
aws ecr create-repository --region "${AWS_REGION_ID}" --repository-name hello-repository
```

5. 推送镜像到仓库

```shell
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION_ID}.amazonaws.com/hello-repository:1.0.0
```

## 参考链接

- [ecr 官网文档](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
- [通过 aws cli 使用 ecr](https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html)
