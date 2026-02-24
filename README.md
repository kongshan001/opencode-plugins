# OpenCode Demo

一个简单的 OpenCode 插件和本地 MCP 服务器示例项目。

## 项目结构

```
opencode-demo/
├── plugins demo-plugin.js     # OpenCode /
│   └──插件
├── mcp-server/
│   ├── index.js           # MCP 服务器实现
│   ├── package.json       # 依赖配置
│   └── node_modules/      # 已安装的依赖
├── opencode.json.example  # OpenCode 配置示例
└── README.md
```

## 插件 (demo-plugin.js)

### 功能

1. **事件监听**: 监听会话完成事件 (`session.idle`)
2. **工具执行前拦截**: 记录工具执行日志 (`tool.execute.before`)
3. **自定义工具**:
   - `hello`: 打招呼
   - `echo`: 回显文本
   - `getTime`: 获取服务器时间

### 使用方法

将插件文件路径添加到 OpenCode 配置:

```json
{
  "plugin": ["/path/to/opencode-demo/plugins/demo-plugin.js"]
}
```

## MCP 服务器 (mcp-server)

### 功能

提供以下工具:

- `get_server_info`: 获取服务器信息
- `calculate`: 简单计算器 (加减乘除)
- `get_date`: 获取当前日期时间
- `reverse_text`: 反转文本

### 使用方法

1. 在 OpenCode 配置中添加 MCP 服务器:

```json
{
  "mcp": {
    "demo-mcp": {
      "type": "local",
      "command": ["node", "/path/to/opencode-demo/mcp-server/index.js"],
      "enabled": true
    }
  }
}
```

2. 在提示词中使用:

```
use the demo-mcp tool to calculate add 10 and 5
use the demo-mcp tool to get_server_info
```

## 本地开发

```bash
# 进入 MCP 服务器目录
cd mcp-server

# 安装依赖
npm install

# 测试 MCP 服务器
node index.js
```

## 提交到 Git

```bash
# 初始化 git 仓库
git init

# 添加文件
git add .

# 提交
git commit -m "feat: 添加 OpenCode 插件和 MCP 服务器示例"

# 添加远程仓库
git remote add origin <your-repo-url>

# 推送
git push -u origin main
```

## 参考文档

- [OpenCode 插件文档](https://opencode.ai/docs/zh-cn/plugins/)
- [OpenCode MCP 服务器文档](https://opencode.ai/docs/zh-cn/mcp-servers/)
