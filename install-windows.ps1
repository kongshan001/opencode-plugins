# ============================================
# OpenCode 一键部署脚本 (Windows PowerShell)
# ============================================

param(
    [string]$InstallDir = "$env:USERPROFILE\.opencode-plugins",
    [switch]$SkipMCP,
    [switch]$SkipSkills,
    [switch]$SkipPlugins,
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

# 配置目录：~/.config/opencode/
$ConfigDir = "$env:USERPROFILE\.config\opencode"
$SkillsDir = "$ConfigDir\skills"
$PluginsDir = "$ConfigDir\plugins"

function Write-Step($msg) { Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "[√] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[!] $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  OpenCode Plugins & Skills 一键部署" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 卸载模式
if ($Uninstall) {
    Write-Step "开始卸载..."
    
    if (Test-Path $SkillsDir) { Remove-Item $SkillsDir -Recurse -Force }
    if (Test-Path $PluginsDir) { Remove-Item $PluginsDir -Recurse -Force }
    if (Test-Path $InstallDir) { Remove-Item $InstallDir -Recurse -Force }
    
    Write-Success "卸载完成"
    exit 0
}

# 检查依赖
Write-Step "检查依赖..."
if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
    Write-Error "OpenCode 未安装"
    exit 1
}
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js 未安装"
    exit 1
}
Write-Success "依赖检查通过"

# 克隆/更新仓库
Write-Step "准备插件仓库..."
$repoUrl = "https://github.com/kongshan001/opencode-plugins.git"

if (Test-Path $InstallDir) {
    Set-Location $InstallDir
    git fetch origin
    git reset --hard origin/master
} else {
    git clone $repoUrl $InstallDir
}
Write-Success "插件仓库准备完成"

# 配置 MCP
if (-not $SkipMCP) {
    Write-Step "配置 MCP..."
    
    if (-not (Test-Path $ConfigDir)) { New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null }
    
    $opencodeConfig = "$ConfigDir\opencode.json"
    
    if (-not (Test-Path $opencodeConfig)) {
        @{
            '$schema' = 'https://opencode.ai/config.json'
            mcp = @{
                'prompt-monitor' = @{
                    type = 'local'
                    command = @('node', "$InstallDir\opencode-prompt-monitor\index.js")
                    enabled = $true
                }
            }
        } | ConvertTo-Json -Depth 10 | Set-Content $opencodeConfig -Encoding UTF8
        Write-Success "MCP 配置完成"
    } else {
        Write-Warn "opencode.json 已存在，跳过 MCP 配置"
    }
}

# 安装插件
if (-not $SkipPlugins) {
    Write-Step "安装插件..."
    
    if (-not (Test-Path $PluginsDir)) { New-Item -ItemType Directory -Path $PluginsDir -Force | Out-Null }
    
    $pluginSrc = "$InstallDir\opencode-prompt-monitor\plugin\index.js"
    if (Test-Path $pluginSrc) {
        Copy-Item $pluginSrc "$PluginsDir\prompt-monitor.js" -Force
        Write-Success "插件已安装: prompt-monitor"
    }
}

# 配置 Skills
if (-not $SkipSkills) {
    Write-Step "配置 Skills..."
    
    if (-not (Test-Path $SkillsDir)) { New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null }
    
    $roles = @('coordinator', 'planner', 'developer', 'reviewer', 'qa', 'doc-writer')
    foreach ($role in $roles) {
        $src = "$InstallDir\team-roles\$role\SKILL.md"
        if (Test-Path $src) {
            $destDir = "$SkillsDir\$role"
            if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
            Copy-Item $src "$destDir\SKILL.md" -Force
            Write-Host "  [√] $role" -ForegroundColor Green
        }
    }
    Write-Success "Skills 配置完成"
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  部署完成!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "配置目录: $ConfigDir" -ForegroundColor Cyan
Write-Host "Skills: $SkillsDir" -ForegroundColor Cyan
Write-Host "Plugins: $PluginsDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步:" -ForegroundColor Yellow
Write-Host "  1. 重启 OpenCode"
Write-Host "  2. 使用 /skill 查看可用技能"
Write-Host ""
