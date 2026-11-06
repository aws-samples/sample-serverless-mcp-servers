import './logging.js';
import log4js from 'log4js';
import express from 'express';
import transport from './transport.js';
import packageInfo from './package.json' with { type: 'json'};
import jwt from 'jsonwebtoken';
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

// Load the JWT signature secret once, during startup. Fail fast if it's
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

const l = log4js.getLogger();
const PORT = process.env.AWS_LWA_PORT || process.env.PORT || 3001;

// This function is using Lambda Web Adapter to run express.js on Lambda
// https://github.com/awslabs/aws-lambda-web-adapter
const app = express();

app.use(express.json());
app.use(async (req, res, next) => {
    l.debug(`> ${req.method} ${req.originalUrl}`);
    l.debug(req.body);
    // l.debug(req.headers);
    return next();
});
    
app.use('/mcp', async (req, res, next) => {
    // Validate authorization header
    const authorizationHeader = req.headers['authorization'];
    try {
        const jwtString = authorizationHeader.split(' ')[1];
        // Also validates `exp` claim
        const claims = jwt.verify(jwtString, JWT_SIGNATURE_SECRET, { algorithms: ['HS256'] });
        // Inject authorization context into request 
        // object so MCP Server will pick it up automatically
        req.auth = claims;
    } catch (e) {
        l.warn(`Failed to parse authorization header, ${e}`);
        return res.status(401).send('Unauthorized');
    }

    return next();
});

await transport.bootstrap(app);

app.listen(PORT, () => {
    l.debug(`version=${packageInfo.version} :: listening on http://localhost:${PORT}`);
});



