# OpenCode Plugins 一键部署脚本 (Windows PowerShell)

Write-Host "🚀 开始部署 OpenCode Plugins..." -ForegroundColor Cyan

# 检查命令
function Test-Command {
    param($cmd)
    $exists = Get-Command $cmd -ErrorAction SilentlyContinue
    if (-not $exists) {
        Write-Host "错误: $cmd 未安装" -ForegroundColor Red
        exit 1
    }
}

# 获取脚本所在目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) {
    $ScriptDir = $PSScriptRoot
}
if (-not $ScriptDir) {
    $ScriptDir = Get-Location
}

# 转换为正斜杠路径（JSON 中需要）
$ScriptDirNormalized = $ScriptDir -replace '\\', '/'

Write-Host "📋 检查依赖..." -ForegroundColor Yellow
Test-Command "node"
Test-Command "npm"

# 安装 MCP 服务器依赖
Write-Host "📦 安装 MCP 服务器依赖..." -ForegroundColor Yellow
Set-Location "$ScriptDir\mcp-server"
npm install

# 返回主目录
Set-Location $ScriptDir

# 创建本地插件目录
$PluginDir = "$env:USERPROFILE\.config\opencode\plugins"
if (-not (Test-Path $PluginDir)) {
    Write-Host "📁 创建插件目录: $PluginDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $PluginDir -Force | Out-Null
}

# 复制插件
Write-Host "📋 安装插件..." -ForegroundColor Yellow
Copy-Item "plugins\demo-plugin.js" "$PluginDir\" -Force
Write-Host "✓ 插件已安装" -ForegroundColor Green

# 创建配置
$ConfigFile = "$env:USERPROFILE\.config\opencode\opencode.json"
Write-Host "⚙️ 创建 OpenCode 配置..." -ForegroundColor Yellow

# 备份现有配置
if (Test-Path $ConfigFile) {
    Copy-Item $ConfigFile "$ConfigFile.backup" -Force
    Write-Host "✓ 已备份现有配置" -ForegroundColor Yellow
}

# 生成配置（使用正斜杠路径）
$ConfigContent = @"
{
  "\$schema": "https://opencode.ai/config.json",
  "mcp": {
    "demo-mcp": {
      "type": "local",
      "command": ["node", "$ScriptDirNormalized/mcp-server/index.js"],
      "enabled": true
    }
  },
  "plugin": [
    "$ScriptDirNormalized/plugins/demo-plugin.js"
  ]
}
"@

# 确保目录存在
$ConfigDir = Split-Path $ConfigFile -Parent
if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
}

Set-Content -Path $ConfigFile -Value $ConfigContent -Encoding UTF8
Write-Host "✓ 配置已创建" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 部署完成！" -ForegroundColor Green
Write-Host ""
Write-Host "请重启 OpenCode 以加载插件和 MCP 服务器" -ForegroundColor Cyan
Write-Host ""
Write-Host "可用工具:" -ForegroundColor White
Write-Host "  - hello <name>     : 打招呼"
Write-Host "  - echo <text>     : 回显文本"
Write-Host "  - getTime         : 获取服务器时间"
Write-Host "  - calculate       : 计算器 (add/subtract/multiply/divide)"
Write-Host "  - get_date        : 获取日期时间"
Write-Host "  - reverse_text    : 反转文本"
Write-Host "  - get_server_info : 服务器信息"

Write-Host ""
Write-Host "提示: 如果遇到执行策略问题，请用管理员运行:" -ForegroundColor Yellow
Write-Host "      Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Gray
