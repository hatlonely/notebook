# pytest 参数化

参数是指同一个测试逻辑，使用不同的数据进行测试，这样可以减少代码量，提高代码的复用性。

## 参数化函数

```python
@pytest.mark.parametrize("a,b,c", [
    (1, 2, 3),
    (4, 5, 9),
    pytest.param(1, 2, 4, marks=pytest.mark.xfail),
])
def test_parametrize(a, b, c):
    assert a + b == c
```

上面的例子中，使用三组数据分别测试了 `test_parametrize` 函数，第三组数据使用了 `pytest.param`
函数，可以为这组数据添加标记，这里使用了 `xfail` 标记，表示这组数据预期是失败的。

## 参数化类

参数化同样可以作用在类中

```python
@pytest.mark.parametrize("a,b,c", [
    (1, 2, 3),
    (4, 5, 9),
    pytest.param(1, 2, 4, marks=pytest.mark.xfail),
])
class TestParametrize:
    def test_parametrize1(self, a, b, c):
        assert a + b == c

    def test_parametrize2(self, a, b, c):
        assert c - b == a
```

## 参数化模块

如果一个模块中的所有测试函数都需要使用同一组数据进行测试，可以使用 `pytestmark` 变量来实现。

```python
import pytest

# 模块中所有的测试函数都会使用这组数据进行测试
pytestmark = pytest.mark.parametrize("a,b,c", [
    (1, 2, 3),
    (4, 5, 9),
    pytest.param(1, 2, 4, marks=pytest.mark.xfail),
])


def test_parametrize(a, b, c):
    assert c - b == a


class TestParametrize:
    def test_parametrize1(self, a, b, c):
        assert a + b == c

    def test_parametrize2(self, a, b, c):
        assert c - b == a
```
