#!/usr/bin/env python3

import pytest


@pytest.fixture()
def setup():
    print("Setup")


@pytest.fixture()
def teardown():
    yield
    print("Teardown")


def test_setup_teardown(setup, teardown):
    print("Test")


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
