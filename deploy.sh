#!/bin/bash

# OpenCode Plugins 一键部署脚本

set -e

echo "🚀 开始部署 OpenCode Plugins..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查命令
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}错误: $1 未安装${NC}"
        exit 1
    fi
}

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 检查依赖
echo -e "${YELLOW}📋 检查依赖...${NC}"
check_command node
check_command npm
check_command git

# 安装 MCP 服务器依赖
echo -e "${YELLOW}📦 安装 MCP 服务器依赖...${NC}"
cd "$SCRIPT_DIR/mcp-server"
npm install

# 返回主目录
cd "$SCRIPT_DIR"

# 创建本地插件目录
PLUGIN_DIR="$HOME/.config/opencode/plugins"
if [ ! -d "$PLUGIN_DIR" ]; then
    echo -e "${YELLOW}📁 创建插件目录: $PLUGIN_DIR${NC}"
    mkdir -p "$PLUGIN_DIR"
fi

# 复制插件
echo -e "${YELLOW}📋 安装插件...${NC}"
cp plugins/demo-plugin.js "$PLUGIN_DIR/"
echo -e "${GREEN}✓ 插件已安装${NC}"

# 创建配置
CONFIG_FILE="$HOME/.config/opencode/opencode.json"
echo -e "${YELLOW}⚙️ 创建 OpenCode 配置...${NC}"

# 备份现有配置
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
    echo -e "${YELLOW}✓ 已备份现有配置${NC}"
fi

# 生成配置
cat > "$CONFIG_FILE" << EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "mcp": {
    "demo-mcp": {
      "type": "local",
      "command": ["node", "$SCRIPT_DIR/mcp-server/index.js"],
      "enabled": true
    }
  },
  "plugin": [
    "$SCRIPT_DIR/plugins/demo-plugin.js"
  ]
}
EOF

echo -e "${GREEN}✓ 配置已创建${NC}"

echo ""
echo -e "${GREEN}🎉 部署完成！${NC}"
echo ""
echo "请重启 OpenCode 以加载插件和 MCP 服务器"
echo ""
echo "可用工具:"
echo "  - hello <name>     : 打招呼"
echo "  - echo <text>     : 回显文本"
echo "  - getTime         : 获取服务器时间"
echo "  - calculate       : 计算器 (add/subtract/multiply/divide)"
echo "  - get_date        : 获取日期时间"
echo "  - reverse_text    : 反转文本"
echo "  - get_server_info : 服务器信息"
