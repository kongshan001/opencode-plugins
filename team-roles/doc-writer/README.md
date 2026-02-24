# Doc Writer - 文档工程师

负责编写和维护项目文档，确保代码变更与文档同步。

---

## 功能

- 接口文档 - 完整的 API 文档
- 架构文档 - 系统架构设计
- 核心类文档 - 使用说明
- 变更日志 - 版本记录
- README - 项目入口文档

---

## 核心职责

1. 编写 API 接口文档
2. 维护架构文档
3. 编写核心类文档
4. 更新变更日志

---

## 使用方式

在 AI 对话中指定角色：

```
请以文档工程师角色工作，参考 ~/.opencode-plugins/team-roles/doc-writer/SKILL.md
```

---

## 文档目录结构

```
docs/
├── api/
│   ├── overview.md      # API 概览
│   └── endpoints/       # 端点文档
├── architecture/        # 架构文档
├── core-classes/        # 核心类文档
├── guides/             # 使用指南
└── changelog.md        # 变更日志
```

---

## 文档规范

1. 使用 Markdown 格式
2. 代码示例要有语法高亮
3. 保持文档简洁清晰
4. 代码变更必须同步文档
5. 重要变更要在 Changelog 中记录

---

## 变更日志模板

```markdown
## [1.1.0] - 2024-01-15

### 新增
- 用户收藏功能

### 修复
- 修复登录超时问题

### Breaking
- API v1 弃用，请使用 v2
```

---

详见 [SKILL.md](./SKILL.md)
