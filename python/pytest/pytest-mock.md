# pytest mock

pytest 内置了 `monkeypatch` fixture，可以用来 mock 任何对象，包括函数、类、属性等。

## mock 方法

下面是一个 mock requests.get 的例子：

```python
import requests


def test_mock_get(monkeypatch):
    def mock_get(url, params=None, **kwargs):
        assert url == "http://test.com"
        assert params == {"hello": "world"}
        assert kwargs == {'headers': {'content-type': 'application/json'}}
        res = requests.Response()
        res.status_code = 200
        res.headers = {'content-type': 'application/json'}
        res._content = b'{"key1": "val1"}'
        return res

    monkeypatch.setattr(requests, 'get', mock_get)
    res = requests.get(
        'http://test.com',
        params={"hello": "world"},
        headers={'content-type': 'application/json'}
    )
    assert res.status_code == 200
    assert res.json() == {"key1": "val1"}
    assert res.headers['content-type'] == 'application/json'
```

## mock 返回

上例的 mock 需要自己构造返回的 Response
对象，其中涉及访问很多原始对象的内部属性，比较麻烦，而且不一定能访问到。比如 `_content` 实际是一个私有成员，理论上不应该访问。

而 mock 返回可以很好地解决这个问题，只需要返回一个 mock 的 Response 对象即可：

```python
class MockResponse():
    def __init__(self, status_code=200, headers=None, content=None):
        self.status_code = status_code
        self.headers = headers
        self.content = content

    def json(self):
        return self.content


def test_mock_response(monkeypatch):
    def mock_get(url, params=None, **kwargs):
        assert url == "http://test.com"
        assert params == {"hello": "world"}
        assert kwargs == {'headers': {'content-type': 'application/json'}}

        return MockResponse(
            status_code=200,
            headers={'content-type': 'application/json'},
            content={"key1": "val1"}
        )

    monkeypatch.setattr(requests, 'get', mock_get)
    res = requests.get(
        'http://test.com',
        params={"hello": "world"},
        headers={'content-type': 'application/json'}
    )
    assert res.status_code == 200
    assert res.json() == {"key1": "val1"}
    assert res.headers['content-type'] == 'application/json'
```

## 参考链接

- [pytest 官网文档](https://docs.pytest.org/en/7.3.x/how-to/monkeypatch.html)
