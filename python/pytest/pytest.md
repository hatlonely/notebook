# pytest

pytest 是 python 的一个测试框架

## 安装

```shell
pip install -U pytest
```

## 快速入门

1. 创建一个测试文件 `test_1_quick_start.py`

```python
#!/usr/bin/env python3

def add(a, b):
    return a + b


def test_add():
    assert add(1, 2) == 3
    assert add(1, 1) == 2
    assert add(1, 0) == 1
```

2. 运行测试

```shell
pytest -q test_1_quick_start.py
```

## 参考链接

- [pytest 官网文档](https://docs.pytest.org/en/7.3.x/index.html)
