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
    
    # 删除 skills
    $skillsDir = "$env:APPDATA\opencode\skills"
    if (Test-Path $skillsDir) {
        Remove-Item $skillsDir -Recurse -Force
        Write-Success "Skills 已删除"
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
    
    # 读取现有配置或创建新的
    $opencodeConfig = "$configDir\opencode.json"
    $config = @{}
    if (Test-Path $opencodeConfig) {
        $config = Get-Content $opencodeConfig | ConvertFrom-Json -AsHashtable
    } else {
        $config = @{
            '$schema' = 'https://opencode.ai/config.json'
        }
    }
    
    # 添加 MCP 配置
    if (-not $config.mcp) {
        $config.mcp = @{}
    }
    $config.mcp['prompt-monitor'] = @{
        type = 'local'
        command = @('node', $InstallDir + '\opencode-prompt-monitor\index.js')
        enabled = $true
    }
    
    # 保存配置
    $config | ConvertTo-Json -Depth 10 | Set-Content $opencodeConfig -Encoding UTF8
    Write-Success "MCP 配置完成: $opencodeConfig"
}

# 配置 Skills (复制到正确位置)
if (-not $SkipSkills) {
    Write-Step "配置 Skills..."
    
    $skillsDir = "$env:APPDATA\opencode\skills"
    
    # 映射 team-roles 到 skills
    $roleMapping = @{
        'coordinator' = 'coordinator'
        'planner' = 'planner'
        'developer' = 'developer'
        'reviewer' = 'reviewer'
        'qa' = 'qa'
        'doc-writer' = 'doc-writer'
    }
    
    foreach ($role in $roleMapping.Keys) {
        $sourceDir = Join-Path $InstallDir "team-roles\$role"
        $targetDir = Join-Path $skillsDir $role
        
        if (Test-Path $sourceDir) {
            # 确保目标目录存在
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            
            # 复制 SKILL.md
            $sourceSkill = Join-Path $sourceDir "SKILL.md"
            $targetSkill = Join-Path $targetDir "SKILL.md"
            
            if (Test-Path $sourceSkill) {
                Copy-Item $sourceSkill $targetSkill -Force
                Write-Host "  - 已安装: $role" -ForegroundColor Green
            }
        }
    }
    
    Write-Success "Skills 配置完成: $skillsDir"
    Write-Host ""
    Write-Host "重启 OpenCode 后使用 /skill 查看可用技能" -ForegroundColor Yellow
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
Write-Host "Skills目录: $env:APPDATA\opencode\skills" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步:" -ForegroundColor Yellow
Write-Host "  1. 重启 OpenCode 使配置生效"
Write-Host "  2. 使用 /skill 查看可用技能"
Write-Host ""
