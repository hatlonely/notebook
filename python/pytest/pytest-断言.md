# pytest 断言

## 断言

```shell
def test_assertions():
    assert True
    assert 1 == 1
    assert 3 > 2
    assert "Hello" != "World"
    assert 1 == 1 and 3 > 2 and "Hello" != "World"
    assert 1 == 1 or 3 > 2 or "Hello" != "World"
    assert "Hello" in "Hello World"
    assert 123 % 2 == 1
    assert 1 in [1, 2, 3]
    assert 1 in {1, 2, 3}
```

## 异常

```shell
def test_exceptions():
    # 检查代码中是否抛出了除零异常
    with pytest.raises(ZeroDivisionError):
        1 / 0

    # 检查代码中是否抛出了运行时错误，并且错误消息中包含了指定的字符串
    with pytest.raises(RuntimeError) as excinfo:
        def f():
            f()

        f()
    assert 'maximum recursion' in str(excinfo.value)

    # 检查代码中是否抛出了值错误，并且错误消息符合正则表达式
    with pytest.raises(ValueError, match=r".* 123 .*"):
        def f():
            raise ValueError("Exception 123 raised")

        f()
```

## 自定义断言消息

默认的断言失败提示如果不满足需求，可以自定义断言失败的提示消息

首先在 `conftest.py` 中定义提示方法

```python
#!/usr/bin/env python3

# 自定义断言消息
def pytest_assertrepr_compare(op, left, right):
    if isinstance(left, str) and isinstance(right, str) and op == "==":
        return ["Comparing two strings:", "   vals: %s != %s" % (left, right)]
```

再在测试文件中定义测试方法

```python
def test_assertrepr_compare():
    assert "123" == "456"
```

执行测试会得到失败错误消息

```shell
__________________________________ test_assertrepr_compare __________________________________

    def test_assertrepr_compare():
>       assert "123" == "456"
E       assert Comparing two strings:
E            vals: 123 != 456

test_2_assertion.py:44: AssertionError
================================== short test summary info ==================================
```

## 参考链接

- [pytest 官网文档](https://docs.pytest.org/en/7.3.x/how-to/assert.html)
