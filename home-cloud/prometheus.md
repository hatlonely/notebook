# prometheus

## 常见错误

**现象**: 异常重启之后， prometheus-kube-prometheus-stack-prometheus-0 启动不起来，报 `opening storage failed: lock DB` 错误
**解决**: 去 nas 中删除文件 `monitoring-prometheus-kube-prometheus-stack-prometheus-db-prometheus-kube-prometheus-stack-prometheus-0-pvc-f0778b1a-5e5a-4423-b1e2-2fc865c3f660/prometheus-db/lock`
