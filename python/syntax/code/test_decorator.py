#!/usr/bin/env python3

import json
import time

import yaml


def simple_decorator(func):
    def wrapper():
        print('Before call')
        func()
        print('After call')

    return wrapper


# 装饰方法
def test_simple_decorator():
    def hello():
        print('Hello world')

    hello = simple_decorator(hello)
    hello()
    print('Done')


# 简单装饰器
def test_simple_decorator2():
    @simple_decorator
    def hello():
        print('Hello world')

    hello()
    print('Done')


def retry(times=3, delay=0.1):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for i in range(times):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    print("retry {}".format(i), e)
                    time.sleep(delay)

        return wrapper

    return decorator


# 带参数的装饰器
def test_retry():
    @retry(times=5, delay=0.05)
    def hello():
        print('Hello world')
        raise Exception('Timeout')

    hello()


# 装饰类
def log_decorator(cls):
    def caller_with_log(caller):
        def call(*args, **kwargs):
            print(f"{caller.__name__}: call start")
            res = caller(*args, **kwargs)
            print(f"{caller.__name__}: call end")
            return res

        return call

    for attr in cls.__dict__:
        caller = getattr(cls, attr)
        if callable(caller):
            if caller.__name__.startswith("__"):
                continue
            setattr(cls, attr, caller_with_log(getattr(cls, attr)))
    return cls


def test_class_decorator():
    @log_decorator
    class A:
        def func1(self):
            print("func1 call")

        def func2(self):
            print("func1 call")

    a = A()
    a.func1()
    a.func2()


def json_object(cls):
    def _init_from_dict__(self, d: dict):
        for field, field_type in cls.__annotations__.items():
            # 跳过不存在的字段
            if field not in d:
                continue
            # 列表类型
            if hasattr(field_type, "__class_getitem__") and field_type.__origin__ is list and field_type.__args__:
                eles = field_type()
                for e in d.get(field, []):
                    eles.append(field_type.__args__[0](e))
                setattr(self, field, eles)
            # 字典类型
            else:
                setattr(self, field, field_type(d.get(field)))

    def _init__(self, s, type_="json"):
        t = type(s)
        if t is str or t is bytes:
            if type_ == "json":
                s = json.loads(s)
            if type_ == "yaml":
                s = yaml.safe_load(s)
        _init_from_dict__(self, s)

    def _str__(self):
        return json.dumps(vars(self), default=lambda x: vars(x), indent=2)

    setattr(cls, "__init__", _init__)
    setattr(cls, "__str__", _str__)

    return cls


def test_json():
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

    a = A({
        "key1": "1",
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
    })
    print(a)
    assert a.key1 == 1
    assert a.key2 == "val2"
    assert a.b.cs[0].key4 == "val4"
    assert a.bs[0].cs[0].key4 == "val4"

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
