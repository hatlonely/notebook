from inspect import signature


class Calculator:
    def add(self, a, b):
        return a + b

    def mul(self, a, b):
        return a * b


def test_calculator():
    c = Calculator()
    assert c.add(1, 2) == 3


def for_all_methods(decorator):
    def decorate(cls):
        for attr in cls.__dict__:
            if callable(getattr(cls, attr)):
                setattr(cls, attr, decorator(getattr(cls, attr)))
        return cls

    return decorate


def log(caller):
    def call_by_log(*args, **kwargs):
        sign = signature(caller)
        print(sign.parameters.items())
        print(list(sign.parameters.keys())[1:])
        print(caller)
        print(*args[1:], kwargs)
        res = caller(*args, **kwargs)
        print(res)
        return res

    return call_by_log


def test_calculator():
    c = for_all_methods(log)(Calculator)()
    assert c.add(1, 2) == 3
