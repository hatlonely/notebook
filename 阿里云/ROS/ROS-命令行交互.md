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

1. 编写模板 `quick-start.yaml`

```yaml
ROSTemplateFormatVersion: '2015-09-01'
Description: ros quick start
Parameters:
  VpcCidrBlock:
    Type: String
    Default: 192.168.0.0/24
Resources:
  VPC:
    Type: ALIYUN::ECS::VPC
    Properties:
      VpcName: myvpc
      CidrBlock:
        Ref: VpcCidrBlock
```

2. 创建资源栈

```shell
aliyun ros CreateStack \
  --RegionId cn-shanghai \
  --StackName quick-start-cli \
  --TimeoutInMinutes 10 \
  --TemplateBody "$(cat quick-start.yaml)"
```

TODO: Parameters 是对象数组，无法传入

3. 查看资源栈

```shell
aliyun ros GetStack --RegionId cn-shanghai --StackId 355cb0f0-ea92-4851-ac73-b47572673bfe
```

4. 更新模板，更新 vpc 的 cidr 地址段为 `172.16.0.0/16`

```yaml
ROSTemplateFormatVersion: '2015-09-01'
Description: ros quick start
Parameters:
  VpcCidrBlock:
    Type: String
    Default: 172.16.0.0/16
Resources:
  VPC:
    Type: ALIYUN::ECS::VPC
    Properties:
      VpcName: myvpc
      CidrBlock:
        Ref: VpcCidrBlock
```

5. 更新资源栈

```shell
aliyun ros UpdateStack \
  --RegionId cn-shanghai \
  --StackId 355cb0f0-ea92-4851-ac73-b47572673bfe \
  --TimeoutInMinutes 10 \
  --TemplateBody "$(cat quick-start.yaml)"
```

6. 删除资源栈

```shell
aliyun ros DeleteStack --RegionId cn-shanghai --StackId 355cb0f0-ea92-4851-ac73-b47572673bfe
```
