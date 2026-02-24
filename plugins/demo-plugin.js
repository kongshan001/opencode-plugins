/**
 * OpenCode Demo Plugin
 * 
 * 一个简单的插件示例：记录日志
 */

export const DemoPlugin = async ({ project, client, $, directory, worktree }) => {
  // 记录插件初始化日志
  console.log("Demo Plugin initialized!");
  console.log("Project:", project?.name);
  console.log("Directory:", directory);

  return {
    // 会话完成事件
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        console.log("Session completed!");
      }
    },

    // 命令执行前事件
    "tool.execute.before": async (input, output) => {
      console.log(`Tool ${input.tool} is about to execute`);
    },
  };
};

export default DemoPlugin;
