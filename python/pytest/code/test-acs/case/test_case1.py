#!/usr/bin/env python3


def test_case1(environment):
    assert environment.options.oss.endpoint == "oss-cn-hangzhou.aliyuncs.com"
    assert environment.options.imm.endpoint == "imm.cn-hangzhou.aliyuncs.com"
