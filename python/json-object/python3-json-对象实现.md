# python3 json 对象实现

python3 中内置了 json 库，用来作 json 的序列化和反序列化，对基本类型都有比较好的支持，但对于对象类型，还是需要自己实现。

## 内置的 json 模块

简单对象，通过 `vars` 方法或者 `__dict__` 属性即可实现。比如

```python
import json


def test_json1():
    class A():
        key1: int
        key2: str

        def __init__(self, d):
            self.key1 = d.get("key1")
            self.key2 = d.get("key2")

    a = A(json.loads("""{"key1":1,"key2": "val2"}"""))
    assert json.dumps(vars(a)) == """{"key1": 1, "key2": "val2"}"""
```

但这种方式需要编写 `__init__` 方法，并在方法中手动设置所有字段，如果对象比较复杂，这里需要更多的代码，并且这种对应关系通过字符串硬编码传递，
容易写错，从而引入 bug。由此很容易想到使用反射机制去设置字段，优化代码如下：

```python
import json


def test_json2():
    class A():
        key1: int
        key2: str

        def __init__(self, d):
            for k, v in d.items():
                setattr(self, k, v)

    a = A(json.loads("""{"key1":1,"key2": "val2"}"""))
    assert json.dumps(vars(a)) == """{"key1": 1, "key2": "val2"}"""
```

## 复杂的场景

这种模式是可以胜任简单的场景的。但实际的业务往往比较复杂，比如：

1. 需要支持嵌套的对象
2. 需要支持数组
3. 类型保证。上面的例子中，没有类型的判断，给 key1 传一个非 int 类型，也是不会有错误的，但这往往不符合预期。

幸运的是 python 提供的反射机制能很容易地实现这些需求。并且通过装饰器模式可以很方便的应用在需要的类中。

具体的实现如下：

```python
import json
import yaml


def json_object(cls):
    def _init_from_dict__(self, d: dict):
        for field, field_type in cls.__annotations__.items():
            # 跳过不存在的字段
            if field not in d or not d.get(field):
                continue
            # 列表类型
            if hasattr(field_type, "__class_getitem__") and field_type.__origin__ is list and field_type.__args__:
                eles = field_type()
                for e in d.get(field, []):
                    eles.append(field_type.__args__[0](e))
                setattr(self, field, eles)
            # 字典类型
            elif field_type is dict:
                setattr(self, field, field_type(d.get(field)))
            else:
                val = d.get(field)
                val = json.loads(json.dumps(val, default=lambda x: vars(x)))
                setattr(self, field, field_type(val))

    def _init__(self, s=None, type_="json"):
        if not s:
            return

        t = type(s)
        if t is str or t is bytes:
            if type_ == "json":
                s = json.loads(s)
            if type_ == "yaml":
                s = yaml.safe_load(s)
        if t is not dict:
            s = json.loads(json.dumps(s, default=lambda x: vars(x)))
        _init_from_dict__(self, s)

    def _str__(self):
        return json.dumps(vars(self), default=lambda x: vars(x), indent=2)

    def create(**kwargs):
        obj = cls()
        _init_from_dict__(obj, kwargs)
        return obj

    setattr(cls, "__init__", _init__)
    setattr(cls, "__str__", _str__)
    setattr(cls, "create", create)

    return cls


@json_object
class A():
    key1: int
    key2: str

    @json_object
    class B:
        key3: str

        @json_object
        class C:
            key4: str

        c: C
        cs: list[C]

    b: B
    bs: list[B]


def test_json_object_from_json():
    a = A("""{
        "key1": 1,
        "key2": "val2",
        "b": {
            "key3": "val3",
            "c": {
                "key4": "val4"
            },
            "cs": [{
                "key4": "val4"
            }]
        },
        "bs": [{
            "key3": "val3",
            "c": {
                "key4": "val4"
            },
            "cs": [{
                "key4": "val4"
            }]
        }]
    }""")
    print(a)
    assert a.key1 == 1
    assert a.key2 == "val2"
    assert a.b.cs[0].key4 == "val4"
    assert a.bs[0].cs[0].key4 == "val4"
```

这里面几个关键的问题：

1. 通用性。这里通过装饰器模式把逻辑封装在一个一起，使用者在类的注解中添加装饰器信息即可；
2. 支持嵌套首先需要知道嵌套的类型。这一点通过类的 `__annotations__` 属性可以获取类定义的属性以及类型信息；
3. 对于类似 `list[C]` 这种嵌套的数组类型，需要知道其类型为 `list`，并且还需要知道其数组元素的类型为 `C`
   。这里通过 `hasattr(field_type, "__class_getitem__") and field_type.__origin__`
   判断是否为数组类，通过 `field_type.__args__` 获取数组元素的类型。
