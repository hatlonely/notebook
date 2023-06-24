#!/usr/bin/env python3

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
