import log4js from 'log4js';
const l = log4js.getLogger();

import runtimePageParser from '../utils/runtimes-page-parser.js';
runtimePageParser.bootstrap();

const toolName = "get-runtimes-info";

const toolDescription = 
    "Use this tool to retrieve most up-to-date information about Lambda runtimes support and deprecation dates. \
    This tool will return a JSON array which contains information about runtimes with deprecation dates."

const toolParamsSchema = {};

const toolCallback = async ({}) => {
    l.debug(`>`);

    const runtimesInfo = await runtimePageParser.get();
    
    return {
        content: [{
            type: 'text',
            text: JSON.stringify(runtimesInfo)
        }]
    }
}

export default {
    toolName,
    toolDescription,
    toolParamsSchema,
    toolCallback
}