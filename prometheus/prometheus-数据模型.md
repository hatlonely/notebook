# prometheus 数据模型

prometheus 主要存储时序数据：一个指标在多种维度下不同时间的数值

## 数据模型

一条时序数据包括几个部分：

- `timestamp`: 时间戳，毫秒级别
- `metric`: 指标名，需要满足正则表达式，`[a-zA-Z_:][a-zA-Z0-9_:]*`
- `value`: 指标值，浮点型
- `label=value`: 维度，一条数据可以有多个维度，label 满足正则表达式 `[a-zA-Z_][a-zA-Z0-9_]*`

## 命名规范

### 指标名

`<namespace>_<name>_<unit>`

- namespace: 命名空间，一般为应用程序名
- name: 指标名称，比如 `memory_usage`
- unit: 指标单位，比如 `seconds`

样例

```text
process_cpu_seconds_total
http_request_duration_seconds
http_requests_total
node_memory_usage_bytes
process_cpu_seconds_total
```

### 维度

用标签来区分不同的维度

样例：

```text
operation="create|update|delete"
stage="extract|transform|load"
```

### 基本单位

- seconds: 时间单位，秒
- celsius: 温度单位，摄氏度
- meters: 长度单位，米
- bytes: 数据大小，字节数
- ratio: 百分比，值为 0-1
- total: 累加值

## 参考链接

- 数据模型: <https://prometheus.io/docs/concepts/data_model/>
- 命名规范: <https://prometheus.io/docs/practices/naming/>