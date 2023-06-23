# pytest fixture

fixture 用来为测试用例提供一个固定的测试环境，比如数据库的连接，一个预先登录的浏览器，或者一个预先登录的用户。是
Setup/Teardown 机制的升级版。

## 基本用法

使用 `@pytest.fixture` 装饰器来定义 fixture 函数。使用 fixture 的函数会先执行 fixture 中的代码，直到遇到 `yield`
关键字，然后执行测试用例，最后再执行 `yield` 后的代码。如果使用了多个 fixture 函数，这些 fixture 会依次执行。

```python
import pytest


@pytest.fixture()
def init_db():
    print("Init DB")
    yield
    print("Drop DB")


# output:
# Init DB
# PASSED [100%]Test DB
# Drop DB
def test_db(init_db):
    print("Test DB")


# 发生异常时，yield 后的代码依然会执行，以保证资源的释放
# output:
# Init DB
# FAILED                                  [100%]
# test_3_fixture.py:36 (test_db_error)
# init_db = None
#
#     def test_db_error(init_db):
# >       raise Exception("DB error")
# E       Exception: DB error
#
# test_3_fixture.py:38: Exception
# Drop DB
def test_db_error(init_db):
    raise Exception("DB error")
```

## 返回值

fixture 也可以返回一个值，一般就是环境中的对象，比如往数据库中插入的数据。

```python
@pytest.fixture()
def init_db_2():
    print("Init DB")
    yield [1, 2, 3]  # 如果不需要清理，这里也可以直接用 return 返回
    print("Drop DB")


# fixture 也可以返回一个值
# Output:
# test_3_fixture.py::test_db_2 Init DB
# PASSED                                      [100%][1, 2, 3]
# Drop DB
def test_db_2(init_db_2):
    print(init_db_2)
```

## 参考链接

- [pytest 官网文档](https://docs.pytest.org/en/7.3.x/how-to/fixtures.html)
- [知乎-pytest中fixture详解](https://zhuanlan.zhihu.com/p/443523226)
