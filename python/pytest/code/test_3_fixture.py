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
