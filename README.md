# MCP Docker 生产环境

基于Docker的MCP服务统一部署环境，所有MCP服务在同一个Python 3.11容器中运行，适合生产环境使用。

## 📥 快速开始

### 1. 克隆仓库
```bash
# 克隆MCP主仓库
git clone https://github.com/liberalchang/MCP.git
cd MCP

# 一步到位：克隆并初始化子模块
git clone --recurse-submodules https://github.com/liberalchang/MCP.git
cd MCP
```

### 2. 初始化子模块
```bash
# 如果没有使用 --recurse-submodules，手动初始化
git submodule update --init --recursive
```

### 3. 启动服务
```bash
# Windows
mcp-manage.bat start

# Linux/Mac
chmod +x mcp-manage.sh
./mcp-manage.sh start
```

### 4. 访问服务
- Daily Hot MCP: http://localhost:13001/mcp

---

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

## Git子模块管理

### 子模块结构
当前项目使用Git子模块管理MCP服务：
```
MCP/
├── .gitmodules              # 子模块配置文件
├── liberalchang-daily-hot-mcp/  # Daily Hot MCP子模块
└── ...
```

### 常用子模块命令

#### 添加新的子模块
```bash
# 添加新的MCP服务作为子模块
git submodule add https://github.com/liberalchang/new-mcp-service.git new-mcp-service

# 添加特定分支的子模块
git submodule add -b develop https://github.com/liberalchang/new-mcp-service.git new-mcp-service
```

#### 更新子模块
```bash
# 更新所有子模块到最新提交
git submodule update --remote

# 更新特定子模块
git submodule update --remote liberalchang-daily-hot-mcp

# 合并子模块的最新更改
git submodule foreach git pull origin main
```

#### 切换子模块分支
```bash
# 进入子模块目录
cd liberalchang-daily-hot-mcp

# 切换到其他分支
git checkout develop

# 返回主仓库
cd ..

# 查看子模块状态
git submodule status
```

#### 提交子模块更改
```bash
# 进入子模块目录进行更改
cd liberalchang-daily-hot-mcp
# ... 进行代码更改 ...
git add .
git commit -m "更新子模块功能"
cd ..

# 在主仓库中记录子模块的更新
git add liberalchang-daily-hot-mcp
git commit -m "更新Daily Hot MCP子模块版本"
git push
```

### 子模块故障排除

#### 1. 子模块处于分离HEAD状态
```bash
# 进入子模块目录
cd liberalchang-daily-hot-mcp

# 检查当前状态
git status

# 切换到主分支
git checkout main

# 返回主仓库
cd ..
```

#### 2. 子模块目录为空
```bash
# 重新初始化子模块
git submodule deinit -f liberalchang-daily-hot-mcp
git submodule update --init --recursive liberalchang-daily-hot-mcp
```

#### 3. 子模块同步问题
```bash
# 强制重置子模块
git submodule foreach git reset --hard

# 清理子模块未跟踪的文件
git submodule foreach git clean -fd
```

### 自动化脚本

创建子模块更新脚本 `scripts/update-submodules.sh`：
```bash
#!/bin/bash
echo "更新所有MCP子模块..."

# 更新所有子模块
git submodule update --remote --recursive

# 检查是否有更新
if git diff --quiet HEAD; then
    echo "没有子模块更新"
else
    echo "检测到子模块更新，提交更改..."
    git add .
    git commit -m "自动更新子模块到最新版本"
    git push
    echo "子模块更新已提交"
fi
```

### CI/CD集成

在GitHub Actions中自动更新子模块：
```yaml
name: Update Submodules
on:
  schedule:
    - cron: '0 2 * * *'  # 每天凌晨2点更新
jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          submodules: recursive
      - name: Update submodules
        run: |
          git submodule update --remote --recursive
          if ! git diff --quiet HEAD; then
            git config --global user.name 'github-actions[bot]'
            git config --global user.email 'github-actions[bot]@users.noreply.github.com'
            git add .
            git commit -m "Auto update submodules"
            git push
          fi
```
