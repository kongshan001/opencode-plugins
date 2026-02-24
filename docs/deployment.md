# 部署指南

本文档提供详细的部署说明。

---

## 环境要求

- [OpenCode](https://opencode.ai) 已安装
- [Node.js](https://nodejs.org) 18+ (用于运行 MCP)

---

## 一键部署

### Windows (PowerShell)

```powershell
# 以管理员身份运行 PowerShell
irm https://raw.githubusercontent.com/kongshan001/opencode-plugins/master/install-windows.ps1 | iex
```

或下载脚本后运行：

```powershell
.\install-windows.ps1 -StartService
```

### Windows (CMD)

```cmd
install-windows.bat
```

### Linux / MacOS

```bash
# 下载并运行
curl -sL https://raw.githubusercontent.com/kongshan001/opencode-plugins/master/install.sh | bash

# 或下载脚本后运行
chmod +x install.sh
./install.sh --start-service
```

---

## 部署选项

| 选项 | 说明 |
|------|------|
| `-StartService` | 启动 MCP 服务 |
| `-SkipMCP` | 跳过 MCP 配置 |
| `-SkipSkills` | 跳过 Skills 配置 |
| `-Uninstall` | 卸载 |

---

## 手动部署

### 1. 克隆仓库

```bash
git clone https://github.com/kongshan001/opencode-plugins.git ~/.opencode-plugins
```

### 2. 配置 MCP

编辑 `~/.config/opencode/opencode.json`：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "prompt-monitor": {
      "type": "local",
      "command": ["node", "/path/to/opencode-plugins/opencode-prompt-monitor/index.js"],
      "enabled": true
    }
  }
}
```

### 3. 配置 Skills (可选)

```json
{
  "$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": ["/path/to/opencode-plugins/team-roles"]
  }
}
```

### 4. 重启 OpenCode

使配置生效。

---

## 验证

```bash
# 测试 MCP 服务
curl http://localhost:3847/health

# 获取 prompt 次数
curl -X POST http://localhost:3847/tools \
  -H "Content-Type: application/json" \
  -d '{"name":"get_prompt_count","arguments":{}}'
```

---

## 故障排除

### MCP 服务未启动

手动启动：

```bash
node ~/.opencode-plugins/opencode-prompt-monitor/index.js &
```

### 端口被占用

修改端口：

```bash
PORT=3848 node ~/.opencode-plugins/opencode-prompt-monitor/index.js &
```

### OpenCode 配置不生效

检查配置文件位置：

```bash
# Linux/Mac
cat ~/.config/opencode/opencode.json

# Windows
type %APPDATA%\opencode\opencode.json
```
