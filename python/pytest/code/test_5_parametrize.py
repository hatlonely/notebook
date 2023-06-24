#!/usr/bin/env python3

import pytest


@pytest.mark.parametrize("a,b,c", [
    (1, 2, 3),
    (4, 5, 9),
    pytest.param(1, 2, 4, marks=pytest.mark.xfail),
])
def test_parametrize(a, b, c):
    assert a + b == c


@pytest.mark.parametrize("a,b,c", [
    (1, 2, 3),
    (4, 5, 9),
    pytest.param(1, 2, 4, marks=pytest.mark.xfail),
])
class TestParametrize:
    def test_parametrize1(self, a, b, c):
        assert a + b == c

    def test_parametrize2(self, a, b, c):
        assert c - b == a
