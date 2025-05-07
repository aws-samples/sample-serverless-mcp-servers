import log4js from 'log4js';
import { 
    LambdaClient, 
    GetFunctionCommand, 
    ListFunctionsCommand,
    UpdateFunctionConfigurationCommand,
    InvokeCommand
} from "@aws-sdk/client-lambda";

const l = log4js.getLogger();
const REGION = process.env.AWS_REGION || "us-east-1";
const lambdaClient = new LambdaClient({ region: REGION });

async function listFunctions(marker){
    l.debug(`> marker=${marker?.substring(0,20)}`);

    const command = new ListFunctionsCommand({
        Marker: marker || null,
        MaxItems: 50
    });

    const lambdaResponse = await lambdaClient.send(command);
    // console.log(lambdaResponse.NextMarker);
    
    const functions = [];
    for (const func of lambdaResponse.Functions) {
        // if (functions.length==3) break;

        functions.push({
            name: func.FunctionName,
            runtime: func.Runtime,
            lastModified: func.LastModified,
            arn: func.FunctionArn,
            // memorySize: func.MemorySize,
            // timeout: func.Timeout,
            // arch: func.Architectures[0]
        });
    }
    return {
        functions,
        nextMarker: lambdaResponse.NextMarker
    };
}

async function getFunction(name) {
    l.debug(`> name=${name}`);
    const command = new GetFunctionCommand({
        FunctionName: name
    });

    const response = await lambdaClient.send(command);
    return {
        config: response.Configuration,
        tags: response.Tags,
        concurrency: response.Concurrency,
    };
}

async function updateFunctionRuntime(name, runtime) {
    l.debug(`> name=${name} runtime=${runtime}`);
    const command = new UpdateFunctionConfigurationCommand({
        FunctionName: name,
        Runtime: runtime
    });

    const response = await lambdaClient.send(command);
    return response;
}

async function invokeFunction(name, payload) {
    l.debug(`> name=${name} payload=${payload}`);
    const command = new InvokeCommand({
        FunctionName: name,
        Payload: payload
    });

    const response = await lambdaClient.send(command);

    return {
        statusCode: response.StatusCode,
        error: response.FunctionError,
        payload: Buffer.from(response.Payload).toString('utf-8')
    };
}

export default {
    listFunctions,
    getFunction,
    updateFunctionRuntime,
    invokeFunction
};

