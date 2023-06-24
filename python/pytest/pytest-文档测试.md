# pytest 文档测试

文档测试是一种测试方法，它可以从文档中提取代码片段并执行它们，然后检查结果是否与文档中的预期结果相匹配。python
默认支持这样的测试，pytest 也对这种测试提供了支持。

## 使用

1. 编写测试文档 `test_9_doctests.txt`

```text
hello this is a doctest
>>> x = 3
>>> x
3
```

2. 运行测试

```shell
pytest test_9_doctests.txt
```

## 文档测试

- [pytest 官网文档](https://docs.pytest.org/en/7.3.x/how-to/doctest.html)
- [python3 文档测试](https://docs.python.org/3/library/doctest.html)
