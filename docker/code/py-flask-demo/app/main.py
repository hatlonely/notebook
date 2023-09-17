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
