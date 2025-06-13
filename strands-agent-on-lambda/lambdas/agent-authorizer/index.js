import jwt from 'jsonwebtoken';
import jwksClient from 'jwks-rsa';
import { promisify } from 'util';
const COGNITO_JWKS_URL = process.env.COGNITO_JWKS_URL;

const client = jwksClient({
    jwksUri: COGNITO_JWKS_URL,
    cache: true
});

const verifyJwt = promisify(jwt.verify);
function getKey(header, callback) {
    // console.log(`>getKey`);
    client.getSigningKey(header.kid, (err, key) => {
        if (err) return callback(err);
        const signingKey = key.getPublicKey();
        callback(null, signingKey);
    });
}

export const handler = async (event) => {
    const authHeader = event.authorizationToken;
    // console.log({authHeader});
    try {
        const jwtString = authHeader.split(' ')[1];
        const claims = await verifyJwt(jwtString, getKey, { algorithms: ['RS256'] });
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