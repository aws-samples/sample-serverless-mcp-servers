import log4js from 'log4js';
import { randomUUID } from "node:crypto";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import { isInitializeRequest } from "@modelcontextprotocol/sdk/types.js"
import mcpServer from './mcp-server.js';
import mcpErrors from './mcp-errors.js';

const MCP_PATH = '/mcp';
const MCP_SESSION_ID_HEADER = 'mcp-session-id';

const l = log4js.getLogger();

const transports = {};

const bootstrap = async (app) => {
    app.post(MCP_PATH, postRequestHandler);
    app.get(MCP_PATH, sessionRequestHandler);
    app.delete(MCP_PATH, sessionRequestHandler);
}

const postRequestHandler = async (req, res) => {
    const sessionId = req.headers[MCP_SESSION_ID_HEADER];
    l.debug(`> sessionId=${sessionId}`);
    let transport;

    if (sessionId && transports[sessionId]){
        l.debug(`using existing transport for sessionid=${sessionId}`);
        // Reuse existing transport
        transport = transports[sessionId];
    } else if (!sessionId && isInitializeRequest(req.body)){
        // New initialization request
        // Create new instances of MCP Server and Transport
        l.debug(`creating new MCP Server and Transport`);
        const newMcpServer = mcpServer.create();
        transport = new StreamableHTTPServerTransport({
            sessionIdGenerator: () => randomUUID(),
            onsessioninitialized: (sessionId) => {
                l.debug(`session initialized for sessionid=${sessionId}`);
                transports[sessionId] = transport;
            }
            // Uncomment if you want to disable SSE in responses
            // enableJsonResponse: true,            
        });

        transport.onclose = () => {
            if (transport.sessionId){
                l.debug(`deleting transport for sessionid=${sessionId}`);
                delete transports[transport.sessionId];
            }
        }

        await newMcpServer.connect(transport);
    } else {
        // Invalid request
        l.debug(`Prodived invalid sessionId=${sessionId}`);
        res.status(400).json(mcpErrors.noValidSessionId);
        return;
    }

    await transport.handleRequest(req, res, req.body);
}

const sessionRequestHandler = async (req, res) => {
    const sessionId = req.headers[MCP_SESSION_ID_HEADER];
    l.debug(`> sessionId=${sessionId}`);
    if (!sessionId || !transports[sessionId]){
        res.status(400).json(mcpErrors.invalidOrMissingSessionId);
        return;
    }

    const transport = transports[sessionId];
    await transport.handleRequest(req, res);
}

export default {
    bootstrap
}
