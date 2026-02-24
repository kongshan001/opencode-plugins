/**
 * OpenCode Demo MCP Server
 * 
 * 一个简单的本地 MCP 服务器，提供实用工具
 * 使用 @modelcontextprotocol/sdk 实现
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

// 工具定义
const tools = [
  {
    name: "get_server_info",
    description: "获取服务器信息",
    inputSchema: {
      type: "object",
      properties: {},
    },
  },
  {
    name: "calculate",
    description: "简单的计算器，支持加减乘除",
    inputSchema: {
      type: "object",
      properties: {
        operation: {
          type: "string",
          enum: ["add", "subtract", "multiply", "divide"],
          description: "运算操作",
        },
        a: { type: "number", description: "第一个数字" },
        b: { type: "number", description: "第二个数字" },
      },
      required: ["operation", "a", "b"],
    },
  },
  {
    name: "get_date",
    description: "获取当前日期和时间",
    inputSchema: {
      type: "object",
      properties: {
        format: {
          type: "string",
          enum: ["iso", "local", "timestamp"],
          description: "日期格式",
        },
      },
    },
  },
  {
    name: "reverse_text",
    description: "反转文本",
    inputSchema: {
      type: "object",
      properties: {
        text: { type: "string", description: "要反转的文本" },
      },
      required: ["text"],
    },
  },
];

// 工具执行逻辑
async function handleToolCall(toolName, args) {
  switch (toolName) {
    case "get_server_info":
      return {
        content: [
          {
            type: "text",
            text: JSON.stringify({
              name: "OpenCode Demo MCP Server",
              version: "1.0.0",
              description: "一个简单的本地 MCP 服务器示例",
              uptime: process.uptime(),
              nodeVersion: process.version,
            }, null, 2),
          },
        ],
      };

    case "calculate":
      const { operation, a, b } = args;
      let result;
      switch (operation) {
        case "add":
          result = a + b;
          break;
        case "subtract":
          result = a - b;
          break;
        case "multiply":
          result = a * b;
          break;
        case "divide":
          result = b !== 0 ? a / b : "Error: Division by zero";
          break;
      }
      return {
        content: [
          {
            type: "text",
            text: `${a} ${operation} ${b} = ${result}`,
          },
        ],
      };

    case "get_date":
      const now = new Date();
      let dateResult;
      switch (args.format) {
        case "iso":
          dateResult = now.toISOString();
          break;
        case "timestamp":
          dateResult = Math.floor(now.getTime() / 1000).toString();
          break;
        case "local":
        default:
          dateResult = now.toLocaleString("zh-CN");
      }
      return {
        content: [
          {
            type: "text",
            text: dateResult,
          },
        ],
      };

    case "reverse_text":
      const reversed = args.text.split("").reverse().join("");
      return {
        content: [
          {
            type: "text",
            text: reversed,
          },
        ],
      };

    default:
      throw new Error(`Unknown tool: ${toolName}`);
  }
}

// 创建服务器
const server = new Server(
  {
    name: "opencode-demo-mcp",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// 处理工具列表请求
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return { tools };
});

// 处理工具调用请求
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  try {
    return await handleToolCall(name, args);
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `Error: ${error.message}`,
        },
      ],
      isError: true,
    };
  }
});

// 启动服务器
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("MCP Server started");
}

main().catch((error) => {
  console.error("Server error:", error);
  process.exit(1);
});
