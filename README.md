# MCP Docker 生产环境

基于Docker的MCP服务统一部署环境，所有MCP服务在同一个Python 3.11容器中运行，适合生产环境使用。

## 架构特点

- **统一容器**: 所有MCP服务在同一个Python 3.11容器中运行
- **资源优化**: 减少容器数量，节省系统资源
- **易于扩展**: 只需添加文件映射和启动命令即可增加新服务
- **生产就绪**: 包含健康检查、日志管理和自动重启

## 服务架构

### MCP统一服务容器 (`mcp-services`)
- **Python版本**: 3.11-slim
- **容器名称**: `mcp-services`
- **网络**: 自定义bridge网络
- **重启策略**: `unless-stopped`
- **健康检查**: 30秒间隔检查服务状态

### 当前运行的服务
1. **Daily Hot MCP** (端口13001)
   - 全网热点趋势聚合服务
   - 访问地址: http://localhost:13001/mcp

## 快速启动

### Windows环境
```cmd
# 使用管理脚本启动
mcp-manage.bat start

# 或使用docker-compose
docker-compose up -d
```

### Linux/Mac环境
```bash
# 给脚本执行权限
chmod +x mcp-manage.sh

# 使用管理脚本启动
./mcp-manage.sh start

# 或使用docker-compose
docker-compose up -d
```

## 服务管理

### 管理脚本命令
```bash
# Windows
mcp-manage.bat start    # 启动服务
mcp-manage.bat stop     # 停止服务
mcp-manage.bat restart  # 重启服务
mcp-manage.bat status   # 查看状态
mcp-manage.bat logs     # 查看日志
mcp-manage.bat exec     # 进入容器
mcp-manage.bat health   # 健康检查

# Linux/Mac
./mcp-manage.sh start
./mcp-manage.sh stop
./mcp-manage.sh restart
./mcp-manage.sh status
./mcp-manage.sh logs
./mcp-manage.sh exec
./mcp-manage.sh health
```

## 添加新MCP服务

### 步骤1: 映射服务代码
在 `docker-compose.yml` 的 volumes 部分添加：
```yaml
volumes:
  - ./liberalchang-daily-hot-mcp:/app/liberalchang-daily-hot-mcp
  - ./config:/app/config
  - ./scripts:/app/scripts
  # 添加新服务映射
  - ./your-new-mcp:/app/your-new-mcp
```

### 步骤2: 映射端口
在 ports 部分添加：
```yaml
ports:
  - "13001:8000"  # Daily Hot MCP
  - "13002:8001"  # 新服务端口
```

### 步骤3: 更新启动脚本
在 `scripts/start.sh` 中添加新服务启动：
```bash
# 在现有服务启动后添加
start_mcp_service "Your-New-MCP" "your-new-mcp" "your_mcp/__main__.py" "your-new-mcp.log"
```

或者使用模板函数（参考 `scripts/service-template.sh`）：
```bash
# 复制模板函数到 start.sh 中
template_start_mcp_service "Your-New-MCP" "your-new-mcp" "your_mcp/__main__.py" "your-new-mcp.log" "8001"
```

### 步骤4: 创建配置文件
在 `config/` 目录创建环境配置：
```bash
# config/your-new-mcp.env
API_KEY=your_api_key
SERVICE_PORT=8001
```

## 端口规划

| 服务 | 端口 | 容器内部端口 | 状态 |
|------|------|-------------|------|
| Daily Hot MCP | 13001 | 8000 | 已启用 |
| File Manager MCP | 13002 | 8001 | 预留 |
| Database MCP | 13003 | 8002 | 预留 |
| Web Scraper MCP | 13004 | 8003 | 预留 |
| Code Analyzer MCP | 13005 | 8004 | 预留 |

## 配置文件

### 环境变量配置
- `./config/daily-hot-mcp.env` - Daily Hot MCP配置
- `./config/mcp-services.conf` - 服务扩展配置模板

### 日志管理
所有服务日志输出到容器内的 `/var/log/` 目录：
- `/var/log/daily-hot-mcp.log` - Daily Hot MCP日志

## 监控和维护

### 健康检查
```bash
# 检查所有服务状态
./mcp-manage.sh health

# 手动检查特定服务
curl -f http://localhost:13001/mcp/
```

### 日志查看
```bash
# 查看所有服务日志
docker-compose logs -f

# 进入容器查看详细日志
docker exec -it mcp-services bash
tail -f /var/log/daily-hot-mcp.log
```

## 故障排除

### 1. 服务启动失败
```bash
# 查看详细日志
docker-compose logs mcp-services

# 进入容器调试
docker exec -it mcp-services bash
```

### 2. 端口冲突
修改 `docker-compose.yml` 中的端口映射，避免端口冲突。

### 3. 依赖安装问题
进入容器手动安装依赖：
```bash
docker exec -it mcp-services bash
cd /app/liberalchang-daily-hot-mcp
pip install -r requirements.txt
```

## 生产环境优化建议

1. **资源限制**: 根据需要添加CPU和内存限制
2. **日志轮转**: 配置logrotate防止日志文件过大
3. **监控告警**: 集成Prometheus/Grafana监控
4. **备份策略**: 定期备份配置和数据
5. **安全加固**: 限制网络访问，使用HTTPS
