# OpenCode Plugins

OpenCode 插件和 MCP 服务器集合。

## 插件列表

### demo-plugin

简单的 OpenCode 插件示例。

**功能：**
- 事件监听：`session.idle` 会话完成
- 工具拦截：`tool.execute.before` 执行前记录
- 自定义工具：`hello`、`echo`、`getTime`

## MCP 服务器

### demo-mcp

本地 MCP 服务器示例。

**工具：**
- `get_server_info` - 服务器信息
- `calculate` - 加减乘除计算
- `get_date` - 获取日期时间
- `reverse_text` - 文本反转

## 快速开始

### Windows

```powershell
# 克隆仓库
git clone https://github.com/kongshan001/opencode-plugins.git
cd opencode-plugins

# 运行部署脚本
.\deploy.ps1
```

如果遇到执行策略问题，请用管理员运行：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### macOS / Linux

```bash
git clone https://github.com/kongshan001/opencode-plugins.git
cd opencode-plugins
./deploy.sh
```

### 手动配置

1. 复制插件：
   - Windows: `copy plugins\demo-plugin.js %USERPROFILE%\.config\opencode\plugins\`
   - macOS/Linux: `cp plugins/demo-plugin.js ~/.config/opencode/plugins/`

2. 添加 MCP 配置到 `~/.config/opencode/opencode.json`（Windows: `%USERPROFILE%\.config\opencode\opencode.json`）：

```json
{
  "mcp": {
    "demo-mcp": {
      "type": "local",
      "command": ["node", "/path/to/opencode-plugins/mcp-server/index.js"],
      "enabled": true
    }
  },
  "plugin": [
    "/path/to/opencode-plugins/plugins/demo-plugin.js"
  ]
}
```

## 贡献

欢迎提交 PR！创建新插件或 MCP 服务器。

## License

MIT
