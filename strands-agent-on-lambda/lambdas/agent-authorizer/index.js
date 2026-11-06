import { createRemoteJWKSet, jwtVerify } from 'jose';

// Fetches and caches Cognito's public signing keys
const JWKS = createRemoteJWKSet(new URL(process.env.COGNITO_JWKS_URL));

export const handler = async (event) => {
    const authHeader = event.authorizationToken;
    // console.log({authHeader});
    try {
        const jwtString = authHeader.split(' ')[1];
        // Verifies signature against Cognito JWKS, and validates `exp` claim
        const { payload: claims } = await jwtVerify(jwtString, JWKS, { algorithms: ['RS256'] });
        // console.log({ claims });
        const principalId = `${claims.sub}|${claims.username}`;
        return generatePolicy('Allow', event.methodArn, principalId);
    } catch (e) {
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
