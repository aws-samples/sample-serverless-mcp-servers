import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";
import { } from '@modelcontextprotocol/sdk/client/auth.js'

const ENDPOINT_URL = process.env.MCP_SERVER_ENDPOINT || 'http://localhost:3001/mcp';
// Change to good_access_token for successful authorization when authorization is enabled

console.log(`Connecting ENDPOINT_URL=${ENDPOINT_URL}`);

const GOOD_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJqb2huLmRvZUBleGFtcGxlLmNvbSIsIm5hbWUiOiJKb2huIERvZSIsImlhdCI6MTc0OTU5NTQwOH0.T717m9gAiiRAXtHJN4Hm8QPZMidiXPSPN2bepA_vNFE';
const BAD_TOKEN = 'blah';

const oauthProvider = {
    tokens: () => {
        console.log('in tokens');
        return {
            access_token: BAD_TOKEN,
            scope: 'profile'
        }
    },
    clientInformation: ()=> {
        console.log('in clientInformation');
        return {
            client_id: 'asd',
            client_secret: 'asd',
            scope: 'profile'
        }
    },
    clientMetadata: ()=> {
        console.log('in clientMetadata');
        return {
            scope: 'profile'
        }
    },
    redirectToAuthorization: ()=>{
        console.log('in redirectToAuthorization');
    },
    saveCodeVerifier: ()=>{
        console.log('in saveCodeVerifier');
    }

    
}


const transport = new StreamableHTTPClientTransport(new URL(ENDPOINT_URL), {
    authProvider: oauthProvider,
    // requestInit: {
    //     headers: {
    //         'Authorization': `Bearer ${fake_token}`
    //     }
    // }
});

const client = new Client({

    name: "node-client",
    version: "0.0.1"
})

await client.connect(transport);
console.log('connected');

// const tools = await client.listTools();
// console.log(`listTools response: `, tools);

// for (let i = 0; i < 2; i++) {
//     let result = await client.callTool({
//         name: "ping"
//     });
//     console.log(`callTool:ping response: `, result);
// }

await client.close();