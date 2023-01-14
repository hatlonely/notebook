package main

import (
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func main() {
	registry := prometheus.NewRegistry()
	prometheus.DefaultGatherer = registry
	prometheus.DefaultRegisterer = registry

	// counter 只能增加 Add/Inc 或者重置 Reset
	// namespace_subsystem_test_counter{key1="val1",key2="val2"} 6
	counter := promauto.NewCounterVec(prometheus.CounterOpts{
		Namespace:   "namespace",
		Subsystem:   "subsystem",
		Name:        "test_counter",
		ConstLabels: nil,
	}, []string{"key1", "key2"})

	counter.WithLabelValues("val1", "val2").Inc()
	counter.WithLabelValues("val1", "val2").Add(5)

	// gauge 可以增加 Add/Inc 也可以减少 Dec/Sub
	// namespace_subsystem_test_gauge{key0="val0",key1="val1",key2="val2"} 2
	gauge := promauto.NewGaugeVec(prometheus.GaugeOpts{
		Namespace:   "namespace",
		Subsystem:   "subsystem",
		Name:        "test_gauge",
		ConstLabels: map[string]string{"key0": "val0"},
	}, []string{"key1", "key2"})
	gauge.WithLabelValues("val1", "val2").Inc()
	gauge.WithLabelValues("val1", "val2").Add(5)
	gauge.WithLabelValues("val1", "val2").Dec()
	gauge.WithLabelValues("val1", "val2").Sub(3)

	// Histogram 近似计算分位数，效率高
	// - <name>_bucket: 值的分布，表示值小于等于 le 值的个数
	// - <name>_sum: 表示所有值的和，sum(values)
	// - <name>_count: 表示值的总数，count(values)
	//
	// histogram_quantile 可以根据 <name>_bucket 值的分布求分位数，是一个近似值
	// <name>_sum / <name_count> 可以求平均值
	// namespace_subsystem_test_histogram_bucket{key0="val0",key1="val1",key2="val2",le="1"} 1
	// namespace_subsystem_test_histogram_bucket{key0="val0",key1="val1",key2="val2",le="10"} 2
	// namespace_subsystem_test_histogram_bucket{key0="val0",key1="val1",key2="val2",le="100"} 4
	// namespace_subsystem_test_histogram_bucket{key0="val0",key1="val1",key2="val2",le="1000"} 6
	// namespace_subsystem_test_histogram_bucket{key0="val0",key1="val1",key2="val2",le="+Inf"} 6
	// namespace_subsystem_test_histogram_sum{key0="val0",key1="val1",key2="val2"} 1276
	// namespace_subsystem_test_histogram_count{key0="val0",key1="val1",key2="val2"} 6
	histogram := promauto.NewHistogramVec(prometheus.HistogramOpts{
		Namespace:   "namespace",
		Subsystem:   "subsystem",
		Name:        "test_histogram",
		ConstLabels: map[string]string{"key0": "val0"},
		Buckets:     []float64{1, 10, 100, 1000},
	}, []string{"key1", "key2"})
	histogram.WithLabelValues("val1", "val2").Observe(1)
	histogram.WithLabelValues("val1", "val2").Observe(10)
	histogram.WithLabelValues("val1", "val2").Observe(15)
	histogram.WithLabelValues("val1", "val2").Observe(100)
	histogram.WithLabelValues("val1", "val2").Observe(150)
	histogram.WithLabelValues("val1", "val2").Observe(1000)

	// Summary 准确计算分位数，加锁操作，性能差，不建议使用
	// - <name>: 分位数准确值
	// - <name>_sum: 表示所有值的和，sum(values)
	// - <name>_count: 表示值的总数，count(values)
	//
	// namespace_subsystem_test_summary{key1="val1",key2="val2",quantile="0.5"} 15
	// namespace_subsystem_test_summary{key1="val1",key2="val2",quantile="0.8"} 150
	// namespace_subsystem_test_summary{key1="val1",key2="val2",quantile="0.9"} 1000
	// namespace_subsystem_test_summary_sum{key1="val1",key2="val2"} 1176
	// namespace_subsystem_test_summary_count{key1="val1",key2="val2"} 5
	summary := promauto.NewSummaryVec(prometheus.SummaryOpts{
		Namespace: "namespace",
		Subsystem: "subsystem",
		Name:      "test_summary",
		Objectives: map[float64]float64{
			0.9: 0.1,
			0.8: 0.1,
			0.5: 0.1,
		},
		MaxAge:     10 * time.Second,
		AgeBuckets: 5,
		BufCap:     10,
	}, []string{"key1", "key2"})
	summary.WithLabelValues("val1", "val2").Observe(1)
	summary.WithLabelValues("val1", "val2").Observe(10)
	summary.WithLabelValues("val1", "val2").Observe(15)
	summary.WithLabelValues("val1", "val2").Observe(150)
	summary.WithLabelValues("val1", "val2").Observe(1000)

	http.Handle("/metrics", promhttp.Handler())
	if err := http.ListenAndServe(":8080", nil); err != nil {
		panic(err)
	}
}
