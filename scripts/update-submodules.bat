@echo off
REM MCP子模块更新脚本 - Windows版本

echo === MCP子模块更新脚本 ===
echo 更新时间: %date% %time%

REM 检查是否在Git仓库中
if not exist ".git" (
    echo 错误: 当前目录不是Git仓库
    pause
    exit /b 1
)

REM 检查是否有子模块
if not exist ".gitmodules" (
    echo 警告: 没有找到.gitmodules文件，可能没有子模块
    pause
    exit /b 0
)

REM 备份当前状态
echo 备份当前子模块状态...
git submodule status > "submodules-backup-%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%%time:~6,2%.txt"

REM 更新所有子模块
echo 开始更新所有子模块...
git submodule update --remote --recursive

REM 检查是否有更新
git diff --quiet HEAD .gitmodules
if !errorlevel! equ 0 (
    echo ✅ 没有子模块更新
    echo 当前子模块状态：
    git submodule status
    pause
    exit /b 0
)

echo 🔄 检测到子模块更新

REM 显示更新内容
echo 更新的子模块：
git diff --name-only HEAD .gitmodules

REM 显示子模块状态
echo 更新后的子模块状态：
git submodule status

REM 询问是否提交
set /p commit_choice="是否提交这些更新？(y/N): "
if /i "%commit_choice%"=="y" (
    echo 正在提交子模块更新...
    
    REM 添加更改
    git add .
    
    REM 提交更改
    git commit -m "自动更新子模块到最新版本 - %date% %time%"
    
    REM 推送到远程仓库
    git remote get-url origin >nul 2>&1
    if !errorlevel! equ 0 (
        echo 推送到远程仓库...
        git push origin main
        echo ✅ 子模块更新已推送到远程仓库
    ) else (
        echo ⚠️  没有配置远程仓库，仅本地提交
    )
    
    echo 🎉 子模块更新完成！
) else (
    echo ❌ 已取消提交
    echo 如需手动提交，请运行：
    echo git add .
    echo git commit -m "更新子模块版本"
    echo git push
)

REM 显示最终状态
echo.
echo === 最终子模块状态 ===
git submodule status

pause
