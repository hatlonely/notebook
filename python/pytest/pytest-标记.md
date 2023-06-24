# pytest 标记

## 跳过测试

- skip: 跳过测试
    - reason: 跳过原因
- skipif: 条件跳过测试
    - condition: 条件
    - reason: 跳过原因

```python
# 跳过
# Output:
# test_4_marker.py::test_skip SKIPPED (test skip)                          [100%]
# Skipped: test skip
@pytest.mark.skip(reason="test skip")
def test_skip():
    assert True


# 条件跳过
# Output:
# test_4_marker.py::test_skipif SKIPPED (test skipif)                      [100%]
# Skipped: test skipif
@pytest.mark.skipif(1 > 0, reason="test skipif")
def test_skipif():
    assert True
```

## 预期失败

如果确定一个 case 会失败，可以使用预期失败标记，这样如果 case 失败了会标记为 xfailed，如果成功了会标记为 xpassed。

- xfail: 预期失败
    - condition: 条件
    - reason: 预期失败原因

```python
# 标记为预期失败
@pytest.mark.xfail(reason="test xfail")
def test_xfail():
    assert False


# 标记为满足条件预期失败
@pytest.mark.xfail(sys.platform == "win32", reason="test xfail")
def test_xfail_condition():
    assert False
```

## 参数化

参数化用于同一个函数，多组 case 的场景

- parametrize: 参数化
    - argnames: 参数名
    - argvalues: 参数值
    - ids: 参数值的标识

```python
# 参数化。同一个函数，多组 case
@pytest.mark.parametrize("a,b,c", [(1, 2, 3), (4, 5, 9)])
def test_parametrize(a, b, c):
    assert a + b == c
```

## 忽略警告

正常情况下，测试中的 warning 会被打印出来，如果想忽略 warning，可以使用 filterwarnings 标记。

- filterwarnings: 忽略警告
    - message: 警告信息

```python
# 忽略警告
@pytest.mark.filterwarnings("ignore:api v1")
def test_filterwarnings():
    def api_v1():
        warnings.warn(UserWarning("api v1"))
        return 1

    assert api_v1() == 1
```

## 使用 fixture

首先在 `conftest.py` 中定义 fixture 函数

```python
@pytest.fixture()
def custom_fixture():
    print("Custom fixture")
```

然后在 case 中使用 fixture

```python
# 使用 fixture
# fixture 需要定义在 conftest.py 中
@pytest.mark.usefixtures("custom_fixture")
def test_fixture():
    assert True
```

## 自定义标记

可以自定义标记，然后在 case 中使用自定义标记，一般用于指定 case 运行。

1. 在 `pytest.ini` 中定义自定义标记

```ini
[pytest]
markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
```

2. 在 python 中使用自定义标记 `test_4_marker.py`

```python
@pytest.mark.slow
def test_custom_slow():
    assert True
```

3. 指定运行自定义标记的 case

```shell
pytest test_4_marker.py -m slow
```

## 参考链接

- [pytest 官网文档](https://docs.pytest.org/en/7.3.x/how-to/mark.html)
