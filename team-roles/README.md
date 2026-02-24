# Team Roles - 团队角色技能集合

本目录包含多角色团队协作的 OpenCode Skills。

## 快速开始

```bash
# 克隆到本地
git clone https://github.com/kongshan001/opencode-plugins.git ~/.opencode-plugins

# 查看所有角色
ls -la ~/.opencode-plugins/team-roles/
```

## 角色列表

| 目录 | 角色 | 说明 |
|------|------|------|
| `coordinator` | 团队协调者 | 协调整个团队工作流程 |
| `planner` | 策划 | 编写需求文档 |
| `developer` | 程序员 | 开发功能代码 |
| `reviewer` | 代码审核 | Code Review |
| `qa` | QA 工程师 | 编写测试、覆盖率检查 |
| `doc-writer` | 文档工程师 | 编写接口/架构文档 |

## 使用方法

在 OpenCode 中，根据当前任务选择对应的 skill：

1. **需要提需求** → 参考 `planner/SKILL.md`
2. **需要开发功能** → 参考 `developer/SKILL.md`  
3. **需要审核代码** → 参考 `reviewer/SKILL.md`
4. **需要写测试** → 参考 `qa/SKILL.md`
5. **需要写文档** → 参考 `doc-writer/SKILL.md`
6. **协调整个流程** → 参考 `coordinator/SKILL.md`

## 目录结构

```
team-roles/
├── coordinator/      # 团队协调者
├── planner/         # 策划
├── developer/       # 程序员
├── reviewer/        # 代码审核
├── qa/              # QA 工程师
└── doc-writer/      # 文档工程师
```

## 集成到项目

将 skills 复制到你的项目目录：

```bash
cp -r ~/.opencode-plugins/team-roles ./skills/
```

然后在 OpenCode 中使用 `/skill` 命令切换角色。
