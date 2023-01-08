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

## 运算符

### 数值运算符

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

只能用在两个瞬时数据之间，集合运算通过指标名（metric）和标签（label）匹配

```promql
# 取 job="prometheus" 指标和指标值大于 5 的数据，作一个交集
(prometheus_http_requests_total{job="prometheus"}) and (prometheus_http_requests_total > 5)
```

### 三角函数

- `atan2`: 反正切


## 匹配模式

匹配模式指的是一个运算符作用在两个瞬时数据上时，可能会出现，一对一，一对多，多对一三种情况

```text
# 一对一匹配
<vector expr> <bin-op> ignoring(<label list>) <vector expr>
<vector expr> <bin-op> on(<label list>) <vector expr>

# 多对一
<vector expr> <bin-op> on(<label list>) group_left(<label list>) <vector expr>
<vector expr> <bin-op> ignoring(<label list>) group_left(<label list>) <vector expr>

# 一对多
<vector expr> <bin-op> on(<label list>) group_right(<label list>) <vector expr>
<vector expr> <bin-op> ignoring(<label list>) group_right(<label list>) <vector expr>
```

- `on`: 指定标签匹配
- `ignoring`: 忽略标签匹配
- `group_left`: 多对一匹配
- `group_right`: 一对多匹配

假设有我们有如下数据两个份瞬时数据

```text
# 错误请求数据
method_code:http_errors:rate5m{method="get", code="500"}  24
method_code:http_errors:rate5m{method="get", code="404"}  30
method_code:http_errors:rate5m{method="put", code="501"}  3
method_code:http_errors:rate5m{method="post", code="500"} 6
method_code:http_errors:rate5m{method="post", code="404"} 21

# 总请求数据
method:http_requests:rate5m{method="get"}  600
method:http_requests:rate5m{method="del"}  34
method:http_requests:rate5m{method="post"} 120
```

上例中有两个指标: 

- `method_code:http_errors:rate5m`: 错误请求数据，有两个标签，`method` 和 `code`
- `method:http_requests:rate5m`: 总请求数据，只有一个标签 `method`

**场景一**: 计算 code="500" 分 method 的失败率

```text
method_code:http_errors:rate5m{code="500"} / ignoring(code) method:http_requests:rate5m
```

这里涉及两个瞬时数据 `method_code:http_errors:rate5m{code="500"}` 500 错误请求数据和 `method:http_requests:rate5m` 总请求数据。
`method_code:http_errors:rate5m{code="500"}` 数据的标签比 `method:http_requests:rate5m` 数据标签多了 code，
表达式 `method_code:http_errors:rate5m{code="500"} / method:http_requests:rate5m` 无法直接匹配，
这个时候可以指定 `ignoring(code)` 在匹配的时候忽略 `code` 这个标签

**场景二**: 计算分 `code` 分 `method` 的失败率

```text
method_code:http_errors:rate5m / ignoring(code) group_left method:http_requests:rate5m
```

`method_code:http_errors:rate5m` 中多条分 code 的数据对应 `method:http_requests:rate5m` 中的一条数据，
表达式 `method_code:http_errors:rate5m / ignoring(code) method:http_requests:rate5m` 无法直接匹配，
这个时候可以指定 `group_left` 来表示进行多对一匹配



## 参考链接

- 查询语法: <https://prometheus.io/docs/prometheus/latest/querying/basics/>
