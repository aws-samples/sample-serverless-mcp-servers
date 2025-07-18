import log4js from 'log4js';
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import mcpServer from './mcp-server.js';
import mcpErrors from './mcp-errors.js';
const MCP_PATH = '/mcp';

const l = log4js.getLogger();

const bootstrap = async (app) => {
    app.post(MCP_PATH, postRequestHandler);
    app.get(MCP_PATH, sessionRequestHandler);
    app.delete(MCP_PATH, sessionRequestHandler);
}

const postRequestHandler = async (req, res) => {
    try {
        // Create new instances of MCP Server and Transport for each incoming request
        const newMcpServer = mcpServer.create();
        const transport = new StreamableHTTPServerTransport({
            // This is a stateless MCP server, so we don't need to keep track of sessions
            sessionIdGenerator: undefined,

            // Change to `false` if you want to enable SSE in responses. 
            enableJsonResponse: true,                  
        });

        res.on('close', () => {
            l.debug(`request processing complete`);
            transport.close();
            newMcpServer.close();
        });
        await newMcpServer.connect(transport);
        await transport.handleRequest(req, res, req.body);
    } catch (err) {
        l.error(`Error handling MCP request ${err}`);
        if (!res.headersSent) {
            res.status(500).json(mcpErrors.internalServerError)
        }
    }
}

const sessionRequestHandler = async (req, res) => {
    res.status(405).set('Allow', 'POST').json(mcpErrors.methodNotAllowed);
}

export default {
    bootstrap
}
