# python *args 和 **kwargs

## *args

`*args` 表示任意数量的位置参数，相当于可变长参数，是一个数组。和数组参数的差别是，传参的时候可以不用 `[]` 包裹。

```python
def sum(*args):
    m = 0
    for n in args:
        m += n
    return m


def test_sum():
    assert sum(1, 2) == 3
    assert sum(1, 2, 3) == 6
    assert sum(1, 2, 3, 4, 5) == 15
    assert sum(1, 2, 3, 4, 5, 6) == 21
```

## **kwargs

`**kwargs` 表示任意数量的关键字参数，相当于可变长命名参数，本质是一个字典。和字典参数的差别是，传参的时候可以不用 `{}`
包裹，直接 `key=value` 即可。

```python
def introduce(**kwargs):
    for key, value in kwargs.items():
        print(key, value)
    return kwargs.get("name") + " " + str(kwargs.get("age"))


def test_introduce():
    assert introduce(name="Tom", age=18) == "Tom 18"
    assert introduce(name="Jerry", age=20) == "Jerry 20"
```
