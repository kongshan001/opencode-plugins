@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ============================================
:: OpenCode 一键部署脚本 (Windows CMD)
:: ============================================

echo ============================================
echo   OpenCode Plugins & Skills 一键部署
echo ============================================
echo.

:: 配置变量
set "REPO_URL=https://github.com/kongshan001/opencode-plugins.git"
set "INSTALL_DIR=%USERPROFILE%\.opencode-plugins"
set "OPENCODE_CONFIG_DIR=%APPDATA%\opencode"
set "SKILLS_DIR=%APPDATA%\opencode\skills"
set "PLUGINS_DIR=%APPDATA%\opencode\plugins"

echo [1/6] 检查 OpenCode 是否已安装...
where opencode >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] OpenCode 未安装，请先安装 OpenCode
    pause
    exit /b 1
)
echo [√] OpenCode 已安装

echo.
echo [2/6] 检查 Node.js...
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Node.js 未安装，请先安装 Node.js
    pause
    exit /b 1
)
echo [√] Node.js 已安装

echo.
echo [3/6] 克隆/更新插件仓库...
if exist "%INSTALL_DIR%" (
    echo [*] 仓库已存在，正在更新...
    cd /d "%INSTALL_DIR%"
    git fetch origin
    git reset --hard origin/master
) else (
    git clone "%REPO_URL%" "%INSTALL_DIR%"
)
echo [√] 插件仓库准备完成

echo.
echo [4/6] 配置 MCP (Prompt Monitor)...
if not exist "%OPENCODE_CONFIG_DIR%" mkdir "%OPENCODE_CONFIG_DIR%"

set "CONFIG_FILE=%OPENCODE_CONFIG_DIR%\opencode.json"
if not exist "%CONFIG_FILE%" (
    echo {"$schema":"https://opencode.ai/config.json","mcp":{"prompt-monitor":{"type":"local","command":["node","%INSTALL_DIR:\=\\%\opencode-prompt-monitor\index.js"],"enabled":true}}} > "%CONFIG_FILE%"
    echo [√] MCP 配置完成
) else (
    echo [*] opencode.json 已存在，跳过 MCP 配置
)

echo.
echo [5/6] 安装插件...
if not exist "%PLUGINS_DIR%" mkdir "%PLUGINS_DIR%"

:: 复制插件
if exist "%INSTALL_DIR%\opencode-prompt-monitor\plugin\index.js" (
    copy /Y "%INSTALL_DIR%\opencode-prompt-monitor\plugin\index.js" "%PLUGINS_DIR%\prompt-monitor.js" >nul 2>&1
    echo [√] 插件已安装: prompt-monitor
)

echo.
echo [6/6] 配置 Skills...
if not exist "%SKILLS_DIR%" mkdir "%SKILLS_DIR%"

for %%r in (coordinator planner developer reviewer qa doc-writer) do (
    if exist "%INSTALL_DIR%\team-roles\%%r\SKILL.md" (
        if not exist "%SKILLS_DIR%\%%r" mkdir "%SKILLS_DIR%\%%r"
        copy /Y "%INSTALL_DIR%\team-roles\%%r\SKILL.md" "%SKILLS_DIR%\%%r\SKILL.md" >nul 2>&1
        if !errorlevel! equ 0 echo [√] 已安装: %%r
    )
)

echo.
echo ============================================
echo   部署完成!
echo ============================================
echo.
echo 插件目录: %INSTALL_DIR%
echo MCP 配置: %CONFIG_FILE%
echo Skills目录: %SKILLS_DIR%
echo 插件目录: %PLUGINS_DIR%
echo.
echo 下一步:
echo   1. 重启 OpenCode 使配置生效
echo   2. 使用 /skill 查看可用技能
echo   3. 使用 prompt-monitor 工具获取 prompt 次数
echo.
pause
