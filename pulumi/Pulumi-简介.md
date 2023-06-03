# Pulumi 简介

Pulumi 是一个资源编排工具。它基于 Terraform，在 Terraform 之上提供各种编程语言的支持
（包括 TypeScript、JavaScript、Python、Go、.NET、Java），以解决描述性语言在逻辑编程方面的不足。

## Pulumi 安装

### Mac 安装

```shell
brew install pulumi/tap/pulumi
pulumi version
```

## 快速入门

1. 新建 pulumi 项目（按提示获取 pulumi token，操作会记录在 pulumi 平台）

```shell
mkdir quickstart && cd quickstart
pulumi new alicloud-python
```

2. 修改 `__main__.py`

```python
import pulumi
import pulumi_alicloud as alicloud

vpc = alicloud.vpc.Network(
    "my-vpc",
    cidr_block="172.16.0.0/12",
)

az = "cn-hangzhou-i"
sg = alicloud.ecs.SecurityGroup(
    "pulumi_sg",
    description="pulumi security_groups",
    vpc_id=vpc.id,
)

vswitch = alicloud.vpc.Switch(
    "pulumi_vswitch",
    availability_zone=az,
    cidr_block="172.16.0.0/21",
    vpc_id=vpc.id,
)

sg_ids= [sg.id]

sg_rule= alicloud.ecs.SecurityGroupRule(
    "sg_rule",
    security_group_id=sg.id,
    ip_protocol="tcp",
    type="ingress",
    nic_type="intranet",
    port_range="22/22",
    cidr_ip="0.0.0.0/0"
)

instance=alicloud.ecs.Instance(
    "ecs-instance2",
    availability_zone=az,
    instance_type ="ecs.t6-c1m1.large",
    security_groups =sg_ids,
    image_id="ubuntu_18_04_64_20G_alibase_20190624.vhd",
    instance_name ="ecsCreatedByPulumi2",
    vswitch_id=vswitch.id,
    internet_max_bandwidth_out=0,
)
```

3. 执行部署 `pulumi up`
4. 执行删除 `pulumi destroy`

## 参考链接

- pulumi 官网: <https://www.pulumi.com/>
- pulumi 官网文档: <https://www.pulumi.com/docs/get-started/>
