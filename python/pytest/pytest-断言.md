# pytest 断言

## 断言

```python
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

期望抛出异常需要使用 `pytest.raises`，直接使用 `try...expect` 语法可能会因为没有进入异常分支，从而跳过异常验证逻辑

```python
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

不要在 `try` 分支中断言，断言本身也是一种异常，如果出错会直接进入错误处理逻辑，无法正确抛出异常

```python
# assert 本身也是也是一种异常，会被 try 捕获，下面代码会测试通过
def test_try_assert():
    try:
        assert 1 == 2
    except Exception as e:
        pass
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

## 非 test 文件的断言

### pytest 机制

断言函数在 `my_checker.py` 中

```python
def checker():
    a = 5
    b = 3
    assert a == b
```

在 pytest.ini 中增加配置

```ini
python_files = *_checker.py
```

在测试文件中调用该断言函数

```python
from my_checker import checker


def test_checker():
    checker()
```

执行测试会得到失败的错误消息，这个输出和 pytest 原生的提示也不一样，不太理想

```shell
test_2_assertion.py::test_checker FAILED                                 [100%]
test_2_assertion.py:51 (test_checker)
5 != 3

Expected :3
Actual   :5
<Click to see difference>

def test_checker():
>       checker()

test_2_assertion.py:53:
```

### \[推荐\] python 原生 assert 机制

直接在断言出增加参数设置断言消息 `my_checker.py`

```python
def checker():
    a = 5
    b = 3
    assert a == b, f"assert {a} == {b}"
```

在测试文件中调用该断言函数

```python
from my_checker import checker


def test_checker():
    checker()
```

执行测试得到失败的错误消息，这个输出和 pytest 的提示是一致的，但需要再每次断言的时候手动编写断言消息

```shell
test_2_assertion.py:51 (test_checker)
def test_checker():
>       checker()

test_2_assertion.py:53:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

    def checker():
        a = 5
        b = 3
>       assert a == b, f"assert {a} == {b}"
E       assert 5 == 3

my_checker.py:4: AssertionError
```

## 参考链接

- [pytest 官网文档](https://docs.pytest.org/en/7.3.x/how-to/assert.html)
- [pytest 配置文件](https://docs.pytest.org/en/7.1.x/reference/reference.html#confval-python_files)
