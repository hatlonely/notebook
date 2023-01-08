# prometheus 查询语法 PromQL

## 基本语法

在 PromQL 中，一个表达式可以表示四种类型

- `瞬时向量（Instant vector）`: 一个时间点的采样信息

```promql
prometheus_http_requests_total
{job="prometheus",code=200}
prometheus_http_requests_total{job="prometheus"}
```

- `区间数据（Range vector）`: 一段时间内采样信息，相当于瞬时向量的集合

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
- 瞬时向量和标量之间，表示瞬时向量中的每条数据的值都和标量进行运算
- 两个瞬时向量之间，表示两个瞬时向量对应的数据的值进行运算

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
- 瞬时向量和标量之间，表示瞬时向量中的每条数据的值都和标量运算，如果计算结果为 `false`，这条数据会被过滤掉
- 两个瞬时向量，表示两个瞬时向量对应的数据的值进行运算，如果计算结果为 `false`，这条数据会被过滤掉

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

只能用在两个瞬时向量之间，集合运算通过指标名（metric）和标签（label）匹配

```promql
# 取 job="prometheus" 指标和指标值大于 5 的数据，作一个交集
(prometheus_http_requests_total{job="prometheus"}) and (prometheus_http_requests_total > 5)
```

### 三角函数

- `atan2`: 反正切

### 运算符优先级

```text
^
*, /, %, atan2
+, -
==, !=, <=, <, >=, >
and, unless
or
```

## 匹配模式

匹配模式指的是一个运算符作用在两个瞬时向量上时，可能会出现，一对一，一对多，多对一三种情况

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

假设有我们有如下数据两个份瞬时向量

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

这里涉及两个瞬时向量 `method_code:http_errors:rate5m{code="500"}` 500 错误请求数据和 `method:http_requests:rate5m` 总请求数据。
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

## 聚合运算

prometheus 提供一些聚合方法支持更丰富的计算，其语法结构如下

```text
<aggr-op> [without|by (<label list>)] ([parameter,] <vector expression>)
<aggr-op>([parameter,] <vector expression>) [without|by (<label list>)]
```

维度选择可以通过 `by` 指定，也可以通过 `without` 排除

聚合运算只能作用于瞬时向量（instant-vector），返回新的（instant-vector），类似于 SQL 中的 `group by` 操作

- `sum`: 维度求和
- `min`: 维度求最小值
- `max`: 维度求最大值
- `avg`: 维度求平均值
- `group`: 维度求标准差
- `stddev`: 维度求标准差
- `stdvar`: 维度求标准方差
- `count`: 维度求记录数量
- `count_values`: 维度求相同值记录数量
- `bottomk`: 最小的 k 个值
- `topk`: 最大的 k 个值
- `quantile`: 分位数

样例

```text
sum without (instance) (http_requests_total)
sum by (application, group) (http_requests_total)
sum(http_requests_total)
count_values("version", build_version)
topk(5, http_requests_total)
```

## 函数

