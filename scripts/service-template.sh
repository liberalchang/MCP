#!/bin/bash

# MCP服务扩展模板
# 用于快速添加新的MCP服务到启动脚本中

# 使用方法：
# 1. 复制此模板为新服务脚本
# 2. 修改服务相关参数
# 3. 在主启动脚本中调用新服务

# 新服务模板函数
template_start_mcp_service() {
    local service_name="$1"           # 服务名称，如 "File-Manager-MCP"
    local service_path="$2"           # 服务路径，如 "file-manager-mcp"  
    local main_script="$3"            # 主程序路径，如 "file_manager/__main__.py"
    local log_file="$4"               # 日志文件名，如 "file-manager-mcp.log"
    local service_port="$5"           # 服务端口，如 "8001"
    
    echo "启动 $service_name 服务..."
    
    # 检查服务目录
    if [ ! -d "/app/$service_path" ]; then
        echo "警告: /app/$service_path 目录不存在，跳过 $service_name"
        return 1
    fi
    
    cd "/app/$service_path"
    
    # 安装依赖
    if [ -f "requirements.txt" ]; then
        echo "安装 $service_name 依赖..."
        pip install -r requirements.txt
    fi
    
    # 安装包
    if [ -f "pyproject.toml" ] && grep -q "\[project\]" pyproject.toml; then
        echo "安装 $service_name 包..."
        pip install -e .
    fi
    
    # 启动服务
    if [ -f "$main_script" ]; then
        echo "运行 $service_name 主程序..."
        # 设置端口环境变量（如果服务需要）
        export SERVICE_PORT=$service_port
        nohup python "$main_script" > "/var/log/$log_file" 2>&1 &
        echo "$service_name 已启动，PID: $!，端口: $service_port"
        return 0
    else
        echo "错误: $main_script 不存在"
        return 1
    fi
}

# 示例：如何在主启动脚本中添加新服务
# 在 start.sh 中添加以下行：
# template_start_mcp_service "File-Manager-MCP" "file-manager-mcp" "file_manager/__main__.py" "file-manager-mcp.log" "8001"

echo "这是MCP服务扩展模板，请参考注释使用"
