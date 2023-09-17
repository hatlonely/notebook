# 制作一个 flask web 服务镜像

1. 创建代码文件 `app/main.py`

```python
import flask

app = flask.Flask(__name__)


@app.route("/")
def index():
    return "<p>Hello, World!</p>"


@app.route("/hello/<name>")
def hello(name):
    return f"<p>Hello, {name}!</p>"


@app.route("/json")
def json():
    return {"hello": "world"}
```

2. 创建依赖文件 `app/requirements.txt`

```txt
Flask~=2.3.3
gunicorn~=21.2.0
```

3. 创建 gunicorn 配置文件 `app/config.py`

- 日志输出到标准输出
- 绑定到 `0.0.0.0` 供所有网络接口访问

```python
bind = "0.0.0.0:8000"
backlog = 2048

workers = 1
worker_class = "sync"
worker_connections = 1000
timeout = 30
keepalive = 2

spew = False

errorlog = "-"
loglevel = "info"
accesslog = "-"

access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'
```

4. 创建 `Dockerfile` 文件

```dockerfile
FROM python:3.12.0rc2-alpine3.18

COPY ./app /app
WORKDIR /app

RUN pip3 install -r requirements.txt

EXPOSE 8000
CMD [ "gunicorn", "-c", "config.py", "main:app" ]
```

5. 构建镜像

```sh
docker build . -t flask-web
```

6. 运行镜像

```sh
docker run -p 8000:8000 flask-web
```

## 参考链接

- [vscode docker python 教程](https://code.visualstudio.com/docs/containers/quickstart-python)
- [flask 生产环境部署文档](https://flask.palletsprojects.com/en/2.3.x/deploying/)
- [flask gunicorn 文档](https://flask.palletsprojects.com/en/2.3.x/deploying/gunicorn/)
- [gunicorn 配置文件样例](https://github.com/benoitc/gunicorn/blob/master/examples/example_config.py)
