# 监控配置指南

本目录包含了完整的监控配置，用于监控分布式服务系统中的各种组件，包括图数据库、向量数据库和缓存服务等。

## 📁 目录结构

```
monitoring/
├── 📊 prometheus.yml                 # Prometheus主配置文件
├── 🚨 alertmanager.yml               # Alertmanager告警配置
├── 🔔 alerts/                        # 告警规则
│   ├── nebula.yml                   # Nebula图数据库监控告警
│   ├── qdrant.yml                   # Qdrant向量数据库监控告警
│   └── redis.yml                    # Redis缓存监控告警
├── 📈 grafana/                      # Grafana配置
│   ├── dashboards/                  # 仪表板配置
│   │   ├── nebula-graph-overview.json   # Nebula图数据库监控仪表板
│   │   ├── qdrant-overview.json         # Qdrant向量数据库监控仪表板
│   │   └── redis-overview.json          # Redis缓存监控仪表板
│   └── provisioning/               # 自动配置
│       ├── alerting/               # 告警配置
│       ├── dashboards/             # 仪表板自动加载配置
│       ├── datasources/            # 数据源配置
│       │   └── prometheus.yml      # Prometheus数据源
│       └── plugins/                # 插件配置
├── 🐳 docker-compose.monitoring.yml   # Docker Compose配置
├── 🚀 deploy-monitoring.ps1         # 部署脚本
├── ⚙️ setup-grafana.ps1            # Grafana设置脚本
├── 📄 docker-commands.txt          # Docker命令参考
└── 📖 README.md                     # 本指南
```

## 🎯 功能特性

### Nebula图数据库监控
- **集群状态**: 监控图数据库集群节点状态和健康度
- **查询性能**: 监控图查询的响应时间、吞吐量和错误率
- **存储指标**: 监控存储空间使用情况和数据分布
- **连接管理**: 监控客户端连接数和连接池状态
- **告警**: 集群节点宕机、查询延迟过高等告警

### Qdrant向量数据库监控
- **集合状态**: 监控向量集合的大小和状态
- **搜索性能**: 监控向量搜索的响应时间和准确率
- **存储指标**: 监控向量数据的存储使用情况和索引效率
- **内存使用**: 监控向量索引的内存占用情况
- **告警**: 搜索延迟过高、存储空间不足等告警

### Redis缓存监控
- **缓存性能**: 监控缓存命中率和响应时间
- **内存使用**: 监控内存使用量和键值对数量
- **连接管理**: 监控客户端连接数和连接状态
- **持久化**: 监控RDB和AOF持久化状态
- **告警**: 内存使用过高、连接数过多等告警

## 🚀 快速开始

### 1. 一键部署

```powershell
# 启动所有监控服务
.\deploy-monitoring.ps1 start

# 检查服务状态
.\deploy-monitoring.ps1 status

# 查看日志
.\deploy-monitoring.ps1 logs
```

### 2. 设置Grafana

```powershell
# 运行Grafana设置脚本
.\setup-grafana.ps1

# 脚本会自动：
# - 生成安全的Grafana管理员密码
# - 创建必要的Docker网络
# - 验证目录结构
# - 更新环境配置
```

### 3. 手动部署

#### 使用Docker Compose (WSL环境)

```powershell
# 启动监控服务
wsl -e bash -cl "cd /home/docker-compose/monitoring && docker-compose -f docker-compose.monitoring.yml up -d"

# 停止服务
wsl -e bash -cl "cd /home/docker-compose/monitoring && docker-compose -f docker-compose.monitoring.yml down"
```

#### 使用Docker命令参考

我们还提供了详细的Docker命令参考文件 `docker-commands.txt`，包含了完整的WSL环境下的操作命令：

```powershell
# 查看Docker命令参考
cat docker-commands.txt

# 按照命令参考执行操作
```

#### 验证配置

```bash
# 验证Prometheus配置
docker run --rm -v "$(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml" prom/prometheus promtool check config /etc/prometheus/prometheus.yml

# 验证告警规则
docker run --rm -v "$(pwd)/alerts:/etc/prometheus/alerts" prom/prometheus promtool check rules /etc/prometheus/alerts/*.yml
```

## 📊 访问地址

| 服务 | 地址 | 用户名/密码 |
|------|------|-------------|
| Prometheus | http://localhost:9090 | - |
| Grafana | http://localhost:3100 | admin/[see GRAFANA_ADMIN_PASSWORD in .env] |
| Alertmanager | http://localhost:9093 | - |

## 🔧 配置说明

### Prometheus配置

- **scrape_interval**: 30秒
- **evaluation_interval**: 15秒
- **数据保留**: 15天

### 告警规则

#### Nebula图数据库告警
- **集群节点宕机**: 有节点不可用，立即触发
- **查询延迟高**: P95查询时间 > 5秒，持续5分钟
- **连接数过多**: 活跃连接数 > 1000，持续10分钟
- **存储空间不足**: 存储使用率 > 85%，持续15分钟

#### Qdrant向量数据库告警
- **搜索延迟高**: P95搜索时间 > 2秒，持续5分钟
- **集合大小异常**: 集合大小超过阈值，持续10分钟
- **内存使用高**: 内存使用率 > 80%，持续10分钟
- **存储空间不足**: 存储使用率 > 85%，持续15分钟

