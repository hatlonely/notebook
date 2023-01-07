# prometheus 数据模型

prometheus 主要存储时序数据：一个指标在多种维度下不同时间的数值

## 数据模型

一条时序数据包括几个部分：

- `timestamp`: 时间戳，毫秒级别
- `metric`: 指标名，需要满足正则表达式，`[a-zA-Z_:][a-zA-Z0-9_:]*`
- `value`: 指标值，浮点型
- `label=value`: 维度，一条数据可以有多个维度，label 满足正则表达式 `[a-zA-Z_][a-zA-Z0-9_]*`

## 命名规范



## 参考链接

- 数据模型: <https://prometheus.io/docs/concepts/data_model/>
- 命名规范: <https://prometheus.io/docs/practices/naming/>