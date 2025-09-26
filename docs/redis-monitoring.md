# Redis监控集成指南

本文档描述如何将Redis缓存服务集成到监控系统中。

## 概述

Redis监控通过redis_exporter收集指标，提供缓存性能、内存使用、连接状态、持久化等关键监控数据。

## 集成步骤

### 1. 部署redis_exporter

确保redis_exporter已部署并配置正确：

```yaml
# docker-compose.redis.yml
services:
  redis-exporter:
    image: oliver006/redis_exporter:latest
    command:
      - --redis.addr=redis://redis:6379
      - --web.listen-address=0.0.0.0:9121
    ports:
      - "9121:9121"
    depends_on:
      - redis
```

### 2. 配置Prometheus

在prometheus.yml中添加Redis任务：

```yaml
scrape_configs:
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']
        labels:
          service: 'redis'
```

### 3. 验证指标

检查指标是否正常收集：

```bash
curl http://localhost:9121/metrics | grep redis
```

## 关键指标

| 指标名称 | 描述 | 类型 |
|---------|------|------|
| redis_up | Redis连接状态 | gauge |
| redis_connected_clients | 客户端连接数 | gauge |
| redis_memory_used_bytes | 内存使用量 | gauge |
| redis_keyspace_hits_total | 键空间命中次数 | counter |
| redis_keyspace_misses_total | 键空间未命中次数 | counter |
| redis_commands_processed_total | 处理命令总数 | counter |
| redis_rdb_last_save_timestamp_seconds | 最后一次RDB保存时间 | gauge |

## 告警配置

参考 `alerts/redis.yml` 中的告警规则，包括：
- 内存使用监控
- 缓存命中率检查
- 连接数限制
- 持久化状态监控

## 故障排除

1. **连接失败**：检查Redis服务和redis_exporter配置
2. **指标异常**：验证Redis运行状态和权限设置
3. **性能问题**：监控内存使用和命令处理情况