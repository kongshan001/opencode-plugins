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

echo [1/5] 检查 OpenCode 是否已安装...
where opencode >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] OpenCode 未安装，请先安装 OpenCode
    pause
    exit /b 1
)
echo [√] OpenCode 已安装

echo.
echo [2/5] 克隆/更新插件仓库...
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
echo [3/5] 配置 MCP (Prompt Monitor)...
if not exist "%OPENCODE_CONFIG_DIR%" mkdir "%OPENCODE_CONFIG_DIR%"

:: 创建 opencode.json（如果不存在）
set "CONFIG_FILE=%OPENCODE_CONFIG_DIR%\opencode.json"
if not exist "%CONFIG_FILE%" (
    echo {"$schema":"https://opencode.ai/config.json","mcp":{"prompt-monitor":{"type":"local","command":["node","%INSTALL_DIR:\=\\%\opencode-prompt-monitor\index.js"],"enabled":true}}} > "%CONFIG_FILE%"
    echo [√] MCP 配置完成
) else (
    echo [*] opencode.json 已存在，如需配置 MCP 请手动添加
    echo     路径: %CONFIG_FILE%
)

echo.
echo [4/5] 配置 Skills...
if not exist "%SKILLS_DIR%" mkdir "%SKILLS_DIR%"

:: 复制每个角色到 skills 目录
for %%r in (coordinator planner developer reviewer qa doc-writer) do (
    if exist "%INSTALL_DIR%\team-roles\%%r\SKILL.md" (
        if not exist "%SKILLS_DIR%\%%r" mkdir "%SKILLS_DIR%\%%r"
        copy /Y "%INSTALL_DIR%\team-roles\%%r\SKILL.md" "%SKILLS_DIR%\%%r\SKILL.md" >nul 2>&1
        if !errorlevel! equ 0 echo [√] 已安装: %%r
    )
)
echo [√] Skills 配置完成

echo.
echo [5/5] 完成...

echo.
echo ============================================
echo   部署完成!
echo ============================================
echo.
echo 插件目录: %INSTALL_DIR%
echo Skills目录: %SKILLS_DIR%
echo.
echo 下一步:
echo   1. 重启 OpenCode 使配置生效
echo   2. 使用 /skill 查看可用技能
echo.
pause
