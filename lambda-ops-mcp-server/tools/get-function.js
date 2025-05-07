import log4js from 'log4js';
const l = log4js.getLogger();

import lambdaClient from '../utils/lambdaClient.js';
import { z } from "zod";

const toolName = "get-function";

const toolDescription = 
    "1. This tool can be used for retrieving information about one specific Lambda function. \
    2. A Function Name parameter MUST be supplied by the caller. \
    3. Whenever you need to make any changes to function configuration, such as updating \
    a runtime version, ALWAYS use this tool first to get the configuration state before updating \
    in order to be able to roll back changes in case the update will break function functionality. ";

const toolParamsSchema = {
    functionName: z.string().describe("Name of the Lambda function to retrieve information about.")
} 

const toolCallback = async ({ functionName }) => {
    l.debug(`> functionName=${functionName}`);
    
    const fn = await lambdaClient.getFunction(functionName);

    l.debug(`< returning response`);
    return {
        content: [{
            type: 'text',
            text: JSON.stringify(fn)
        }]
    }
}

export default {
    toolName,
    toolDescription,
    toolParamsSchema,
    toolCallback
}