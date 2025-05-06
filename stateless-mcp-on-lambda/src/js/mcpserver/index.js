import './logging.js';
import log4js from 'log4js';
import express from 'express';
import metadata from './metadata.js';
import transport from './transport.js';
import serverlessExpress from '@codegenie/serverless-express';

await metadata.init();

const l = log4js.getLogger();
const PORT = 3000;

const app = express();
app.use(express.json());

app.get('/health', (req, res) => {
    res.json(metadata.all);
});

app.use(async (req, res, next) => {
    l.debug(`> ${req.method} ${req.originalUrl}`);
    l.debug(req.body);
    // l.debug(req.headers);
    return next();
});

await transport.bootstrap(app); 

// Uncomment if you want to test locally
app.listen(PORT, () => {
    l.debug(metadata.all);
    l.debug(`listening on http://localhost:${PORT}`);
});

export const handler = serverlessExpress({ app });
