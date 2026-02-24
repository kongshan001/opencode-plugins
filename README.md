# OpenCode Plugins & Skills

OpenCode 自定义 MCP、Skills 和插件集合。

---

## 🚀 一键部署

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/kongshan001/opencode-plugins/master/install-windows.ps1 | iex
```

### Windows (CMD)

```cmd
install-windows.bat
```

### Linux / MacOS

```bash
curl -sL https://raw.githubusercontent.com/kongshan001/opencode-plugins/master/install.sh | bash
```

详细说明见 [一键部署指南](./docs/deployment.md)

---

## 📦 内容导航

| 类型 | 目录 | 说明 |
|------|------|------|
| **MCP** | [`opencode-prompt-monitor/`](./opencode-prompt-monitor) | 实时监控 prompt 次数 |
| **Skills** | [`team-roles/`](./team-roles) | 团队协作角色集合 |

### MCP 插件

- **[Prompt Monitor](./opencode-prompt-monitor)** - 实时监控 OpenCode 发送给大模型的 prompt 次数

### 团队角色 Skills

- **[团队角色合集](./team-roles)** - 策划、程序、审核、QA、文档等角色定义
  - [Coordinator](./team-roles/coordinator) - 团队协调者
  - [Planner](./team-roles/planner) - 策划
  - [Developer](./team-roles/developer) - 程序员
  - [Reviewer](./team-roles/reviewer) - 代码审核
  - [QA](./team-roles/qa) - QA 工程师
  - [Doc Writer](./team-roles/doc-writer) - 文档工程师

---

## 📁 目录结构

```
opencode-plugins/
├── docs/
│   └── deployment.md        # 部署指南
├── opencode-prompt-monitor/ # MCP 插件
├── team-roles/              # 团队角色 Skills
├── install.sh              # Linux/Mac 安装脚本
├── install-windows.ps1     # Windows PowerShell
└── install-windows.bat     # Windows CMD
```

---

## 🤝 贡献

欢迎提交 PR！请确保文档清晰完整。

---

## 📄 License

MIT
