# Qdrant向量数据库监控集成指南

本文档描述如何将Qdrant向量数据库集成到监控系统中。

## 概述

Qdrant向量数据库监控通过内置的metrics端点提供性能指标，支持向量搜索性能、集合状态、资源使用等关键监控数据。

## 集成步骤

### 1. 启用Qdrant指标

确保Qdrant服务已启用metrics端点：

```yaml
# docker-compose.qdrant.yml
services:
  qdrant:
    image: qdrant/qdrant:latest
    ports:
      - "6333:6333"     # REST API
      - "6334:6334"     # gRPC
      - "9090:9090"     # metrics端点
    environment:
      - QDRANT__TELEMETRY_ENABLED=true
```

### 2. 配置Prometheus

在prometheus.yml中添加Qdrant任务：

```yaml
scrape_configs:
  - job_name: 'qdrant'
    static_configs:
      - targets: ['qdrant:9090']
        labels:
          service: 'qdrant'
```

### 3. 验证指标

检查指标是否正常收集：

```bash
curl http://localhost:9090/metrics | grep qdrant
```

## 关键指标

| 指标名称 | 描述 | 类型 |
|---------|------|------|
| qdrant_collections_total | 集合总数 | gauge |
| qdrant_points_total | 向量点总数 | gauge |
| qdrant_search_operations_total | 搜索操作总数 | counter |
| qdrant_search_latency_ms | 搜索延迟 | histogram |
| qdrant_memory_usage_bytes | 内存使用量 | gauge |

## 告警配置

参考 `alerts/qdrant.yml` 中的告警规则，包括：
- 搜索性能监控
- 内存使用预警
- 集合状态检查

## 故障排除

1. **指标未显示**：检查Qdrant metrics端点是否启用
2. **连接失败**：验证Qdrant服务状态和端口配置
3. **性能问题**：监控搜索延迟和资源使用情况