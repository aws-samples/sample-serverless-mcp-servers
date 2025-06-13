const { Stack } = require('aws-cdk-lib');
const lambda = require('aws-cdk-lib/aws-lambda');
const McpServerConstruct = require('./mcp-server');
const AgentConstruct = require('./agent');
const Cognito = require('./cognito');

// The IaC below uses Arm64 by default. 
// Change to x86 if you're building on x86 arch.
const FN_ARCHITECTURE = lambda.Architecture.ARM_64;
const JWT_SIGNATURE_SECRET = 'jwt-signature-secret';

class StrandsAgentOnLambdaStack extends Stack {
    constructor(scope, id, props) {
        super(scope, id, props);

        const { 
            cognitoJwksUrl 
        } = new Cognito(this, 'Cognito');

        const {
            mcpEndpoint
        } = new McpServerConstruct(this, 'McpServerConstruct',{
            fnArchitecture: FN_ARCHITECTURE,
            jwtSignatureSecret: JWT_SIGNATURE_SECRET
        });

        new AgentConstruct(this, 'AgentConstruct', {
            fnArchitecture: FN_ARCHITECTURE,
            jwtSignatureSecret: JWT_SIGNATURE_SECRET,
            mcpEndpoint,
            cognitoJwksUrl
        });

    }
}

module.exports = { StrandsAgentOnLambdaStack }
