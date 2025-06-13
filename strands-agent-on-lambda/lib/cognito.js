const { Construct } = require('constructs');
const cognito = require('aws-cdk-lib/aws-cognito');
const { CfnOutput, RemovalPolicy, Stack } = require('aws-cdk-lib');

const REDIRECT_URI = "http://localhost:8000/callback";
const LOGOUT_URI = "http://localhost:8000/chat";

class Cognito extends Construct {
    constructor(scope, id, props) {
        super(scope, id, props);

        const userPool = new cognito.UserPool(this, 'UserPool', {
            userPoolName: 'strands-agent-on-lambda',
            selfSignUpEnabled: false,
            signInAliases: { username: true, email: true },
            removalPolicy: RemovalPolicy.DESTROY
        });

        const userPoolClient = new cognito.UserPoolClient(this, 'UserPoolClient', {
            userPool,
            generateSecret: true,
            authFlows: {
                userPassword: true
            },
            oAuth: {
                flows: {
                    authorizationCodeGrant: true
                },
                callbackUrls: [REDIRECT_URI],
                logoutUrls: [LOGOUT_URI]
            }
        });

        const userPoolDomain = userPool.addDomain('UserPoolDomain', {
            cognitoDomain: {
                domainPrefix: 'strands-on-lambda'
            }
        });

        new cognito.CfnUserPoolUser(this, 'AliceUser', {
            userPoolId: userPool.userPoolId,
            messageAction: 'SUPPRESS',
            username: 'Alice',
        });

        new cognito.CfnUserPoolUser(this, 'BobUser', {
            userPoolId: userPool.userPoolId,
            messageAction: 'SUPPRESS',
            username: 'Bob',
        });

        // Outputs
        const region = Stack.of(this).region;
        const cognitoJwksUrl = `https://cognito-idp.${region}.amazonaws.com/${userPool.userPoolId}/.well-known/jwks.json`;
        const cognitoWellKnownUrl = `https://cognito-idp.${region}.amazonaws.com/${userPool.userPoolId}/.well-known/openid-configuration`;
        const cognitoSignInUrl = userPoolDomain.signInUrl(userPoolClient, {
            redirectUri: REDIRECT_URI
        });
        const cognitoLogoutUrl = `${userPoolDomain.baseUrl()}/logout?client_id=${userPoolClient.userPoolClientId}`;

        new CfnOutput(this, 'CognitoUserPoolId', {
            exportName: 'CognitoUserPoolId',
            value: userPool.userPoolId
        });


        new CfnOutput(this, 'CognitoWellKnownUrl', {
            exportName: 'CognitoWellKnownUrl',
            value: cognitoWellKnownUrl
        });

        new CfnOutput(this, 'CognitoSignInUrl', {
            exportName: 'CognitoSignInUrl',
            value: cognitoSignInUrl
        });

        new CfnOutput(this, 'CognitoLogoutUrl', {
            exportName: 'CognitoLogoutUrl',
            value: cognitoLogoutUrl
        });


        new CfnOutput(this, 'CognitoClientId', {
            exportName: 'CognitoClientId',
            value: userPoolClient.userPoolClientId
        });

        new CfnOutput(this, 'CognitoClientSecret', {
            exportName: 'CognitoClientSecret',
            value: userPoolClient.userPoolClientSecret.unsafeUnwrap()
        });

        new CfnOutput(this, 'CognitoJwksUrl', {
            exportName: 'CognitoJwksUrl',
            value: cognitoJwksUrl
        });

        return {
            cognitoJwksUrl
        }
    }
}

module.exports = Cognito;