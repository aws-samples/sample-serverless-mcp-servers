
export const handler = async (event) => {
    const authToken = event.authorizationToken;
    if (!authToken) {
        return generatePolicy('Deny', event.methodArn);
    }

    if (authToken === 'Bearer good_access_token') {
        return generatePolicy('Allow', event.methodArn);
    }

    return generatePolicy('Deny', event.methodArn);

};

const generatePolicy = (effect, resource) => {
    return {
        principalId: 'user',
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