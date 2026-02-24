# ============================================
# OpenCode 一键部署脚本 (Windows PowerShell)
# ============================================

param(
    [string]$InstallDir = "$env:USERPROFILE\.opencode-plugins",
    [switch]$SkipMCP,
    [switch]$SkipSkills,
    [switch]$StartService,
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Step($msg) {
    Write-Host "[*] $msg" -ForegroundColor Cyan
}

function Write-Success($msg) {
    Write-Host "[√] $msg" -ForegroundColor Green
}

function Write-Warn($msg) {
    Write-Host "[!] $msg" -ForegroundColor Yellow
}

function Write-Err($msg) {
    Write-Host "[X] $msg" -ForegroundColor Red
}

# 颜色配置
$cyan = "Cyan"
$green = "Green"
$yellow = "Yellow"
$red = "Red"

Write-Host ""
Write-Host "============================================" -ForegroundColor $cyan
Write-Host "  OpenCode Plugins & Skills 一键部署" -ForegroundColor $cyan
Write-Host "============================================" -ForegroundColor $cyan
Write-Host ""

# 卸载模式
if ($Uninstall) {
    Write-Step "开始卸载..."
    
    # 停止 MCP 服务
    $proc = Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*opencode-prompt-monitor*" }
    if ($proc) {
        Stop-Process -Id $proc.Id -Force
        Write-Success "MCP 服务已停止"
    }
    
    # 删除配置
    $mcpConfig = "$env:APPDATA\opencode\mcp.json"
    if (Test-Path $mcpConfig) {
        Remove-Item $mcpConfig -Force
        Write-Success "MCP 配置已删除"
    }
    
    Write-Success "卸载完成"
    exit 0
}

# 检查 OpenCode
Write-Step "检查 OpenCode..."
try {
    $opencodeVersion = & opencode --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "OpenCode 已安装: $opencodeVersion"
    }
} catch {
    Write-Err "OpenCode 未安装"
    Write-Host "请先安装 OpenCode: https://opencode.ai" -ForegroundColor $yellow
    exit 1
}

# 检查 Node.js
Write-Step "检查 Node.js..."
try {
    $nodeVersion = & node --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Node.js 已安装: $nodeVersion"
    }
} catch {
    Write-Err "Node.js 未安装"
    Write-Host "请先安装 Node.js: https://nodejs.org" -ForegroundColor $yellow
    exit 1
}

# 克隆/更新仓库
Write-Step "准备插件仓库..."
$repoUrl = "https://github.com/kongshan001/opencode-plugins.git"

if (Test-Path $InstallDir) {
    Write-Host "仓库已存在，正在更新..." -ForegroundColor $yellow
    Set-Location $InstallDir
    git pull
} else {
    git clone $repoUrl $InstallDir
}
Write-Success "插件仓库准备完成: $InstallDir"

# 配置 MCP
if (-not $SkipMCP) {
    Write-Step "配置 MCP (Prompt Monitor)..."
    
    $configDir = "$env:APPDATA\opencode"
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
    
    $mcpConfig = "$configDir\mcp.json"
    
    # 备份现有配置
    if (Test-Path $mcpConfig) {
        $backup = "$mcpConfig.backup_$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item $mcpConfig $backup
        Write-Host "已备份现有配置: $backup" -ForegroundColor $yellow
    }
    
    # 转换路径为 Windows 格式
    $installPathWin = $InstallDir -replace '\\', '\\\\'
    
    $mcpJson = @{
        mcpServers = @{
            "prompt-monitor" = @{
                command = "node"
                args = @("$InstallDir\opencode-prompt-monitor\index.js")
            }
        }
    }
    
    $mcpJson | ConvertTo-Json -Depth 10 | Set-Content $mcpConfig -Encoding UTF8
    Write-Success "MCP 配置完成: $mcpConfig"
}

# 配置 Skills
if (-not $SkipSkills) {
    Write-Step "配置 Skills..."
    
    $configDir = "$env:APPDATA\opencode"
    $opencodeConfig = "$configDir\opencode.json"
    
    # 创建默认配置（如果不存在）
    if (-not (Test-Path $opencodeConfig)) {
        @{
            '$schema' = 'https://opencode.ai/config.json'
            skills = @{
                paths = @($InstallDir + '\team-roles')
            }
        } | ConvertTo-Json -Depth 10 | Set-Content $opencodeConfig -Encoding UTF8
        Write-Success "Skills 配置完成: $opencodeConfig"
    } else {
        Write-Warn "opencode.json 已存在，请手动添加 skills 配置"
        Write-Host ""
        Write-Host "在 opencode.json 中添加:" -ForegroundColor $yellow
        $skillsJson = @{
            skills = @{
                paths = @($InstallDir + '\team-roles')
            }
        } | ConvertTo-Json -Depth 10
        Write-Host $skillsJson -ForegroundColor $yellow
    }
}

# 启动 MCP 服务
if ($StartService) {
    Write-Step "启动 MCP 服务..."
    
    # 检查是否已运行
    $portInUse = Get-NetTCPConnection -LocalPort 3847 -ErrorAction SilentlyContinue
    if ($portInUse) {
        Write-Warn "端口 3847 已被占用，MCP 服务可能已在运行"
    } else {
        $mcpScript = "$InstallDir\opencode-prompt-monitor\index.js"
        
        # 启动 node 进程
        $env:OPENCODE_LOG_DIR = "$env:USERPROFILE\.local\share\opencode\log"
        Start-Process -FilePath "node" -ArgumentList $mcpScript -WindowStyle Hidden
        
        Start-Sleep -Seconds 2
        
        # 验证服务
        try {
            $health = Invoke-RestMethod -Uri "http://localhost:3847/health" -TimeoutSec 5
            if ($health.status -eq "ok") {
                Write-Success "MCP 服务已启动 (端口 3847)"
            }
        } catch {
            Write-Warn "MCP 服务启动验证失败"
        }
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor $green
Write-Host "  部署完成!" -ForegroundColor $green
Write-Host "============================================" -ForegroundColor $green
Write-Host ""
Write-Host "插件目录: $InstallDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步:" -ForegroundColor Yellow
Write-Host "  1. 重启 OpenCode 使配置生效" 
Write-Host "  2. 测试 MCP: curl http://localhost:3847/health"
Write-Host ""
Write-Host "团队角色 Skills:" -ForegroundColor Cyan
Write-Host "  $InstallDir\team-roles\"
Write-Host ""
Write-Host "使用说明:" -ForegroundColor Yellow
Write-Host "  卸载: .\install.ps1 -Uninstall"
Write-Host "  启动MCP: .\install.ps1 -StartService"
Write-Host ""
