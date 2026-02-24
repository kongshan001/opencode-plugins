#!/usr/bin/env node

/**
 * OpenCode Prompt Monitor MCP Server
 * 实时监控 OpenCode 发送给大模型的 prompt 次数
 */

const http = require('http');
const fs = require('fs');
const path = require('path');

const LOG_DIR = process.env.OPENCODE_LOG_DIR || path.join(process.env.HOME || '/root', '.local/share/opencode/log');
const STATE_FILE = path.join(process.env.HOME || '/root', '.local/state/opencode/prompt-count.json');

// 状态管理
let promptCount = 0;
let sessionStartTime = Date.now();
let lastLogSize = 0;

// 读取当前日志文件
function getLatestLogFile() {
  const files = fs.readdirSync(LOG_DIR)
    .filter(f => f.endsWith('.log'))
    .map(f => ({
      name: f,
      time: fs.statSync(path.join(LOG_DIR, f)).mtime.getTime()
    }))
    .sort((a, b) => b.time - a.time);
  
  return files.length > 0 ? path.join(LOG_DIR, files[0].name) : null;
}

// 解析日志行，检测 prompt 事件
function parseLogLine(line) {
  // 检测 session.prompt 事件
  if (line.includes('service=session.prompt') && line.includes('step=')) {
    const stepMatch = line.match(/step=(\d+)/);
    const sessionMatch = line.match(/sessionID=([^\s]+)/);
    return {
      type: 'prompt',
      step: stepMatch ? parseInt(stepMatch[1]) : 0,
      sessionId: sessionMatch ? sessionMatch[1] : 'unknown',
      timestamp: new Date().toISOString()
    };
  }
  
  // 检测 LLM 调用事件
  if (line.includes('service=llm') && line.includes('stream')) {
    const modelMatch = line.match(/modelID=([^\s]+)/);
    const providerMatch = line.match(/providerID=([^\s]+)/);
    return {
      type: 'llm_call',
      model: modelMatch ? modelMatch[1] : 'unknown',
      provider: providerMatch ? providerMatch[1] : 'unknown',
      timestamp: new Date().toISOString()
    };
  }
  
  return null;
}

// 监控日志文件
function watchLog() {
  const logFile = getLatestLogFile();
  if (!logFile) return;
  
  try {
    const stats = fs.statSync(logFile);
    const currentSize = stats.size;
    
    // 如果文件变小了（新日志文件），重置位置
    if (currentSize < lastLogSize) {
      lastLogSize = 0;
    }
    
    if (currentSize > lastLogSize) {
      const stream = fs.createReadStream(logFile, {
        start: lastLogSize,
        end: currentSize - 1
      });
      
      let buffer = '';
      stream.on('data', (chunk) => {
        buffer += chunk;
        const lines = buffer.split('\n');
        buffer = lines.pop(); // 保留不完整的行
        
        for (const line of lines) {
          const event = parseLogLine(line);
          if (event && event.type === 'prompt') {
            promptCount++;
            saveState();
          }
        }
      });
      
      stream.on('end', () => {
        lastLogSize = currentSize;
      });
    }
  } catch (err) {
    // 忽略错误
  }
}

// 保存状态
function saveState() {
  try {
    const state = {
      promptCount,
      sessionStartTime,
      lastUpdated: new Date().toISOString()
    };
    fs.mkdirSync(path.dirname(STATE_FILE), { recursive: true });
    fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
  } catch (err) {
    // 忽略
  }
}

// 加载状态
function loadState() {
  try {
    if (fs.existsSync(STATE_FILE)) {
      const state = JSON.parse(fs.readFileSync(STATE_FILE, 'utf8'));
      promptCount = state.promptCount || 0;
      sessionStartTime = state.sessionStartTime || Date.now();
    }
  } catch (err) {
    // 忽略
  }
}

// MCP 工具定义
const tools = {
  // 获取当前 prompt 次数
  get_prompt_count: {
    description: "获取 OpenCode 当前会话发送给大模型的 prompt 次数",
    parameters: {
      type: "object",
      properties: {
        reset: {
          type: "boolean",
          description: "是否重置计数",
          default: false
        }
      }
    }
  },
  
  // 获取统计信息
  get_stats: {
    description: "获取详细的 prompt 统计信息",
    parameters: {
      type: "object",
      properties: {}
    }
  }
};

// 处理 MCP 请求
function handleRequest(req, res) {
  res.setHeader('Content-Type', 'application/json');
  
  if (req.method === 'GET' && req.url === '/health') {
    res.end(JSON.stringify({ status: 'ok', promptCount }));
    return;
  }
  
  if (req.method === 'POST' && req.url === '/tools') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const { name, arguments: args } = JSON.parse(body);
        
        if (name === 'get_prompt_count') {
          if (args.reset) {
            promptCount = 0;
            sessionStartTime = Date.now();
            saveState();
          }
          res.end(JSON.stringify({
            content: [{
              type: "text",
              text: `当前已发送 ${promptCount} 个 prompt`
            }]
          }));
        } else if (name === 'get_stats') {
          const uptime = Math.floor((Date.now() - sessionStartTime) / 1000);
          res.end(JSON.stringify({
            content: [{
              type: "text",
              text: JSON.stringify({
                promptCount,
                uptimeSeconds: uptime,
                promptsPerMinute: uptime > 0 ? (promptCount / (uptime / 60)).toFixed(2) : 0
              }, null, 2)
            }]
          }));
        } else {
          res.end(JSON.stringify({ error: 'Unknown tool' }));
        }
      } catch (err) {
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }
  
  // 列出可用工具
  if (req.method === 'GET' && req.url === '/tools') {
    res.end(JSON.stringify({ tools: Object.keys(tools) }));
    return;
  }
  
  res.end(JSON.stringify({ error: 'Not found' }));
}

// 启动服务器
const PORT = process.env.PORT || 3847;

loadState();

// 启动日志监控
setInterval(watchLog, 1000);

const server = http.createServer(handleRequest);
server.listen(PORT, () => {
  console.log(`OpenCode Prompt Monitor MCP running on port ${PORT}`);
});
