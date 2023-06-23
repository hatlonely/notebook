#!/usr/bin/env python3

import pytest


# 断言
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


# 异常
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


# 自定义断言消息。自定义消息在 conftest 中定义
def test_assertrepr_compare():
    assert "123" == "456"
