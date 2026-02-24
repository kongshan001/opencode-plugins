/**
 * OpenCode Prompt Monitor Plugin
 * 实时监控 OpenCode 发送给大模型的 prompt 次数
 * 
 * 使用方法：
 * 1. 复制此文件到 ~/.config/opencode/plugins/prompt-monitor.js
 * 2. 重启 OpenCode
 * 3. 在对话中使用 "查看 prompt 统计"
 */

// 状态存储
const state = {
  promptCount: 0,
  sessionStartTime: Date.now(),
  promptHistory: [],
  currentModel: ''
}

// 保存状态到文件
function saveState() {
  try {
    const fs = require('fs')
    const path = require('path')
    const os = require('os')
    
    const home = process.env.HOME || process.env.USERPROFILE || os.homedir()
    const stateDir = path.join(home, '.local/state/opencode')
    const stateFile = path.join(stateDir, 'prompt-monitor-state.json')
    
    const data = {
      promptCount: state.promptCount,
      sessionStartTime: state.sessionStartTime,
      promptHistory: state.promptHistory.slice(-50),
      lastUpdated: new Date().toISOString()
    }
    
    fs.mkdirSync(stateDir, { recursive: true })
    fs.writeFileSync(stateFile, JSON.stringify(data, null, 2))
  } catch (err) {
    // 忽略错误
  }
}

// 加载状态
function loadState() {
  try {
    const fs = require('fs')
    const path = require('path')
    const os = require('os')
    
    const home = process.env.HOME || process.env.USERPROFILE || os.homedir()
    const stateFile = path.join(home, '.local/state/opencode/prompt-monitor-state.json')
    
    if (fs.existsSync(stateFile)) {
      const data = JSON.parse(fs.readFileSync(stateFile, 'utf8'))
      state.promptCount = data.promptCount || 0
      state.sessionStartTime = data.sessionStartTime || Date.now()
      state.promptHistory = data.promptHistory || []
    }
  } catch (err) {
    // 忽略错误
  }
}

// 初始化时加载状态
loadState()

// 导出插件
module.exports = async function PromptMonitorPlugin({ client }) {
  // 日志
  if (client?.app?.log) {
    await client.app.log({
      body: {
        service: "prompt-monitor",
        level: "info",
        message: "Plugin initialized",
      },
    })
  }

  return {
    // 工具执行前钩子 - 统计 prompt
    "tool.execute.before": async (input, output) => {
      // 检测 LLM 相关调用
      if (input.tool === "llm" || input.tool === "prompt") {
        state.promptCount++
        state.promptHistory.push({
          count: state.promptCount,
          tool: input.tool,
          timestamp: new Date().toISOString()
        })
        saveState()
      }
    },
    
    // 会话创建时重置（可选）
    "session.created": async () => {
      // 可以选择在这里重置计数
      // state.promptCount = 0
      // state.sessionStartTime = Date.now()
      // state.promptHistory = []
    },
  }
}
