import pytest
import requests


def test_root(setup):
    res = requests.get("http://localhost:5000")
    assert res.text == "<p>Hello, World!</p>"


@pytest.mark.parametrize("name", ["John", "Jane", "Doe"])
def test_hello(setup, name):
    res = requests.get(f"http://localhost:5000/hello/{name}")
    assert res.text == f"<p>Hello, {name}!</p>"


def test_json(setup):
    res = requests.get("http://localhost:5000/json")
    assert res.json() == {"hello": "world"}
