/**
 * OpenCode Demo Plugin
 * 
 * 一个简单的插件示例：会话完成后发送通知，并提供自定义工具
 */

export const DemoPlugin = async ({ project, client, $, directory, worktree }) => {
  // 记录插件初始化日志
  await client.app.log({
    body: {
      service: "demo-plugin",
      level: "info",
      message: "Demo plugin initialized",
      extra: { 
        project: project?.name, 
        directory, 
        worktree 
      },
    },
  });

  return {
    // 会话完成事件
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await client.app.log({
          body: {
            service: "demo-plugin",
            level: "info",
            message: "Session completed!",
          },
        });
      }
    },

    // 命令执行前事件
    "tool.execute.before": async (input, output) => {
      await client.app.log({
        body: {
          service: "demo-plugin",
          level: "debug",
          message: `Tool ${input.tool} is about to execute`,
        },
      });
    },

    // 自定义工具
    tool: {
      hello: {
        description: "Say hello with a custom message",
        args: {
          name: { type: "string", description: "Name to greet" },
        },
        async execute(args, context) {
          return `Hello, ${args.name}! 👋 Welcome to OpenCode Demo!`;
        },
      },
      
      echo: {
        description: "Echo back the input text",
        args: {
          text: { type: "string", description: "Text to echo" },
        },
        async execute(args, context) {
          return `Echo: ${args.text}`;
        },
      },

      getTime: {
        description: "Get current server time",
        args: {},
        async execute(args, context) {
          return new Date().toISOString();
        },
      },
    },
  };
};

export default DemoPlugin;
