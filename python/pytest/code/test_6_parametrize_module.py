#!/usr/bin/env python3

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
