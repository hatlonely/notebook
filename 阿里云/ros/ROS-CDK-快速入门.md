# ROS-CDK 快速入门

ROS-CDK 是 ROS 提供的一个命令行工具，帮助用户通过多种编程语言定义资源，无需使用繁琐的 YAML 语法，和开源工具 Pulumi 类似。

## 安装

### Mac 安装

```shell
brew install node
npm install typescript -g
npm install lerna -g
npm install @alicloud/ros-cdk-cli -g
ros-cdk --version
```

## 快速入门

1. 初始化 ros-cdk 工程

```shell
mkdir py_demo && cd py_demo
ros-cdk init --language=python --generate-only=true

pip3 install -r requirements.txt
```

工程目录结构

```text
├── README.md    # 说明文件
├── app.py       # 入口文件
├── cdk.json     # 工程描述文件
├── py_demo
│   ├── __init__.py
│   └── py_demo_stack.py  # 资源栈定义文件
├── requirements.txt      # python 依赖描述文件
├── setup.py              # python 模块安装文件
├── source.bat
└── test                  # 资源栈测试
    ├── __init__.py
    └── test_py_demo.py
```

2. 设置阿里云凭证

```shell
export ACCESS_KEY_ID="xx"
export ACCESS_KEY_SECRET="xx"
export REGION_ID="cn-beijing"
```

3. 修改资源栈定义文件 `py_demo/py_demo_stack.py`

```python
import ros_cdk_core as core
import ros_cdk_ecs as ecs

class PyDemoStack(core.Stack):
    def __init__(self, scope: core.Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        vpc = ecs.Vpc(self, "vpc", ecs.VPCProps(
            cidr_block="192.168.0.0/16",
            description="create by ros-cdk",
            vpc_name="test-ros-cdk-vpc",
        ))
```

4. 检查模板

```shell
ros-cdk synth --json
```

5. 部署资源栈

```shell
ros-cdk deploy
```

6. 查看资源栈

```shell
ros-cdk list-stacks
```

7. 更新资源栈 `py_demo/py_demo_stack.py`

```python
import ros_cdk_core as core
import ros_cdk_ecs as ecs

class PyDemoStack(core.Stack):
    def __init__(self, scope: core.Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        vpc = ecs.Vpc(self, "vpc", ecs.VPCProps(
            cidr_block="10.0.0.0/24",
            description="create by ros-cdk",
            vpc_name="test-ros-cdk-vpc",
        ))
```

8. 查看资源 diff

```shell
ros-cdk diff
```

9. 更新资源

```shell
ros-cdk deploy
```

10. 删除资源

```shell
ros-cdk destroy
```

## 参考链接

- ROS CDK: <https://help.aliyun.com/document_detail/204689.html>
