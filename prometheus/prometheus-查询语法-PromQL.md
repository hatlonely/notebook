# prometheus 查询语法 PromQL

## 4种数据类型

在 PromQL 中，一个表达式可以表示四种类型

- `瞬时向量（Instant vector）`: 最近时间的采样信息

```text
promhttp_metric_handler_requests_total
{job="prometheus",code=200}
promhttp_metric_handler_requests_total{job="prometheus"}
```

- `区间向量（Range vector）`: 一段时间内采样信息，样例

```text
promhttp_metric_handler_requests_total{job="prometheus"}[1h]
promhttp_metric_handler_requests_total{job="prometheus"}[1h] offset 5m
```

- `Scalar`: 浮点数值

```text
23
-2.43
3.4e-9
0x8f
-Inf
NaN
```

- `String`: 字符串值

```text
"hello world"
'hello world'
`hello world`
```

## 参考链接

- 查询语法: <https://prometheus.io/docs/prometheus/latest/querying/basics/>
