# ROS 快速入门

ROS 是阿里云的资源编排服务，用来管理包括 ECS/VPC/RDS/SLB 等各种阿里云资源。ROS 使用 YAML 作为资源模板描述语言，同时也支持开源的 Terraform 语法。

资源管理的交互逻辑主要通过阿里云控制台完成。同时也提供了命令行工具--alicm来调用 api。

由于 YAML 的描述性语言在逻辑表达方面的缺陷，提供了 ROS-CDK（类似 Pulumi）来简化模板的开发。

## 快速入门

1. [ROS 控制台](https://rosnext.console.aliyun.com/overview) -> 【模板】-> 【我的模板】->【创建模板】
2. 编写模板【ROS】->【YAML】

```yaml
ROSTemplateFormatVersion: '2015-09-01'
Description: ros quick start
Parameters:
  VpcCidrBlock:
    Type: String
    Default: 192.168.0.0/16
Resources:
  VPC:
    Type: ALIYUN::ECS::VPC
    Properties:
      VpcName: myvpc
      CidrBlock:
        Ref: VpcCidrBlock
```

3. 创建资源。保存模板之后，回到【我的模板】，选择刚刚创建的模板，点击【创建资源栈】。
4. 创建成功之后会生成资源栈，可以通过资源栈查看，更新和删除资源。
5. 更新资源。资源栈界面的【更改集】中【创建更改集】，可以更新资源。
6. 删除资源。删除资源栈之后，对应的资源也会删除。

## 参考链接

- 阿里云官网: <https://help.aliyun.com/document_detail/48749.html>

