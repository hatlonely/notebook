# ROS 快速入门

ros 是阿里云的资源编排服务

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

