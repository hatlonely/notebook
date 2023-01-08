# prometheus 查询语法 PromQL

## 基本语法

在 PromQL 中，一个表达式可以表示四种类型

- `瞬时数据（Instant vector）`: 一个时间点的采样信息

```text
prometheus_http_requests_total
{job="prometheus",code=200}
prometheus_http_requests_total{job="prometheus"}
```

- `区间数据（Range vector）`: 一段时间内采样信息，相当于瞬时数据的集合

```text
prometheus_http_requests_total{job="prometheus"}[1h]
prometheus_http_requests_total{job="prometheus"}[1h] offset 5m
```

- `标量（Scalar）`: 浮点数值

```text
23
-2.43
3.4e-9
0x8f
-Inf
NaN
```

- `字符串（String）`: 字符串值

```text
"hello world"
'hello world'
`hello world`
```

## 操作符

### 二元运算符

- `+`: 加
- `-`: 减
- `*`: 乘
- `/`: 除
- `%`: 取模
- `^`: 次方



## 参考链接

- 查询语法: <https://prometheus.io/docs/prometheus/latest/querying/basics/>
