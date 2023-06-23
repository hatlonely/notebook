#!/usr/bin/env python3

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


def sum2(*args):
    return sum(*args)


def test_sum2():
    assert sum2(1, 2) == 3
    assert sum2(1, 2, 3) == 6
    assert sum2(1, 2, 3, 4, 5) == 15
    assert sum2(1, 2, 3, 4, 5, 6) == 21


def introduce(**kwargs):
    for key, value in kwargs.items():
        print(key, value)
    return kwargs.get("name") + " " + str(kwargs.get("age"))


def test_introduce():
    assert introduce(name="Tom", age=18) == "Tom 18"
    assert introduce(name="Jerry", age=20) == "Jerry 20"


def introduce2(**kwargs):
    return introduce(**kwargs)


def test_introduct2():
    assert introduce2(name="Tom", age=18) == "Tom 18"
    assert introduce2(name="Jerry", age=20) == "Jerry 20"
