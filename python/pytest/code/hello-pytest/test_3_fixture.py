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


@pytest.fixture()
def init_db_3():
    return []


@pytest.fixture(autouse=True)
def insert1(init_db_3):
    print("Insert 1")
    init_db_3.append(1)
    return init_db_3


@pytest.fixture(autouse=True)
def insert2(insert1):
    print("Insert 2")
    insert1.append(2)
    return insert1


def test_db_3(insert2):
    assert insert2 == [1, 2]


# 在一次测试调用中，fixture 只会执行一次
@pytest.fixture(scope="session")
def session_fixture():
    print("Session fixture")


def test_session_1(session_fixture):
    print("Test session 1")


def test_session_2(session_fixture):
    print("Test session 2")
