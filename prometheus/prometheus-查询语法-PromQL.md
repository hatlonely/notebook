# prometheus 查询语法 PromQL

## 4种数据类型

在 PromQL 中，一个表达式可以表示四种类型

- `瞬时向量（Instant vector）`: 最近时间的采样信息

```text
http_requests_total
{job="prometheus",method="get"}
http_requests_total{job="prometheus",group="canary"}
http_requests_total{environment=~"staging|testing|development",method!="GET"}
```

- `区间向量（Range vector）`: 一段时间内采样信息，样例

```text
http_requests_total{job="prometheus"}[5m]
http_requests_total offset 5m
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
