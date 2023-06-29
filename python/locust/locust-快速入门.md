# locust 快速入门

## 安装

```shell
pip3 install locust
```

检查是否安装成功

```shell
locust --version
```

## 准备服务

1. 编写 `flask_app.py`

```python
from flask import Flask

app = Flask(__name__)


@app.route('/hello')
def hello():
    return "hello"


@app.route('/world')
def world():
    return "world"
```

2. 运行服务

```shell
flask --app flask_app.py run
```

## 测试服务

1. 编写 `locustfile.py`

```python
from locust import HttpUser, task


class HelloWorldUser(HttpUser):
    @task
    def hello_world(self):
        self.client.get("/hello")
        self.client.get("/world")
```

2. 运行测试

```shell
locust -f locustfile.py
```

3. 打开测试页面 http://localhost:8089

设置测试参数：

- Number of users: 1
- Spawn rate: 1
- Host: http://localhost:5000

## 参考链接

- [locust 官方文档](https://docs.locust.io/en/stable/installation.html)
- [locust 项目地址](https://github.com/locustio/locust)
