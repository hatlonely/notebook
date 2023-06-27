#!/usr/bin/env python3

def add(a, b):
    return a + b


def test_add():
    assert add(1, 2) == 3
    assert add(1, 1) == 2
    assert add(1, 0) == 1
