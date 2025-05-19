import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import metadata from "./metadata.js";

let SHORT_DELAY = true;
const LONG_DELAY_MS = 100;
const SHORT_DELAY_MS = 50;

const create = () => {
  const mcpServer = new McpServer({
    name: "demo-mcp-server",
    version: metadata.version
  }, {
    capabilities: {
      tools: {}
    }
  });

  mcpServer.tool("ping", async () => {
    const startTime = Date.now();
    SHORT_DELAY=!SHORT_DELAY;

    if (SHORT_DELAY){
      await new Promise((resolve) => setTimeout(resolve, SHORT_DELAY_MS));
    } else {
      await new Promise((resolve) => setTimeout(resolve, LONG_DELAY_MS));
    }
    const duration = Date.now() - startTime;

    return {
      content: [
        {
          type: "text",
          text: `pong! taskId=${metadata.taskId} v=${metadata.version} d=${duration}`
        }
      ]
    }
  });

  return mcpServer
};

export default { create };
