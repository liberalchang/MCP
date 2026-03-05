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
start_mcp_service "Daily-Hot-MCP" "daily-hot-mcp" "daily_hot_mcp/__main__.py" "daily-hot-mcp.log"

# 等待服务启动
echo "等待服务启动..."
sleep 5

# 检查服务状态
echo "=== 服务状态检查 ==="
if pgrep -f "daily_hot_mcp/__main__.py" > /dev/null; then
    echo "✅ Daily Hot MCP 服务运行正常"
else
    echo "❌ Daily Hot MCP 服务启动失败"
    exit 1
fi

# 显示运行中的服务
echo "=== 运行中的MCP服务 ==="
ps aux | grep -E "(daily_hot_mcp|python.*mcp)" | grep -v grep || echo "没有找到运行中的MCP服务"

echo "=== 启动完成 ==="
echo "所有MCP服务已启动，日志文件位于 /var/log/"
echo "Daily Hot MCP 访问地址: http://localhost:8000/mcp"

# 保持容器运行
echo "监控服务状态中..."
while true; do
    # 检查关键服务是否还在运行
    if ! pgrep -f "daily_hot_mcp/__main__.py" > /dev/null; then
        echo "[$(date)] 警告: Daily Hot MCP 服务已停止，尝试重启..."
        start_mcp_service "Daily-Hot-MCP" "daily-hot-mcp" "daily_hot_mcp/__main__.py" "daily-hot-mcp.log"
    fi
    
    # 每分钟输出一次状态
    echo "[$(date)] MCP服务运行中..."
    sleep 60
done
