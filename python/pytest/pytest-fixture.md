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

## autouse

fixture 之间如果有依赖关系，可以使用 `autouse=True` 来自动使用 fixture。否则需要在测试用例中显式指定所有的 fixture。

```python
@pytest.fixture()
def init_db_3():
    return []


@pytest.fixture(autouse=True)
def insert1(init_db_3):
    print("Insert 1")
    init_db_3.append(1)
    return init_db_3


@pytest.fixture(autouse=True)
def insert2(insert1):
    print("Insert 2")
    insert1.append(2)
    return insert1


def test_db_3(insert2):
    assert insert2 == [1, 2]
```

## 作用域

fixture 有如下五种作用域：

- `function`: 默认作用域，每个测试用例都会执行一次
- `class`: 每个测试类执行一次
- `module`: 每个测试模块执行一次
- `package`: 每个测试包执行一次
- `session`: 每个测试会话执行一次，即全局只执行一次

```python
# 在一次测试调用中，fixture 只会执行一次
@pytest.fixture(scope="session")
def session_fixture():
    print("Session fixture")


def test_session_1(session_fixture):
    print("Test session 1")


def test_session_2(session_fixture):
    print("Test session 2")
```

## 参考链接

- [pytest 官网文档](https://docs.pytest.org/en/7.3.x/how-to/fixtures.html)
- [知乎-pytest中fixture详解](https://zhuanlan.zhihu.com/p/443523226)
