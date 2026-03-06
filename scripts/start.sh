#!/bin/bash

# MCP服务统一启动脚本
# 用于在容器内启动所有MCP服务

set -e  # 遇到错误立即退出

echo "=== MCP服务启动脚本 ==="
echo "启动时间: $(date)"

# 确保日志目录存在
mkdir -p /var/log

# 安装健康检查所需的依赖
pip install requests

# 函数：启动MCP服务
start_mcp_service() {
    local service_name=$1
    local service_path=$2
    local main_script=$3
    local log_file=$4
    
    echo "启动 $service_name 服务..."
    
    if [ ! -d "/app/$service_path" ]; then
        echo "警告: /app/$service_path 目录不存在，跳过 $service_name"
        return 1
    fi
    
    cd "/app/$service_path"
    
    # 加载.env文件到环境变量
    if [ -f ".env" ]; then
        echo "加载环境变量文件: .env"
        export $(cat .env | grep -v '^#' | xargs)
    else
        echo "警告: 未找到 .env 文件"
    fi
    
    # 检查并安装依赖
    if [ -f "requirements.txt" ]; then
        echo "安装 $service_name 依赖..."
        pip install -r requirements.txt
    fi
    
    # 检查并安装包
    if [ -f "pyproject.toml" ] && grep -q "\[project\]" pyproject.toml; then
        echo "安装 $service_name 包..."
        pip install -e .
    fi
    
    # 启动服务
    if [ -f "$main_script" ]; then
        echo "运行 $service_name 主程序..."
        nohup python "$main_script" > "/var/log/$log_file" 2>&1 &
        echo "$service_name 已启动，PID: $!"
        return 0
    else
        echo "错误: $main_script 不存在"
        return 1
    fi
}

# 启动Daily Hot MCP服务
# 注意：需要先在 config/daily-hot-mcp.env 中配置真实的 FIRECRAWL_API_KEY
start_mcp_service "Daily-Hot-MCP" "daily-hot-mcp" "daily_hot_mcp/__main__.py" "daily-hot-mcp.log"

echo "=== 启动完成 ==="
echo "所有MCP服务已启动，日志文件位于 /var/log/"
echo "Daily Hot MCP 访问地址: http://localhost:8000/mcp"
echo "服务健康检查由Docker容器自动管理"

# 保持容器运行
echo "容器保持运行中..."
while true; do
    echo "[$(date)] 容器运行中，健康检查由Docker管理..."
    sleep 300  # 每5分钟输出一次状态
done
