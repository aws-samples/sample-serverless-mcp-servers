import jwt from 'jsonwebtoken';
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

const AUTHORIZED_SUB = 'travel-agent';

// Load the JWT signature secret once, during function init. Fail fast if it's
// not configured or can't be read - never fall back to a default value.
const JWT_SIGNATURE_SECRET_ARN = process.env.JWT_SIGNATURE_SECRET_ARN;
if (!JWT_SIGNATURE_SECRET_ARN) {
    throw new Error('JWT_SIGNATURE_SECRET_ARN environment variable is not set');
}
const { SecretString: JWT_SIGNATURE_SECRET } = await new SecretsManagerClient()
    .send(new GetSecretValueCommand({ SecretId: JWT_SIGNATURE_SECRET_ARN }));
if (!JWT_SIGNATURE_SECRET) {
    throw new Error(`Secret ${JWT_SIGNATURE_SECRET_ARN} has no string value`);
}

export const handler = async (event) => {
    const authHeader = event.authorizationToken;
    // console.log({authHeader});
    try {
        const jwtString = authHeader.split(' ')[1];
        // Also validates `exp` claim
        const claims = jwt.verify(jwtString, JWT_SIGNATURE_SECRET, { algorithms: ['HS256'] });
        // console.log({claims})

        const principalId = `${claims.sub}|${claims.user_id}|${claims.user_name}`;

        if (claims.sub !== AUTHORIZED_SUB) {
            console.log(`Access denied to sub=${claims.sub}`);
            return generatePolicy('Deny', event.methodArn, principalId);
        }
        return generatePolicy('Allow', event.methodArn, principalId);
    } catch (e){
        console.error(`Failed to parse authorization header: ${e}`);
        return generatePolicy('Deny', event.methodArn);
    }
};

const generatePolicy = (effect, resource, principalId) => {
    console.log(`generatePolicy effect=${effect} pricipalId=${principalId}`);
    return {
        principalId,
        policyDocument: {
            Version: '2012-10-17',
            Statement: [{
                Action: 'execute-api:Invoke',
                Effect: effect,
                Resource: resource
            }]
        }
    };
};
