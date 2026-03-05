#!/bin/bash

# MCP服务管理脚本 - 生产环境

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

case "$1" in
    start)
        echo "启动MCP服务..."
        docker-compose -f "$DOCKER_COMPOSE_FILE" up -d
        echo "等待服务启动..."
        sleep 15
        echo "检查服务状态："
        docker-compose -f "$DOCKER_COMPOSE_FILE" ps
        ;;
        
    stop)
        echo "停止MCP服务..."
        docker-compose -f "$DOCKER_COMPOSE_FILE" down
        ;;
        
    restart)
        echo "重启MCP服务..."
        docker-compose -f "$DOCKER_COMPOSE_FILE" restart
        ;;
        
    status)
        echo "MCP服务状态："
        docker-compose -f "$DOCKER_COMPOSE_FILE" ps
        ;;
        
    logs)
        if [ -z "$2" ]; then
            echo "查看所有服务日志..."
            docker-compose -f "$DOCKER_COMPOSE_FILE" logs -f
        else
            echo "查看服务 $2 的日志..."
            docker-compose -f "$DOCKER_COMPOSE_FILE" logs -f "$2"
        fi
        ;;
        
    exec)
        echo "进入MCP服务容器..."
        docker exec -it mcp-services bash
        ;;
        
    health)
        echo "检查服务健康状态..."
        echo "Daily Hot MCP (13001):"
        curl -f http://localhost:13001/mcp/ 2>/dev/null && echo "✅ 正常" || echo "❌ 异常"
        ;;
        
    *)
        echo "MCP服务管理脚本"
        echo "用法: $0 {start|stop|restart|status|logs|exec|health}"
        echo ""
        echo "命令说明："
        echo "  start   - 启动所有MCP服务"
        echo "  stop    - 停止所有MCP服务"
        echo "  restart - 重启所有MCP服务"
        echo "  status  - 查看服务状态"
        echo "  logs    - 查看服务日志 [service_name]"
        echo "  exec    - 进入服务容器"
        echo "  health  - 检查服务健康状态"
        exit 1
        ;;
esac
