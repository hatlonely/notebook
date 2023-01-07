# prometheus 查询语法 PromQL

## 4种数据类型

在 PromQL 中，一个表达式可以表示四种类型

- `瞬时向量（Instant vector）`: 最近时间的采样信息，样例 `http_requests_total`
- `区间向量（Range vector）`: 一段时间内采样信息，样例 `http_requests_total{job="prometheus"}[5m]`
- `Scalar`: 浮点数值，样例 `3.4e-9`
- `String`: 字符串值，`"hello world", 'hello world'`

## 参考链接

- 查询语法: <https://prometheus.io/docs/prometheus/latest/querying/basics/>
