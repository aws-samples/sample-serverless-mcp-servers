import jwt from 'jsonwebtoken';

const JWT_SIGNATURE_SECRET = process.env.JWT_SIGNATURE_SECRET;
const AUTHORIZED_SUB = 'travel-agent';

export const handler = async (event) => {
    const authHeader = event.authorizationToken;
    // console.log({authHeader});
    try {
        const jwtString = authHeader.split(' ')[1];
        const claims = jwt.verify(jwtString, JWT_SIGNATURE_SECRET);
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