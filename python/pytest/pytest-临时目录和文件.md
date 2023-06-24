# pytest 临时目录和文件

测试过程中，有时候需要创建临时目录和文件，用于测试，测试完成后，需要删除临时目录和文件。

pytest 提供了两个 fixture 来创建临时目录和文件，分别是 tmp_path 和 tmp_path_factory。其中 `tmp_path_factory`
是一个 `session`
级别的 fixture，`tmp_path` 是一个 `function` 级别的 fixture。即 `tmp_path_factory` 在不同的测试 case 之间调用返回的结果总是一样的，
但其调用 `mktemp` 方法创建的临时目录和文件是不同的，而 `tmp_path` 在不同的测试 case 之间调用返回的结果是不一样的。

```python
def test_tmp_path(tmp_path):
    p = tmp_path / "1.txt"
    p.write_text("Hello World")

    print(p)
    assert p.read_text() == "Hello World"


def test_tmp_path_factory(tmp_path_factory):
    p = tmp_path_factory.mktemp("mydir") / "1.txt"
    p.write_text("Hello World")

    print(p)
    assert p.read_text() == "Hello World"
```

## 参考链接

- [pytest 官网文档](https://docs.pytest.org/en/7.3.x/how-to/tmp_path.html)
