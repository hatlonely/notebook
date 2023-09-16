# flask 快速入门

## 安装

```shell
pip3 install Flask
```

## 快速入门

1. 创建 flask 入口文件 `1_quick_start.py`

```shell
from flask import Flask

app = Flask(__name__)


@app.route('/')
def hello_world():
    return "<p>Hello, World!</p>"
```

2. 运行 flask

```shell
flask --app 1_quick_start run
```

> windows wsl 报错找不到 flask 命令，可能需要在 .zsh 中添加路径 `export PATH="$HOME/.local/bin:$PATH"`

3. 访问 app

```shell
curl http://127.0.0.1:5000
```

## 命令行

- `host`: 指定主机，外网只能通过设定的主机地址访问，可以设置为 0.0.0.0 以允许外网访问
- `debug`: 开启调试模式，修改代码后自动重启

## 路由

- `@app.route(rule, options)`: 装饰器，将函数注册为路由，`rule` 为路由规则，`options` 为可选参数

```python
@app.route('/')
def index():
    return 'Index Page'


@app.route('/hello')
def hello():
    return 'Hello, World'
```

## 变量

在路由中可以设置变量，变量名需要用 `<variable_name>` 包裹，变量默认为字符串类型，可以通过 `<converter:variable_name>`
指定变量类型

```python
@app.route('/user/<username>')
def show_user_profile(username):
    return f'User {username}'
```

```shell
$ curl 127.0.0.1:5000/user/hatlonely

User hatlonely
```

## HTTP 方法

可以通过 `methods` 参数指定路由支持的 HTTP 方法

```python
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        return do_the_login()
    else:
        return show_the_login_form()
```

上面的代码也可以分开写成两个方法

```python
@app.get('/login')
def login_get():
    return show_the_login_form()


@app.post('/login')
def login_post():
    return do_the_login()
```

## 静态文件

```python
url_for('static', filename='style.css')
```

## 模板渲染

```python
from flask import render_template


@app.route('/hello/')
@app.route('/hello/<name>')
def hello(name=None):
    return render_template('hello.html', name=name)
```

模板文件

```jinja2
<!doctype html>
<title>Hello from Flask</title>
{% if name %}
  <h1>Hello {{ name }}!</h1>
{% else %}
  <h1>Hello, World!</h1>
{% endif %}
```

## 获取请求数据

```python
from flask import request

with app.test_request_context('/hello', method='POST'):
    # now you can do something with the request until the
    # end of the with block, such as basic assertions:
    assert request.path == '/hello'
    assert request.method == 'POST'
```

## 文件上传

```python
from flask import request


@app.route('/upload', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        f = request.files['the_file']
        f.save('/var/www/uploads/uploaded_file.txt')
```

## cookies

获取 cookies

```python
from flask import request


@app.route('/')
def index():
    username = request.cookies.get('username')
```

设置 cookies

```python
from flask import make_response


@app.route('/')
def index():
    resp = make_response(render_template(...))
    resp.set_cookie('username', 'the username')
    return resp
```

## 重定向

```python
@app.route('/')
def index():
    return redirect(url_for('login'))
```

## 错误

```python
@app.route('/login')
def login():
    abort(401)
    this_is_never_executed()
```

## 返回 json

```python
@app.route("/me")
def me_api():
    user = get_current_user()
    return {
        "username": user.username,
        "theme": user.theme,
        "image": url_for("user_image", filename=user.image),
    }


@app.route("/users")
def users_api():
    users = get_all_users()
    return [user.to_json() for user in users]
```

## sessions

```python
from flask import session

# Set the secret key to some random bytes. Keep this really secret!
app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'


@app.route('/')
def index():
    if 'username' in session:
        return f'Logged in as {session["username"]}'
    return 'You are not logged in'


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        session['username'] = request.form['username']
        return redirect(url_for('index'))
    return '''
        <form method="post">
            <p><input type=text name=username>
            <p><input type=submit value=Login>
        </form>
    '''


@app.route('/logout')
def logout():
    # remove the username from the session if it's there
    session.pop('username', None)
    return redirect(url_for('index'))
```

## 日志

```python
app.logger.debug('A value for debugging')
app.logger.warning('A warning occurred (%d apples)', 42)
app.logger.error('An error occurred')
```

## 参考链接

- [flask 官网文档](https://flask.palletsprojects.com/en/2.3.x/quickstart/#a-minimal-application)