#### Redis缓存告警
- **内存使用高**: 内存使用率 > 80%，持续5分钟
- **缓存命中率低**: 命中率 < 50%，持续10分钟
- **连接数过多**: 客户端连接数 > 1000，持续10分钟
- **持久化失败**: RDB或AOF持久化失败，立即触发

### Grafana仪表板

#### Nebula图数据库仪表板
- **集群概览**: 集群节点状态、健康度和运行时间
- **查询性能**: 图查询的QPS、P50/P95/P99延迟
- **存储指标**: 存储空间使用、数据分布和增长趋势
- **连接监控**: 客户端连接数、连接池状态和错误率
- **资源使用**: CPU、内存、磁盘IO使用情况

#### Qdrant向量数据库仪表板
- **集合概览**: 向量集合数量、大小和状态
- **搜索性能**: 向量搜索的QPS、延迟分布和准确率
- **存储指标**: 向量数据存储使用情况和索引效率
- **内存监控**: 向量索引内存占用和缓存命中率
- **资源使用**: CPU、内存、磁盘IO使用情况

#### Redis缓存仪表板
- **缓存概览**: 键值对数量、内存使用和命中率
- **性能指标**: 命令QPS、P50/P95/P99延迟
- **连接监控**: 客户端连接数、阻塞连接和错误率
- **持久化状态**: RDB和AOF持久化状态和性能
- **资源使用**: CPU、内存、网络IO使用情况

## 📈 常用查询

### Nebula图数据库查询

```promql
# 集群节点健康度
nebula_cluster_healthy_nodes / nebula_cluster_total_nodes * 100

# 查询QPS
rate(nebula_graphd_queries_total[5m])

# 平均查询延迟
rate(nebula_graphd_query_latency_us_sum[5m]) / rate(nebula_graphd_query_latency_us_count[5m]) / 1000

# 存储空间使用率
nebula_storaged_disk_usage_bytes / nebula_storaged_disk_capacity_bytes * 100
```

### Qdrant向量数据库查询

```promql
# 集合数量
qdrant_collections_total

# 搜索QPS
rate(qdrant_search_operations_total[5m])

# 平均搜索延迟
rate(qdrant_search_latency_ms_sum[5m]) / rate(qdrant_search_latency_ms_count[5m])

# 内存使用率
qdrant_memory_usage_bytes / qdrant_memory_capacity_bytes * 100
```

### Redis缓存查询

```promql
# 缓存命中率
redis_keyspace_hits_total / (redis_keyspace_hits_total + redis_keyspace_misses_total) * 100

# 命令QPS
rate(redis_commands_processed_total[5m])

# 平均命令延迟
rate(redis_commands_duration_seconds_sum[5m]) / rate(redis_commands_duration_seconds_count[5m])

# 内存使用率
redis_memory_used_bytes / redis_memory_max_bytes * 100
```

## 🛠️ 故障排除

### 常见问题

1. **服务无法启动**
   - 检查端口是否被占用
   - 验证配置文件格式
   - 查看服务日志

2. **指标未显示**
   - 确认应用服务已启动
   - 检查指标端点是否可访问
   - 验证Prometheus目标状态

3. **告警不触发**
   - 检查告警规则配置
   - 确认阈值设置
   - 查看Alertmanager日志

### 调试命令

```powershell
# 检查服务状态 (WSL环境)
wsl -e bash -cl "cd /home/docker-compose/monitoring && docker-compose -f docker-compose.monitoring.yml ps"

# 查看服务日志 (WSL环境)
wsl -e bash -cl "cd /home/docker-compose/monitoring && docker-compose -f docker-compose.monitoring.yml logs -f prometheus"
wsl -e bash -cl "cd /home/docker-compose/monitoring && docker-compose -f docker-compose.monitoring.yml logs -f grafana"
wsl -e bash -cl "cd /home/docker-compose/monitoring && docker-compose -f docker-compose.monitoring.yml logs -f alertmanager"

# 测试各服务的指标端点
# Prometheus自身指标
wsl -e bash -cl "cd /home/docker-compose/monitoring && curl -s http://localhost:9090/metrics | head -20"

# 测试Redis Exporter指标 (如果Redis服务已启动)
wsl -e bash -cl "cd /home/docker-compose/monitoring && curl -s http://localhost:9121/metrics | head -20"

# 查看Docker系统状态
wsl -e bash -cl "docker system df"
```

## 🔧 自定义配置

### 修改告警阈值

编辑对应的告警规则文件：
- `alerts/nebula.yml` - Nebula图数据库告警规则
- `alerts/qdrant.yml` - Qdrant向量数据库告警规则  
- `alerts/redis.yml` - Redis缓存告警规则

### 添加新指标

1. 在应用代码中添加指标收集
2. 更新Prometheus配置
3. 在Grafana中添加新的面板

### 配置通知

编辑 `alertmanager.yml` 配置邮件、Slack或其他通知渠道。

## 📚 相关文档

- [Nebula图数据库监控集成指南](docs/nebula-monitoring.md)
- [Qdrant向量数据库监控集成指南](docs/qdrant-monitoring.md)
- [Redis监控集成指南](docs/redis-monitoring.md)
- [Prometheus官方文档](https://prometheus.io/docs/)
- [Grafana官方文档](https://grafana.com/docs/)
- [Docker命令参考](docker-commands.txt) - 本项目专用的Docker命令集合

## 🤝 贡献

欢迎提交Issue和Pull Request来改进监控配置！