# OpenCode Prompt Monitor

实时监控 OpenCode 发送给大模型的 prompt 次数的 MCP 插件。

---

## 功能

- 统计当前会话的 prompt 次数
- 查看 prompt 历史记录（包含 step、model、时间戳）
- 统计信息（次数、运行时长、每分钟请求数）
- 跨平台支持（Windows、Linux、macOS）

---

## 快速开始

### 1. 配置 MCP

编辑 `~/.config/opencode/opencode.json`（Linux/Mac）或 `%APPDATA%\opencode\opencode.json`（Windows）：

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

### 2. 重启 OpenCode

使配置生效。

---

## 工具

| 工具 | 说明 |
|------|------|
| `get_prompt_count` | 获取当前 prompt 次数 |
| `get_stats` | 获取统计信息 |
| `get_history` | 获取 prompt 历史记录 |

---

## 使用方式

在 OpenCode 中直接使用：

```
使用 prompt-monitor 工具获取 prompt 次数
```

或更具体：

```
使用 get_stats 工具查看详细统计
```

---

## 输出示例

### get_prompt_count

```
当前已发送 15 个 prompt
```

### get_stats

```json
{
  "promptCount": 15,
  "uptimeSeconds": 300,
  "promptsPerMinute": "3.00",
  "currentModel": "glm-5"
}
```

### get_history

```json
[
  {"count": 1, "step": 0, "model": "glm-5", "timestamp": "..."},
  {"count": 2, "step": 1, "model": "glm-5", "timestamp": "..."}
]
```

---

## 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `OPENCODE_LOG_DIR` | OpenCode 日志目录 | `~/.local/share/opencode/log` |
| `OPENCODE_STATE_FILE` | 状态文件路径 | `~/.local/state/opencode/prompt-count.json` |

---

## 目录结构

```
opencode-prompt-monitor/
├── index.js    # MCP 服务器（stdio 协议）
└── README.md   # 本文档
```
