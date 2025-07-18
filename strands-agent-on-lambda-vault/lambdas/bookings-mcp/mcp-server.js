import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import packageInfo from './package.json' with { type: 'json'};
import toolBookHotel from './tool-book-hotel.js';
import toolBookCar from './tool-book-car.js';
import toolGetAvailableCars from './tool-get-available-cars.js';
import toolGetTravelPolicies from './tool-get-travel-policies.js';

const create = () => {
  const mcpServer = new McpServer({
    name: `bookings-mcp`,
    version: packageInfo.version
  }, {
    capabilities: {
      tools: {}
    },
    instructions: `
This MCP Server provides 
1. A collection of corporate travel policies that must always be followed. 
2. Tools to book hotels and car rentals
`
  });

  mcpServer.tool(...toolBookHotel);
  mcpServer.tool(...toolBookCar);
  mcpServer.tool(...toolGetAvailableCars);
  mcpServer.tool(...toolGetTravelPolicies);

  return mcpServer
};

export default { create };
