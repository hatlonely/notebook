#!/usr/bin/env python3

# 自定义断言消息
def pytest_assertrepr_compare(op, left, right):
    if isinstance(left, str) and isinstance(right, str) and op == "==":
        return ["Comparing two strings:", "   vals: %s != %s" % (left, right)]
