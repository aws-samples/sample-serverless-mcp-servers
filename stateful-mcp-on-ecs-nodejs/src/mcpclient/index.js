// As of building this sample (early May 2025), MCP Client SDK does not support
// cookie-based sticky sessions. In case you want to run more than one 
// instance of MCP Servers (multiple ECS tasks), you need to add cookie 
// support to `fetch`, the underlying framework that MCP Client uses for HTTP.
// Note that other clients, e.g. MCP Inspector, do not have this patch 
// implemented so they will not work when you have more than one instance 
// of MCP Server (==ECS Task) running. 
// A potential alternative is to run your MCP Servers in stateless mode, 
// see stateless-mcp-on-ecs and stateless-mcp-on-lambda samples in this repo.
// See big comment in ecs.tf for more details. 
import fetchCookie from 'fetch-cookie';
fetch = fetchCookie(fetch);

import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";

const ENDPOINT_URL = process.env.MCP_SERVER_ENDPOINT || 'http://localhost:3000/mcp';

console.log(`Connecting ENDPOINT_URL=${ENDPOINT_URL}`);

const transport = new StreamableHTTPClientTransport(new URL(ENDPOINT_URL));

const client = new Client({
    name: "node-client",
    version: "0.0.1"
})

await client.connect(transport);
console.log('connected');

const tools = await client.listTools();
console.log(`listTools response: `, tools);

for (let i = 0; i < 2; i++) {
    let result = await client.callTool({
        name: "ping"
    });
    console.log(`callTool:ping response: `, result);
}

await client.close();
