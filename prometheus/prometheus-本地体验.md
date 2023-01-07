# prometheus 本地体验

## 本地部署

### Mac

下载 prometheus 并启动

```shell
wget https://github.com/prometheus/prometheus/releases/download/v2.41.0/prometheus-2.41.0.darwin-amd64.tar.gz
tar -xzvf prometheus-2.41.0.darwin-amd64.tar.gz
cd prometheus-2.41.0.darwin-amd64
./prometheus
```

## Web UI

通过 <http://localhost:9090> 访问 Prometheus 的 web 界面，可以查询到 Prometheus server 本身的一些指标，比如

```text
promhttp_metric_handler_requests_total
```

## 配置文件

prometheus 的配置文件为 `prometheus.yml`

```yaml
global:  # 全局配置
  scrape_interval:     15s  # 数据拉取间隔
  evaluation_interval: 15s  # 规则计算间隔，规则计算用于告警

rule_files:  # 告警规则
  # - "first.rules"
  # - "second.rules"

scrape_configs:  # 数据抓取规则
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
```

## 参考链接

- 下载链接: <https://prometheus.io/download/>
