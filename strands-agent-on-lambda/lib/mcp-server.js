const lambda = require('aws-cdk-lib/aws-lambda');
const apigw = require('aws-cdk-lib/aws-apigateway');
const { Stack, Duration, CfnOutput } = require('aws-cdk-lib');
const { Construct } = require('constructs');

class McpServerConstruct extends Construct {
    constructor(scope, id, props) {
        super(scope, id, props);

        const lwaLayerArn = `arn:aws:lambda:${Stack.of(this).region}:753240598075:layer:LambdaAdapterLayerArm64:25`;
        const lwaLayer = lambda.LayerVersion.fromLayerVersionArn(this, 'LWALayer', lwaLayerArn);

        const bookingsMcpServerFn = new lambda.Function(this, 'BookingsMcpServer', {
            functionName: 'bookings-mcp-server',
            architecture: props.fnArchitecture,
            runtime: lambda.Runtime.NODEJS_22_X,
            handler: 'run.sh',
            timeout: Duration.seconds(10),
            memorySize: 1024,
            code: lambda.Code.fromAsset('./lambdas/bookings-mcp'),
            layers: [lwaLayer],
            environment: {
                AWS_LAMBDA_EXEC_WRAPPER: '/opt/bootstrap',
                AWS_LWA_PORT: "3001",
                JWT_SIGNATURE_SECRET: props.jwtSignatureSecret
            }
        });

        const mcpApi = new apigw.RestApi(this, 'McpApi', {
            restApiName: 'travel-agent-mcp-api',
            endpointTypes: [apigw.EndpointType.REGIONAL],
            deploy: true
        });

        const mcpResource = mcpApi.root.addResource('mcp');

        const mcpAuthorizerFn = new lambda.Function(this, 'McpAuthorizerFn', {
            functionName: 'bookings-mcp-server-authorizer',
            architecture: props.fnArchitecture,
            runtime: lambda.Runtime.NODEJS_22_X,
            handler: 'index.handler',
            timeout: Duration.seconds(10),
            memorySize: 1024,
            code: lambda.Code.fromAsset('./lambdas/mcp-authorizer'),
            environment: {
                JWT_SIGNATURE_SECRET: props.jwtSignatureSecret
            }
        });

        const mcpAuthorizer = new apigw.TokenAuthorizer(this, 'McpAuthorizer', {
            handler: mcpAuthorizerFn,
            identitySource: apigw.IdentitySource.header('Authorization')
        });

        mcpResource.addMethod('ANY', new apigw.LambdaIntegration(bookingsMcpServerFn), {
            authorizer: mcpAuthorizer,
            authorizationType: apigw.AuthorizationType.CUSTOM
        });

        const mcpEndpoint = `${mcpApi.url}mcp`;

        new CfnOutput(this, 'McpEndpoint', {
            value: mcpEndpoint
        })

        return { mcpEndpoint };
    }
}

module.exports = McpServerConstruct;