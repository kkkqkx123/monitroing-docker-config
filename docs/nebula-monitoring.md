# Nebula图数据库监控集成指南

本文档描述如何将Nebula图数据库集成到监控系统中。

## 概述

Nebula图数据库监控通过nebula-stats-exporter收集指标，提供集群状态、查询性能、存储使用等关键监控数据。

## 集成步骤

### 1. 部署nebula-stats-exporter

确保nebula-stats-exporter已部署并配置正确：

```yaml
# docker-compose.nebula.yml
services:
  nebula-stats-exporter:
    image: vesoft/nebula-stats-exporter:v3.3.0
    command:
      - --bare-metal
      - --nebula-address=nebula-graphd:9669
      - --port=9100
    ports:
      - "9200:9100"
```

### 2. 配置Prometheus

在prometheus.yml中添加Nebula任务：

```yaml
scrape_configs:
  - job_name: 'nebula'
    static_configs:
      - targets: ['nebula-stats-exporter:9100']
        labels:
          service: 'nebula'
```

### 3. 验证指标

检查指标是否正常收集：

```bash
curl http://localhost:9200/metrics | grep nebula
```

## 关键指标

| 指标名称 | 描述 | 类型 |
|---------|------|------|
| nebula_cluster_healthy_nodes | 健康节点数量 | gauge |
| nebula_graphd_queries_total | 查询总数 | counter |
| nebula_graphd_query_latency_us | 查询延迟 | histogram |
| nebula_storaged_disk_usage_bytes | 存储使用量 | gauge |

## 告警配置

参考 `alerts/nebula.yml` 中的告警规则，包括：
- 集群节点健康度检查
- 查询性能监控
- 存储空间预警

## 故障排除

1. **指标未显示**：检查nebula-stats-exporter状态和配置
2. **连接失败**：验证Nebula服务地址和端口
3. **权限问题**：确保有足够的权限访问Nebula集群