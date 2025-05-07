import log4js from 'log4js';
const l = log4js.getLogger();

import lambdaClient from '../utils/lambdaClient.js';
import { z } from "zod";

const toolName = "update-function-runtime";

const toolDescription = 
    "1. This tool can be used for updating the runtime version used by a Lambda function. \
    You MUST supply two parameters as explained below. \
    2. A 'functionName' parameter value MUST be supplied by the caller. \
    3. A 'runtime' parameter value MUST be spllied by the caller. \
    4. After updating a function runtime, you SHOULD ALWAYS invoke the function \
    in order to validate it still works. \
    5. Use invoke-function tool to test if the function can still be invoked. If invocation fails - \
    ALWAYS rollback to the previous runtime version automatically. Do not attempt to fix code until you \
    get to a state when function is working again.\
    6. When rolling back, check if there's an in-between runtime version that you can try upgrading to. \
    For example, if you upgraded from runtime version 1 to version 3, and version 3 is failing, try \
    downgrading to version 2 first, and so on. If it still fails, go back to the original runtime version. \
    7. When user is asking to downgrade runtime version to a version you know is either deprecated or \
    soon-to-be-deprecated, ALWAYS confirm whether user actually wants to do it. \
    ";

const toolParamsSchema = {
    functionName: z.string().describe("Name of the Lambda function to retrieve information about."),
    runtime: z.string().describe("The new runtime version to be used by the Lambda function.")
} 

const toolCallback = async ({ functionName, runtime }) => {
    l.debug(`> functionName=${functionName} runtime=${runtime}`);
    
    const fn = await lambdaClient.updateFunctionRuntime(functionName, runtime);

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