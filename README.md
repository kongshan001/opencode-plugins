# OpenCode Plugins & Skills

OpenCode 自定义 MCP、Skills 和插件集合。

---

## 🚀 一键部署

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

## 📦 手动部署

```bash
# 克隆仓库
git clone https://github.com/kongshan001/opencode-plugins.git ~/.opencode-plugins

# 查看所有插件和角色
ls -la ~/.opencode-plugins/
```

---

## 🛠️ MCP 插件

### Prompt Monitor

实时监控 OpenCode 发送给大模型的 prompt 次数。

| 项目 | 说明 |
|------|------|
| 目录 | `opencode-prompt-monitor/` |
| 功能 | 统计 prompt 次数、查看历史记录 |
| 状态 | ✅ 已完成 |

#### 接入方式

编辑 `~/.config/opencode/opencode.json` 添加 MCP 配置：

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

或者直接启动（独立进程）：

```bash
node ~/.opencode-plugins/opencode-prompt-monitor/index.js &
```

#### 使用方法

| 工具 | 说明 |
|------|------|
| `get_prompt_count` | 获取当前 prompt 次数 |
| `get_prompt_history` | 获取 prompt 历史记录 |
| `get_stats` | 获取统计信息（次数、运行时长、每分钟请求数） |

#### API 端点

```bash
# 健康检查
curl http://localhost:3847/health

# 获取 prompt 次数
curl -X POST http://localhost:3847/tools \
  -H "Content-Type: application/json" \
  -d '{"name":"get_prompt_count","arguments":{}}'

# 获取历史记录
curl -X POST http://localhost:3847/tools \
  -H "Content-Type: application/json" \
  -d '{"name":"get_prompt_history","arguments":{"limit":10}}'
```

---

## 👥 团队角色 Skills

完整的软件工程团队角色定义，包含策划、程序、审核、QA、文档等角色。

| 角色 | 目录 | 说明 | 状态 |
|------|------|------|------|
| 策划 | `team-roles/planner/` | 需求分析、编写 REQ 文档 | ✅ |
| 程序 | `team-roles/developer/` | 代码开发、git 规范 | ✅ |
| 审核 | `team-roles/reviewer/` | Code Review | ✅ |
| QA | `team-roles/qa/` | 单元测试、覆盖率检查 | ✅ |
| 文档 | `team-roles/doc-writer/` | 接口文档、架构文档 | ✅ |
| 协调者 | `team-roles/coordinator/` | 协调团队工作流程 | ✅ |

### 接入方式

在 OpenCode 中使用这些角色，只需让 AI 助手（如 OpenClaw、Claude）阅读对应的 SKILL.md 文件即可。

```bash
# 查看角色列表
ls ~/.opencode-plugins/team-roles/

# 查看特定角色详情
cat ~/.opencode-plugins/team-roles/planner/SKILL.md
```

---

## 📁 目录结构

```
opencode-plugins/
├── README.md                          # 本文件
├── opencode-prompt-monitor/           # MCP 插件
│   ├── index.js                       # MCP 服务器
│   └── mcp.json                       # 配置示例
└── team-roles/                       # 团队角色
    ├── README.md                      # 角色说明
    ├── coordinator/                   # 协调者
    ├── planner/                       # 策划
    ├── developer/                     # 程序员
    ├── reviewer/                      # 代码审核
    ├── qa/                            # QA 工程师
    └── doc-writer/                   # 文档工程师
```

---

## 🤝 贡献指南

欢迎提交 PR！

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/xxx`)
3. 提交更改 (`git commit -m 'feat: xxx'`)
4. 推送分支 (`git push origin feature/xxx`)
5. 提交 Pull Request

---

## 📄 License

MIT
