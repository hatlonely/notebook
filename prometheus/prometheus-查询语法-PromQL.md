# prometheus 查询语法 PromQL

## 基本语法

在 PromQL 中，一个表达式可以表示四种类型

- `瞬时数据（Instant vector）`: 一个时间点的采样信息

```promql
prometheus_http_requests_total
{job="prometheus",code=200}
prometheus_http_requests_total{job="prometheus"}
```

- `区间数据（Range vector）`: 一段时间内采样信息，相当于瞬时数据的集合

```promql
prometheus_http_requests_total{job="prometheus"}[1h]
prometheus_http_requests_total{job="prometheus"}[1h] offset 5m
```

- `标量（Scalar）`: 浮点数值

```promql
23
-2.43
3.4e-9
0x8f
-Inf
NaN
```

- `字符串（String）`: 字符串值

```promql
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

这些运算符三种使用场景：

- 两个标量之间，表示正常的二元运算
- 瞬时数据和标量之间，表示瞬时数据中的每条数据的值都和标量进行运算
- 两个瞬时数据之间，表示两个瞬时数据对应的数据的值进行运算

```promql
# 返回标量 2
1 + 1

# 当前时刻的每个值都 + 5
prometheus_http_requests_total + 5

# 将 5 分钟之前的值和 10 分钟之前的相加
(prometheus_http_requests_total offset 5m) + (prometheus_http_requests_total offset 10m)
```

### 比较运算符

- `==`: 相等
- `!=`: 不等
- `> `: 大于
- `< `: 小于
- `>=`: 大于等于
- `<=`: 小于等于

这些运算符同样也有三种使用场景：

- 两个标量之间，表示正常的比较运算，无法直接运行
- 瞬时数据和标量之间，表示瞬时数据中的每条数据的值都和标量运算，如果计算结果为 `false`，这条数据会被过滤掉
- 两个瞬时数据，表示两个瞬时数据对应的数据的值进行运算，如果计算结果为 `false`，这条数据会被过滤掉

```promql
# 只取数据大于 5 的数据
prometheus_http_requests_total offset 60m > 5

# 只取 5 分钟之前和 10 分钟之前相等的数据
(prometheus_http_requests_total offset 5m) == (prometheus_http_requests_total offset 10m)
```

### 集合运算符

- `and`: 交集
- `or`: 并集
- `unless`: 差集

只能用在两个瞬时数据之间

### 三角函数

- `atan2`: 反正切


## 参考链接

- 查询语法: <https://prometheus.io/docs/prometheus/latest/querying/basics/>
