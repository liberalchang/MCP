#!/bin/bash

# MCP子模块更新脚本
# 用于批量更新所有MCP服务子模块

set -e  # 遇到错误立即退出

echo "=== MCP子模块更新脚本 ==="
echo "更新时间: $(date)"

# 检查是否在Git仓库中
if [ ! -d ".git" ]; then
    echo "错误: 当前目录不是Git仓库"
    exit 1
fi

# 检查是否有子模块
if [ ! -f ".gitmodules" ]; then
    echo "警告: 没有找到.gitmodules文件，可能没有子模块"
    exit 0
fi

# 备份当前状态
echo "备份当前子模块状态..."
git submodule status > /tmp/submodules-backup-$(date +%Y%m%d-%H%M%S).txt

# 更新所有子模块
echo "开始更新所有子模块..."
git submodule update --remote --recursive

# 检查是否有更新
if git diff --quiet HEAD -- .gitmodules; then
    echo "✅ 没有子模块更新"
    echo "当前子模块状态："
    git submodule status
    exit 0
fi

echo "🔄 检测到子模块更新"

# 显示更新内容
echo "更新的子模块："
git diff --name-only HEAD .gitmodules

# 显示子模块状态
echo "更新后的子模块状态："
git submodule status

# 询问是否提交
read -p "是否提交这些更新？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "正在提交子模块更新..."
    
    # 配置Git用户信息（如果未配置）
    if [ -z "$(git config user.name)" ]; then
        git config user.name "MCP Updater"
        git config user.email "mcp-updater@example.com"
    fi
    
    # 添加更改
    git add .
    
    # 提交更改
    git commit -m "自动更新子模块到最新版本 - $(date '+%Y-%m-%d %H:%M:%S')"
    
    # 推送到远程仓库
    if git remote get-url origin > /dev/null 2>&1; then
        echo "推送到远程仓库..."
        git push origin main
        echo "✅ 子模块更新已推送到远程仓库"
    else
        echo "⚠️  没有配置远程仓库，仅本地提交"
    fi
    
    echo "🎉 子模块更新完成！"
else
    echo "❌ 已取消提交"
    echo "如需手动提交，请运行："
    echo "git add ."
    echo "git commit -m '更新子模块版本'"
    echo "git push"
fi

# 显示最终状态
echo ""
echo "=== 最终子模块状态 ==="
git submodule status
