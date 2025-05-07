import log4js from 'log4js';
const l = log4js.getLogger();

import lambdaClient from '../utils/lambdaClient.js';
import { z } from "zod";

const toolName = "invoke-function";

const toolDescription = 
    "1. This tool can be used for invoking Lambda functions. \
    2. A functionName parameter MUST be supplied by the caller. \
    3. A payload parameter MUST be supplied by the caller. Ask explicitly if needed.";

const toolParamsSchema = {
    functionName: z.string().describe("Name of the Lambda function to retrieve information about."),
    payload: z.string().describe("The JSON payload to be sent to the Lambda function.")
} 

const toolCallback = async ({ functionName, payload }) => {
    l.debug(`> functionName=${functionName}, payload=${payload}`);
    
    const resp = await lambdaClient.invokeFunction(functionName, payload);

    l.debug(`< returning response`);
    return {
        content: [{
            type: 'text',
            text: JSON.stringify(resp)
        }]
    }
}

export default {
    toolName,
    toolDescription,
    toolParamsSchema,
    toolCallback
}