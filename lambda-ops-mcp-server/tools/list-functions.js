import log4js from 'log4js';
const l = log4js.getLogger();

import lambdaClient from '../utils/lambdaClient.js';
import { z } from "zod";

const toolName = "list-functions";

const toolDescription = 
    "1. This tool can be used for retrieving a list of AWS Lambda functions. \
    2. This tool should be used to answer questions about what functions are available \
    in user's account, as well as questions about specific properties of these functions. \
    3. This tool should not be used when you need information about one specific function. \
    If you need information about one specific function, use the get-function tool instead. \
    4. This tool supports optional pagination via the marker parameter. If you see a 'marker' \
    property in the tool response, you SHOULD use it to make another request to the tool to \
    continue building the list. When 'marker' property is not present in the tool response, \
    it means you've reached the last page of results and you should stop retrieving more functions. \
    5. When you're using this tool for the first time, you obviously do not have \
    marker yet, so supply an empty string as a value instead \
    5. This tool returns a JSON object with two elements. The first element is an array of \
    functions. The second element is a marker that can be used for further pagination. \
    ";

const toolParamsSchema = {
    marker: z.string().optional().describe(
        "Pagination marker. Send empty string for the first \
        request, when previous marker is not yet available."
    )
};


const toolCallback = async ({ marker }) => {
    l.debug(`> marker=${marker?.substring(0,20)}`);

    const {functions, nextMarker} = await lambdaClient.listFunctions(marker)
    
    const response = JSON.stringify({
        functions,
        marker: nextMarker
    });

    l.debug(`< returning response functions.length=${functions.length}`);

    return {
        content: [{
            type: 'text',
            text: response
        }]
    }
}

export default {
    toolName,
    toolDescription,
    toolParamsSchema,
    toolCallback
}