#!/bin/bash

# ============================================
# OpenCode 一键部署脚本 (Linux/Mac)
# ============================================

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置
REPO_URL="https://github.com/kongshan001/opencode-plugins.git"
INSTALL_DIR="${HOME}/.opencode-plugins"
OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"

# 参数
SKIP_MCP=false
SKIP_SKILLS=false
START_SERVICE=false
UNINSTALL=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-mcp) SKIP_MCP=true; shift ;;
        --skip-skills) SKIP_SKILLS=true; shift ;;
        --start-service) START_SERVICE=true; shift ;;
        --uninstall) UNINSTALL=true; shift ;;
        -h|--help)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --skip-mcp        跳过 MCP 配置"
            echo "  --skip-skills     跳过 Skills 配置"
            echo "  --start-service   启动 MCP 服务"
            echo "  --uninstall       卸载"
            echo "  -h, --help        显示帮助"
            exit 0
            ;;
        *) echo "未知参数: $1"; exit 1 ;;
    esac
done

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}  OpenCode Plugins & Skills 一键部署${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# 卸载模式
if [ "$UNINSTALL" = true ]; then
    echo -e "${YELLOW}[*] 开始卸载...${NC}"
    
    # 停止 MCP 服务
    if pgrep -f "opencode-prompt-monitor" > /dev/null; then
        pkill -f "opencode-prompt-monitor"
        echo -e "${GREEN}[√] MCP 服务已停止${NC}"
    fi
    
    # 删除配置
    if [ -f "${OPENCODE_CONFIG_DIR}/mcp.json" ]; then
        rm -f "${OPENCODE_CONFIG_DIR}/mcp.json"
        echo -e "${GREEN}[√] MCP 配置已删除${NC}"
    fi
    
    echo -e "${GREEN}[√] 卸载完成${NC}"
    exit 0
fi

# 检查 OpenCode
echo -e "${YELLOW}[*] 检查 OpenCode...${NC}"
if ! command -v opencode &> /dev/null; then
    echo -e "${RED}[X] OpenCode 未安装${NC}"
    echo -e "${YELLOW}请先安装 OpenCode: https://opencode.ai${NC}"
    exit 1
fi
OPENCODE_VERSION=$(opencode --version)
echo -e "${GREEN}[√] OpenCode 已安装: ${OPENCODE_VERSION}${NC}"

# 检查 Node.js
echo -e "${YELLOW}[*] 检查 Node.js...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}[X] Node.js 未安装${NC}"
    echo -e "${YELLOW}请先安装 Node.js: https://nodejs.org${NC}"
    exit 1
fi
NODE_VERSION=$(node --version)
echo -e "${GREEN}[√] Node.js 已安装: ${NODE_VERSION}${NC}"

# 克隆/更新仓库
echo -e "${YELLOW}[*] 准备插件仓库...${NC}"
if [ -d "$INSTALL_DIR" ]; then
    echo "仓库已存在，正在更新..."
    cd "$INSTALL_DIR"
    git pull
else
    git clone "$REPO_URL" "$INSTALL_DIR"
fi
echo -e "${GREEN}[√] 插件仓库准备完成: ${INSTALL_DIR}${NC}"

# 配置 MCP
if [ "$SKIP_MCP" = false ]; then
    echo -e "${YELLOW}[*] 配置 MCP (Prompt Monitor)...${NC}"
    
    mkdir -p "$OPENCODE_CONFIG_DIR"
    
    # 备份
    if [ -f "${OPENCODE_CONFIG_DIR}/mcp.json" ]; then
        BACKUP="${OPENCODE_CONFIG_DIR}/mcp.json.backup_$(date +%Y%m%d%H%M%S)"
        cp "${OPENCODE_CONFIG_DIR}/mcp.json" "$BACKUP"
        echo -e "${YELLOW}已备份现有配置: $BACKUP${NC}"
    fi
    
    # 使用 OpenCode 正确的 MCP 配置格式 (mcp 字段)
    cat > "${OPENCODE_CONFIG_DIR}/opencode.json" << EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "mcp": {
    "prompt-monitor": {
      "type": "local",
      "command": ["node", "${INSTALL_DIR}/opencode-prompt-monitor/index.js"],
      "enabled": true
    }
  },
  "skills": {
    "paths": ["${INSTALL_DIR}/team-roles"]
  }
}
EOF
    echo -e "${GREEN}[√] MCP 配置完成${NC}"
fi

# 配置 Skills
if [ "$SKIP_SKILLS" = false ]; then
    echo -e "${YELLOW}[*] 配置 Skills...${NC}"
    
    mkdir -p "$OPENCODE_CONFIG_DIR"
    
    if [ ! -f "${OPENCODE_CONFIG_DIR}/opencode.json" ]; then
        cat > "${OPENCODE_CONFIG_DIR}/opencode.json" << EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": ["${INSTALL_DIR}/team-roles"]
  }
}
EOF
        echo -e "${GREEN}[√] Skills 配置完成${NC}"
    else
        echo -e "${YELLOW}[!] opencode.json 已存在，请手动添加 skills 配置${NC}"
        echo -e "${YELLOW}添加以下内容:${NC}"
        echo "  \"skills\": { \"paths\": [\"${INSTALL_DIR}/team-roles\"] }"
    fi
fi

# 启动 MCP 服务
if [ "$START_SERVICE" = true ]; then
    echo -e "${YELLOW}[*] 启动 MCP 服务...${NC}"
    
    # 检查端口
    if lsof -i :3847 > /dev/null 2>&1; then
        echo -e "${YELLOW}[!] 端口 3847 已被占用${NC}"
    else
        OPENCODE_LOG_DIR="${HOME}/.local/share/opencode/log" node "${INSTALL_DIR}/opencode-prompt-monitor/index.js" &
        sleep 2
        
        # 验证
        if curl -s http://localhost:3847/health > /dev/null 2>&1; then
            echo -e "${GREEN}[√] MCP 服务已启动 (端口 3847)${NC}"
        else
            echo -e "${YELLOW}[!] MCP 服务启动验证失败${NC}"
        fi
    fi
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  部署完成!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${CYAN}插件目录: ${INSTALL_DIR}${NC}"
echo ""
echo -e "${YELLOW}下一步:${NC}"
echo "  1. 重启 OpenCode 使配置生效"
echo "  2. 测试 MCP: curl http://localhost:3847/health"
echo ""
echo -e "${CYAN}团队角色 Skills:${NC}"
echo "  ${INSTALL_DIR}/team-roles/"
echo ""
echo -e "${YELLOW}使用说明:${NC}"
echo "  卸载: $0 --uninstall"
echo "  启动MCP: $0 --start-service"
echo ""
