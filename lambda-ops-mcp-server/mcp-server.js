import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import getRuntimesInfo from "./tools/get-runtimes-info.js";
import listFunctions from "./tools/list-functions.js";
import getFunction from "./tools/get-function.js";
import invokeFunction from "./tools/invoke-function.js";
import updateFunctionRuntime from "./tools/update-function-runtime.js";

const server = new McpServer({
  name: "AWS Lambda Operations MCP Server",
  version: "0.0.1"
}, {
  capabilities: {
    tools: {},
    resources: {}
  },
  instructions:
    'Use this MCP server to retrieve various information about AWS Lambda functions \
    and perform runtime updates. \
    This MCP server allows to retrieve list of lambda function, get information about \
    specific functions, retrieve information about Lambda runtimes deprecation dates, \
    and update Lambda function runtime versions. \
    Always start using this server by running the get-runtimes-info tool to get the most\
    up-to-date information about supported and deprecated runtimes.'
});

server.tool(
  getRuntimesInfo.toolName,
  getRuntimesInfo.toolDescription,
  getRuntimesInfo.toolParamsSchema,
  getRuntimesInfo.toolCallback);

server.tool(
  listFunctions.toolName,
  listFunctions.toolDescription,
  listFunctions.toolParamsSchema,
  listFunctions.toolCallback);

server.tool(
  getFunction.toolName,
  getFunction.toolDescription,
  getFunction.toolParamsSchema,
  getFunction.toolCallback);

server.tool(
  invokeFunction.toolName,
  invokeFunction.toolDescription,
  invokeFunction.toolParamsSchema,
  invokeFunction.toolCallback);

server.tool(
  updateFunctionRuntime.toolName,
  updateFunctionRuntime.toolDescription,
  updateFunctionRuntime.toolParamsSchema,
  updateFunctionRuntime.toolCallback);

export default server;
