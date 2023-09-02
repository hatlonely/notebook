# markdown mermaid gantt 甘特图

```mermaid
gantt
  title 甘特图
  dateFormat YYYY-MM-DD
  excludes weekdays

  section person1
    task1: done, t1, 2019-01-01, 2019-01-03
    task2: active, t2, 2019-01-04, 3d
    task3: t3, after t2, 5d

  section person2
    task1: done, t1, 2019-01-01, 2019-01-03
    task4: crit, t4, after t2, 2d
    task5: t5, after t4, 3d
```

- 任务后面描述：[status], [tag], [startDate], [duration|endDate]
- 任务状态：
    - done: 已完成（灰色）
    - active: 进行中（浅蓝）
    - crit: 风险（红色）
    - 无：未开始（紫）

## 参考链接

- [mermaid Gantt diagrams](https://mermaid.js.org/syntax/gantt.html)
