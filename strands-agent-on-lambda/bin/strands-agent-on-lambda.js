#!/usr/bin/env node

const cdk = require('aws-cdk-lib');
const { StrandsAgentOnLambdaStack } = require('../lib/strands-agent-on-lambda-stack');

const app = new cdk.App();
new StrandsAgentOnLambdaStack(app, 'StrandsAgentOnLambdaStack');
