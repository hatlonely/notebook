#!/usr/bin/env python3

import time


def simple_decorator(func):
    def wrapper():
        print('Before call')
        func()
        print('After call')

    return wrapper


def test_simple_decorator():
    def hello():
        print('Hello world')

    hello = simple_decorator(hello)
    hello()
    print('Done')


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


def test_retry():
    @retry(times=5, delay=0.05)
    def hello():
        print('Hello world')
        raise Exception('Timeout')

    hello()
