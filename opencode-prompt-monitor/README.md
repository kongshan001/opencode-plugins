# OpenCode Prompt Monitor

实时监控 OpenCode 发送给大模型的 prompt 次数。

---

## 两种使用方式

### 方式1: MCP 服务器（推荐）

MCP 服务器提供工具供 LLM 调用。

**配置** (`~/.config/opencode/opencode.json`):

```json
{
  "mcp": {
    "prompt-monitor": {
      "type": "local",
      "command": ["node", "/path/to/opencode-prompt-monitor/index.js"],
      "enabled": true
    }
  }
}
```

**使用**:
```
使用 prompt-monitor 工具获取 prompt 次数
```

### 方式2: 插件

插件通过钩子自动统计，无需手动调用。

**安装**:
```bash
# 复制插件到全局插件目录
cp plugin/index.js ~/.config/opencode/plugins/prompt-monitor.js
```

---

## MCP 工具

| 工具 | 说明 |
|------|------|
| `get_prompt_count` | 获取当前 prompt 次数 |
| `get_stats` | 获取统计信息 |
| `get_history` | 获取 prompt 历史记录 |

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

---

## 目录结构

```
opencode-prompt-monitor/
├── index.js        # MCP 服务器（stdio 协议）
├── plugin/
│   └── index.js    # OpenCode 插件（钩子方式）
├── package.json
└── README.md
```

---

## 参考

- [OpenCode MCP 文档](https://opencode.ai/docs/zh-cn/mcp-servers/)
- [OpenCode 插件文档](https://opencode.ai/docs/zh-cn/plugins/)
