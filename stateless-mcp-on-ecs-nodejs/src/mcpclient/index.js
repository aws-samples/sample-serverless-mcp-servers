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
