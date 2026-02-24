# Team Roles - 团队角色技能集合

完整的软件工程团队角色定义，包含策划、程序、审核、QA、文档等角色。

## 📦 快速开始

```bash
# 克隆到本地
git clone https://github.com/kongshan001/opencode-plugins.git ~/.opencode-plugins

# 查看所有角色
ls -la ~/.opencode-plugins/team-roles/
```

---

## 👥 角色列表

| 角色 | 目录 | 功能介绍 | 最佳实践 |
|------|------|----------|----------|
| **协调者** | `coordinator/` | 协调团队工作流程 | 完整功能开发、紧急修复、大型重构 |
| **策划** | `planner/` | 需求分析、编写 REQ 文档 | 新项目启动、功能迭代、需求变更 |
| **程序员** | `developer/` | 代码开发、git 规范提交 | 实现新功能、Bug 修复、代码重构 |
| **审核** | `reviewer/` | Code Review | PR 审查、快速审查、大型重构审查 |
| **QA** | `qa/` | 单元测试、集成测试、覆盖率 | 单元测试、集成测试、覆盖率分析 |
| **文档** | `doc-writer/` | 接口文档、架构文档 | API 文档更新、核心类文档、变更日志 |

---

## 🚀 接入方式

### 作为 AI 助手的工作指引

在开发项目时，可以指定 AI 使用特定角色：

```
请以 [角色名] 角色工作，参考 ~/.opencode-plugins/team-roles/[角色名]/SKILL.md
```

例如：
```
请以策划角色工作，参考 ~/.opencode-plugins/team-roles/planner/SKILL.md
```

### 每个角色的核心职责

#### 1. 协调者 (Coordinator)
- 协调整个团队工作流程
- 确保各角色有序协作
- 把控整体进度和质量

#### 2. 策划 (Planner)
- 编写需求文档 (REQ-XXX.md)
- 优先级排序 (P0/P1/P2)
- 定义验收标准

#### 3. 程序员 (Developer)
- 理解需求并实现代码
- 遵循 git 提交规范
- 编写自测代码

#### 4. 审核 (Reviewer)
- Code Review
- 检查安全性/性能/规范
- 提出改进建议

#### 5. QA
- 编写单元测试
- 编写集成测试
- 确保测试覆盖率达标

#### 6. 文档 (Doc Writer)
- 编写 API 接口文档
- 维护架构文档
- 编写核心类文档
- 更新变更日志

---

## 📁 目录结构

```
team-roles/
├── README.md              # 本文件
├── coordinator/           # 协调者
│   └── SKILL.md
├── planner/              # 策划
│   └── SKILL.md
├── developer/            # 程序员
│   └── SKILL.md
├── reviewer/             # 代码审核
│   └── SKILL.md
├── qa/                  # QA 工程师
│   └── SKILL.md
└── doc-writer/           # 文档工程师
    └── SKILL.md
```

---

## 📋 推荐工作流

### 完整功能开发

```
策划 → 程序 → 审核 → QA → 文档 → 提交推送
```

### 紧急修复

```
评估 → 程序 → 快速审核 → 测试 → 合并
```

### 大型重构

```
策划 → 设计 → 分阶段实施 → 持续审核 → 完整测试 → 文档更新 → 合并
```

---

## 🤝 贡献

欢迎提交改进！请确保：
1. 每个角色 SKILL.md 包含：功能介绍、接入方式、最佳实践
2. 文档清晰易懂
3. 示例实用

---

## 📄 License

MIT
