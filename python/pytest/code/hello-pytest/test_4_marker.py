#!/usr/bin/env python3

import sys
import warnings

import pytest


# 跳过
# Output:
# test_4_marker.py::test_skip SKIPPED (test skip)                          [100%]
# Skipped: test skip
@pytest.mark.skip(reason="test skip")
def test_skip():
    assert True


# 条件跳过
# Output:
# test_4_marker.py::test_skipif SKIPPED (test skipif)                      [100%]
# Skipped: test skipif
@pytest.mark.skipif(1 > 0, reason="test skipif")
def test_skipif():
    assert True


# 标记为预期失败
@pytest.mark.xfail(reason="test xfail")
def test_xfail():
    assert False


# 标记为满足条件预期失败
@pytest.mark.xfail(sys.platform == "win32", reason="test xfail")
def test_xfail_condition():
    assert False


# 参数化。同一个函数，多组 case
@pytest.mark.parametrize("a,b,c", [(1, 2, 3), (4, 5, 9)])
def test_parametrize(a, b, c):
    assert a + b == c


# 忽略警告
@pytest.mark.filterwarnings("ignore:api v1")
def test_filterwarnings():
    def api_v1():
        warnings.warn(UserWarning("api v1"))
        return 1

    assert api_v1() == 1


# 使用 fixture
# fixture 需要定义在 conftest.py 中
@pytest.mark.usefixtures("custom_fixture")
def test_fixture():
    assert True


@pytest.mark.slow
def test_custom_slow():
    assert True
