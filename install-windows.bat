@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ============================================
:: OpenCode 一键部署脚本 (Windows)
:: ============================================

echo ============================================
echo   OpenCode Plugins & Skills 一键部署
echo ============================================
echo.

:: 检查是否以管理员运行
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] 建议以管理员身份运行此脚本
    echo.
)

:: 配置变量
set "REPO_URL=https://github.com/kongshan001/opencode-plugins.git"
set "INSTALL_DIR=%USERPROFILE%\.opencode-plugins"
set "OPENCODE_CONFIG_DIR=%APPDATA%\opencode"

echo [1/5] 检查 OpenCode 是否已安装...
where opencode >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] OpenCode 未安装
    echo [!] 请先安装 OpenCode: https://opencode.ai
    echo.
    pause
    exit /b 1
)
echo [√] OpenCode 已安装

echo.
echo [2/5] 克隆插件仓库...
if exist "%INSTALL_DIR%" (
    echo [*] 仓库已存在，正在更新...
    cd /d "%INSTALL_DIR%"
    git pull
) else (
    git clone "%REPO_URL%" "%INSTALL_DIR%"
)
echo [√] 插件仓库准备完成

echo.
echo [3/5] 配置 MCP (Prompt Monitor)...
if not exist "%OPENCODE_CONFIG_DIR%" mkdir "%OPENCODE_CONFIG_DIR%"

:: 检查是否已有 mcp.json
if exist "%OPENCODE_CONFIG_DIR%\mcp.json" (
    echo [*] 备份现有 mcp.json...
    copy "%OPENCODE_CONFIG_DIR%\mcp.json" "%OPENCODE_CONFIG_DIR%\mcp.json.bak"
)

:: 创建新的 mcp.json
(
echo {
echo   "mcpServers": {
echo     "prompt-monitor": {
echo       "command": "node",
echo       "args": ["%INSTALL_DIR%\opencode-prompt-monitor\index.js"]
echo     }
echo   }
echo }
) > "%OPENCODE_CONFIG_DIR%\mcp.json"

echo [√] MCP 配置完成

echo.
echo [4/5] 配置 Skills...
if not exist "%OPENCODE_CONFIG_DIR%\opencode.json" (
    echo [*] 创建 opencode.json...
    (
    echo {
    echo   "$schema": "https://opencode.ai/config.json",
    echo   "skills": {
    echo     "paths": ["%INSTALL_DIR%\team-roles"]
    echo   }
    echo }
    ) > "%OPENCODE_CONFIG_DIR%\opencode.json"
) else (
    echo [*] 更新 opencode.json...
    :: 这里需要更复杂的 JSON 合并逻辑，暂时跳过
    echo [!] 请手动添加 skills 配置到 opencode.json
    echo    添加以下内容:
    echo    ^, "skills": { "paths": ["%INSTALL_DIR%\team-roles"] ^}
)
echo [√] Skills 配置完成

echo.
echo [5/5] 启动 Prompt Monitor MCP 服务...
:: 检查 Node.js
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Node.js 未安装，请先安装 Node.js
) else (
    :: 检查是否已运行
    netstat -ano | findstr ":3847" >nul
    if %errorlevel% equ 0 (
        echo [*] MCP 服务已在运行
    ) else (
        start "" node "%INSTALL_DIR%\opencode-prompt-monitor\index.js"
        timeout /t 2 /nobreak >nul
        echo [√] MCP 服务已启动
    )
)

echo.
echo ============================================
echo   部署完成!
echo ============================================
echo.
echo 配置文件位置: %OPENCODE_CONFIG_DIR%
echo 插件目录: %INSTALL_DIR%
echo.
echo 下一步:
echo   1. 重启 OpenCode 使配置生效
echo   2. 使用命令测试 MCP:
echo      curl http://localhost:3847/health
echo.
echo 团队角色 Skills 位置:
echo   %INSTALL_DIR%\team-roles\
echo.
pause
