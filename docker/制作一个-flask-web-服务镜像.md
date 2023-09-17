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

3. 创建 `Dockerfile` 文件

```dockerfile
FROM python:3.12.0rc2-alpine3.18

COPY ./app /app
WORKDIR /app

RUN pip3 install -r requirements.txt

EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "main:app"]
```

4. 构建镜像

```sh
docker build . -t flask-web
```

5. 运行镜像

```sh
docker run -p 8000:8000 flask-web
```

## 参考链接

- [vscode docker python 教程](https://code.visualstudio.com/docs/containers/quickstart-python)
- [flask 生产环境部署文档](https://flask.palletsprojects.com/en/2.3.x/deploying/)
- [flask gunicorn 文档](https://flask.palletsprojects.com/en/2.3.x/deploying/gunicorn/)
