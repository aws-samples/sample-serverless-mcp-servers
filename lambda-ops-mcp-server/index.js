import './utils/logging.js';
import log4js from 'log4js';
const l = log4js.getLogger();
l.info('starting...');

import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import mcpServer from './mcp-server.js';
const transport = new StdioServerTransport();
await mcpServer.connect(transport);
