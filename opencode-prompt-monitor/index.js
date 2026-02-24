#!/usr/bin/env node

/**
 * OpenCode Prompt Monitor MCP Server
 * 实时监控 OpenCode 发送给大模型的 prompt 次数
 * 
 * 使用 MCP stdio 协议通信
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const readline = require('readline');

// 配置路径
function getUserHome() {
  return process.env.HOME || process.env.USERPROFILE || os.homedir();
}

const LOG_DIR = process.env.OPENCODE_LOG_DIR || path.join(getUserHome(), '.local/share/opencode/log');
const STATE_FILE = process.env.OPENCODE_STATE_FILE || path.join(getUserHome(), '.local/state/opencode/prompt-count.json');

// 状态管理
let promptCount = 0;
let sessionStartTime = Date.now();
let promptHistory = [];
let currentModel = '';
let lastLogSize = 0;

// MCP 响应
function sendResponse(id, result) {
  const response = JSON.stringify({ jsonrpc: '2.0', id, result });
  process.stdout.write(response + '\n');
}

function sendError(id, code, message) {
  const error = JSON.stringify({ jsonrpc: '2.0', id, error: { code, message } });
  process.stdout.write(error + '\n');
}

// 读取当前日志文件
function getLatestLogFile() {
  try {
    const files = fs.readdirSync(LOG_DIR)
      .filter(f => f.endsWith('.log'))
      .map(f => ({
        name: f,
        time: fs.statSync(path.join(LOG_DIR, f)).mtime.getTime()
      }))
      .sort((a, b) => b.time - a.time);
    
    return files.length > 0 ? path.join(LOG_DIR, files[0].name) : null;
  } catch (err) {
    return null;
  }
}

// 解析日志行
function parseLogLine(line) {
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
  
  if (line.includes('service=llm') && line.includes('stream')) {
    const modelMatch = line.match(/modelID=([^\s]+)/);
    if (modelMatch) {
      currentModel = modelMatch[1];
    }
    return {
      type: 'llm_call',
      model: currentModel
    };
  }
  
  return null;
}

// 从日志更新状态
function updateFromLog() {
  const logFile = getLatestLogFile();
  if (!logFile) return;
  
  try {
    const stats = fs.statSync(logFile);
    const currentSize = stats.size;
    
    if (currentSize < lastLogSize) {
      lastLogSize = 0;
    }
    
    if (currentSize > lastLogSize) {
      const content = fs.readFileSync(logFile, 'utf8');
      const lines = content.split('\n').slice(lastLogSize > 0 ? 0 : 0);
      
      // 只处理新增的内容
      const newContent = content.slice(lastLogSize);
      const newLines = newContent.split('\n');
      
      for (const line of newLines) {
        const event = parseLogLine(line);
        if (event && event.type === 'prompt') {
          promptCount++;
          promptHistory.push({
            count: promptCount,
            step: event.step,
            sessionId: event.sessionId,
            model: currentModel,
            timestamp: event.timestamp
          });
        }
      }
      
      lastLogSize = currentSize;
      saveState();
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
      promptHistory: promptHistory.slice(-50)
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
      promptHistory = state.promptHistory || [];
    }
  } catch (err) {
    // 忽略
  }
}

// MCP 工具列表
const tools = [
  {
    name: 'get_prompt_count',
    description: '获取 OpenCode 当前会话发送给大模型的 prompt 次数',
    inputSchema: {
      type: 'object',
      properties: {
        reset: {
          type: 'boolean',
          description: '是否重置计数',
          default: false
        }
      }
    }
  },
  {
    name: 'get_stats',
    description: '获取详细的 prompt 统计信息（次数、运行时长、每分钟请求数）',
    inputSchema: {
      type: 'object',
      properties: {}
    }
  },
  {
    name: 'get_history',
    description: '获取最近的 prompt 历史记录',
    inputSchema: {
      type: 'object',
      properties: {
        limit: {
          type: 'number',
          description: '返回最近几条记录',
          default: 10
        }
      }
    }
  }
];

// 主循环
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

// 加载保存的状态
loadState();

rl.on('line', (line) => {
  try {
    const request = JSON.parse(line);
    const { id, method, params } = request;
    
    switch (method) {
      case 'initialize':
        sendResponse(id, {
          protocolVersion: '2024-11-05',
          capabilities: {
            tools: {}
          },
          serverInfo: {
            name: 'prompt-monitor',
            version: '1.0.0'
          }
        });
        break;
        
      case 'tools/list':
        sendResponse(id, { tools });
        break;
        
      case 'tools/call':
        const toolName = params?.name;
        const args = params?.arguments || {};
        
        switch (toolName) {
          case 'get_prompt_count':
            if (args.reset) {
              promptCount = 0;
              promptHistory = [];
              sessionStartTime = Date.now();
              saveState();
            } else {
              updateFromLog();
            }
            sendResponse(id, {
              content: [{
                type: 'text',
                text: `当前已发送 ${promptCount} 个 prompt`
              }]
            });
            break;
            
          case 'get_stats':
            updateFromLog();
            const uptime = Math.floor((Date.now() - sessionStartTime) / 1000);
            sendResponse(id, {
              content: [{
                type: 'text',
                text: JSON.stringify({
                  promptCount,
                  uptimeSeconds: uptime,
                  promptsPerMinute: uptime > 0 ? (promptCount / (uptime / 60)).toFixed(2) : 0,
                  currentModel
                }, null, 2)
              }]
            });
            break;
            
          case 'get_history':
            updateFromLog();
            const limit = args.limit || 10;
            sendResponse(id, {
              content: [{
                type: 'text',
                text: JSON.stringify(promptHistory.slice(-limit), null, 2)
              }]
            });
            break;
            
          default:
            sendError(id, -32601, `Unknown tool: ${toolName}`);
        }
        break;
        
      case 'ping':
        sendResponse(id, {});
        break;
        
      default:
        sendError(id, -32601, `Method not found: ${method}`);
    }
  } catch (err) {
    sendError(null, -32700, 'Parse error');
  }
});
