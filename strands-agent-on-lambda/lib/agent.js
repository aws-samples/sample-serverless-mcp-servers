const iam = require('aws-cdk-lib/aws-iam');
const lambda = require('aws-cdk-lib/aws-lambda');
const apigw = require('aws-cdk-lib/aws-apigateway');
const ddb = require('aws-cdk-lib/aws-dynamodb');
const s3 = require('aws-cdk-lib/aws-s3');
const { Duration, RemovalPolicy, CfnOutput } = require('aws-cdk-lib');
const { Construct } = require('constructs');

class AgentConstruct extends Construct {
    constructor(scope, id, props) {
        super(scope, id, props);

        const agentSessionStoreBucket = new s3.Bucket(this, 'AgentSessionStore', {
            removalPolicy: RemovalPolicy.DESTROY,
            autoDeleteObjects: true
        });       

        const dependenciesLayer = new lambda.LayerVersion(this, 'DependenciesLayer', {
            removalPolicy: RemovalPolicy.DESTROY,
            compatibleArchitectures: [props.fnArchitecture],
            code: lambda.Code.fromAsset('./layers/dependencies', {
                bundling: {
                    image: lambda.Runtime.PYTHON_3_13.bundlingImage,
                    command: [
                        'bash',
                        '-c',
                        'pip install --no-cache-dir -r requirements.txt -t /asset-output/python && cp -au . /asset-output/python'
                    ]
                }
            })
        });

        const travelAgentFn = new lambda.Function(this, 'TravelAgent', {
            functionName: 'travel-agent-on-lambda',
            architecture: props.fnArchitecture,
            runtime: lambda.Runtime.PYTHON_3_13,
            handler: 'app.handler',
            timeout: Duration.seconds(30),
            memorySize: 1024,
            code: lambda.Code.fromAsset('./lambdas/travel-agent', {
                exclude: ['.venv/**', '.venv', '*.pyc', '__pycache__/**', '.idea/**', '']
            }),
            layers: [dependenciesLayer],
            environment: {
                MCP_ENDPOINT: props.mcpEndpoint,
                JWT_SIGNATURE_SECRET: props.jwtSignatureSecret,
                SESSION_STORE_BUCKET_NAME: agentSessionStoreBucket.bucketName,
                COGNITO_JWKS_URL: props.cognitoJwksUrl
            }
        });

        travelAgentFn.addToRolePolicy(new iam.PolicyStatement({
            actions: ['bedrock:InvokeModel', 'bedrock:InvokeModelWithResponseStream'],
            resources: ['*'],
        }));

        agentSessionStoreBucket.grantReadWrite(travelAgentFn);

        const agentApi = new apigw.RestApi(this, 'AgentApi', {
            restApiName: 'travel-agent-api',
            endpointTypes: [apigw.EndpointType.REGIONAL],
            deploy: true
        });

        const agentAuthorizerFn = new lambda.Function(this, 'AgentAuthorizerFn', {
            functionName: 'travel-agent-authorizer',
            architecture: props.fnArchitecture,
            runtime: lambda.Runtime.NODEJS_22_X,
            handler: 'index.handler',
            timeout: Duration.seconds(10),
            memorySize: 1024,
            code: lambda.Code.fromAsset('./lambdas/agent-authorizer'),
            environment: {
                COGNITO_JWKS_URL: props.cognitoJwksUrl
            }
        });

        const agentAuthorizer = new apigw.TokenAuthorizer(this, 'AgentAuthorizer', {
            handler: agentAuthorizerFn,
            identitySource: apigw.IdentitySource.header('Authorization')
        });

        agentApi.root.addMethod('POST', new apigw.LambdaIntegration(travelAgentFn), {
            authorizer: agentAuthorizer,
            authorizationType: apigw.AuthorizationType.CUSTOM
        });

        new CfnOutput(this, 'AgentEndpointUrl', {
            exportName: 'AgentEndpointUrl',
            value: agentApi.url
        })

    }
}

module.exports = AgentConstruct;