- `absent(v instant-vector) -> instant-vector | none`: 如果瞬时向量有任何值，则返回空，如果没有值，返回一条数据，其值为 1。这个函数在设置告警的时候很有用
- `absent_over_time(v range-vector) -> instant-vector | none`: 和 `absent` 类似，参数为范围向量
- `changes(v range-vector) -> instant-vector`: 范围向量变化的次数
- `clamp(v instant-vector, min scalar, max scalar) -> instant-vector`: 如果值小于 min，这只为 min，如果大于 max 设置为 max
- `clamp_max(v instant-vector, max scalar) -> instant-vector`: 如果值大于 max 设置为 max
- `clamp_min(v instant-vector, min scalar) -> instant-vector`: 如果值小于 min 设置为 min
- `day_of_month(v=vector(time()) instant-vector) -> instant-vector`: UTC 时间中的所在月份中的第几天，取值 `[1, 31]`，`time.day_of_month`
- `day_of_week(v=vector(time()) instant-vector) -> instant-vector`: UTC 时间中的星期几，取值 `[0, 6]`，0 表示周日，`time.day_of_week`
- `day_of_year(v=vector(time()) instant-vector) -> instant-vector`: UTC 时间中的一年中的第几天，取值 `[1, 366]`，`time.day_of_year`
- `days_in_month(v=vector(time()) instant-vector) -> instant-vector`: UTC 时间所在月份的天数，取值 `[28, 31]`，`time.days_in_month`
- `hour(v=vector(time()) instant-vector) -> instant-vector`: UTC 时间中的小时，取值 `[0, 23]`，`time.hour`
- `minute(v=vector(time()) instant-vector) -> instant-vector`: UTC 时间中的分钟，取值 `[0, 59]`，`time.minute`
- `year(v=vector(time()) instant-vector) -> instant-vector`: UTC 时间中的年份，`time.year`
- `month(v=vector(time()) instant-vector) -> instant-vector`: UTC 时间中的月份，取值 `[1, 12]`，`time.month`
- `label_join(v instant-vector, dst_label string, separator string, src_label_1 string, src_label_2 string, ...) -> instant-vector`: 新增标签，标签值通过其他标签用逗号合并
- `label_replace(v instant-vector, dst_label string, replacement string, src_label string, regex string) -> instant-vector`: 替换或新增标签，支持正则替换
- `ceil(v instant-vector) -> instant-vector`: 向上取整
- `round(v instant-vector, to_nearest=1 scalar)`: 四舍五入
- `floor(v instant-vector) -> instant-vector`: 向下取整
- `abs(v instant-vector) -> instant-vector`: 绝对值
- `exp(v instant-vector) -> instant-vector`: 返回 e 的次方，`exp(value)`
- `ln(v instant-vector) -> instant-vector`: 返回 e 的对数，`ln(value)`
- `log2(v instant-vector) -> instant-vector`: 返回 2 的对数，`log2(value)`
- `log10(v instant-vector) -> instant-vector`: 返回 10 的对数，`log10(value)`
- `sqrt(v instant-vector) -> instant-vector`: 返回平方根，`sqrt(value)`
- `delta(v range-vector) -> instant-vector`: 返回最后一个值和第一个值的差，`v[-1].value - v[0].value`
- `idelta(v range-vector) -> instant-vector`: 返回最后两个值的差，`v[-1].value - v[-2].value`
- `increase(v range-vector) -> instant-vector`: 区间内最后一个值和第一个值的差，`v[-1].value - v[0].value`
- `irate(v range-vector) -> instant-vector`: 区间内最后一个值和倒数第二个值的差再除以时间，`(v[-1].value - v[-2].value) / (v[-1].time - v[-2].time)`
- `rate(v range-vector) -> instant-vector`: 区间内最后一个值和第一个值的差再除以时间，`(v[-1].value - v[0].value) / (v[-1].time - v[0].time)`
- `resets(v range-vector) -> instant-vector`: 计数器重置的次数。计数器重置指的是连续样本之间的单调性发生变化
- `scalar(v instant-vector) -> scalar`: 如果 v 中只有一个元素，返回这个元素的值，否则返回 NAN，`if len(v) == 1 ? v[0].value else NAN`
- `sgn(v instant-vector) -> instant-vector`: 获取值的符号。大于0，返回1；小于0，返回-1；等于0，返回0
- `sort(v instant-vector) -> instant-vector`: 按值升序排序
- `sort_desc(v instant-vector) -> instant-vector`: 按值降序排序
- `time() -> scalar`: 返回当前的时间戳
- `timestamp(v instant-vector) -> instant-vector`: 获取时间戳，`time`
- `vector(s scalar) -> vector`: 返回没有标签的 vector
- `deriv(v range-vector) -> range-vector`: 使用线性回归计算各个时间序列的导数
- `predict_linear`: 
- `histogram_count(v instant-vector)`:
- `histogram_sum(v instant-vector)`: 
- `histogram_fraction(lower scalar, upper scalar, v instant-vector)`: 
- `histogram_quantile(φ scalar, b instant-vector)`: 
- `holt_winters(v range-vector, sf scalar, tf scalar)`: 

### 聚合函数

- `avg_over_time(v range-vector) -> instant-vector`: 求平均值
- `min_over_time(v range-vector) -> instant-vector`: 求最小值
- `max_over_time(v range-vector) -> instant-vector`: 求最大值
- `sum_over_time(v range-vector) -> instant-vector`: 求和
- `count_over_time(v range-vector) -> instant-vector`: 计数
- `quantile_over_time(s scalar, v range-vector) -> instant-vector`: 求分位数
- `stddev_over_time(v range-vector) -> instant-vector`: 求方差
- `stdvar_over_time(v range-vector) -> instant-vector`: 求标准差
- `last_over_time(v range-vector) -> instant-vector`: 求最近一个点
- `present_over_time(v range-vector) -> instant-vector`:

### 三角函数

- `acos(v instant-vector) -> instant-vector`: 反余弦
- `asin(v instant-vector) -> instant-vector`: 反正弦
- `atan(v instant-vector) -> instant-vector`: 反正切
- `acosh(v instant-vector) -> instant-vector`: 反双曲余弦
- `asinh(v instant-vector) -> instant-vector`: 反双曲正弦
- `atanh(v instant-vector) -> instant-vector`: 反双曲正切
- `cos(v instant-vector) -> instant-vector`: 余弦
- `sin(v instant-vector) -> instant-vector`: 正弦
- `tan(v instant-vector) -> instant-vector`: 正切
- `cosh(v instant-vector) -> instant-vector`: 双曲余弦
- `sinh(v instant-vector) -> instant-vector`: 双曲正弦
- `tanh(v instant-vector) -> instant-vector`: 双曲正切
- `deg(v instant-vector) -> instant-vector`: 弧度转角度
- `pi() -> scalar`: 返回 π
- `rad(v instant-vector) -> instant-vector`: 角度转弧度


## 参考链接

- 查询语法: <https://prometheus.io/docs/prometheus/latest/querying/basics/>
