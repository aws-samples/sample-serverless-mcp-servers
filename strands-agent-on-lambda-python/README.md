# Strands Agent on AWS Lambda (Python)

This project demonstrates how to deploy a Strands Agent on AWS Lambda using Python. The implementation uses Amazon API Gateway for REST endpoints and AWS Lambda as the serverless compute backend.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Python 3.x
- Make
- AWS SAM CLI
- Docker Desktop or Podman for local builds
- Strands Agent testing tools

## Project Structure

```
strands-agent-on-lambda-python/
├── build/         # Build artifacts
├── etc/           # Configuration files
├── sam/           # SAM template files
├── src/           # Source code
├── tmp/           # Temporary files
└── makefile       # Build and deployment commands
```

## Configuration

Before deploying, you need to configure the environment variables in `etc/environment.sh`:

1. AWS Configuration:
   - `PROFILE`: Your AWS CLI profile name
   - `BUCKET`: S3 bucket name for deployment artifacts
   - `REGION`: AWS region (default: us-east-1)

2. Strands Agent Dependencies:
   - `P_DESCRIPTION`: Strands Agent package version
   - `O_LAYER_ARN`: This will be updated after creating the Lambda layer

3. API Gateway and Lambda Configuration:
   - `P_API_STAGE`: API Gateway stage name (default: dev)
   - `P_FN_MEMORY`: Lambda function memory in MB (default: 128)
   - `P_FN_TIMEOUT`: Lambda function timeout in seconds (default: 15)

## Deployment Steps

1. Create the Lambda Layer:
   ```bash
   make layer
   ```
   After execution, copy the `outLayer` value and update the `O_LAYER_ARN` in `etc/environment.sh`.

2. Deploy the API Gateway and Lambda function:
   ```bash
   make apigw
   ```
   This will create the API Gateway and Lambda function, which will have the Strands Agent dependencies layer attached.

   After execution, copy the `outApiEndpoint` value and update the `O_API_ENDPOINT` in `etc/environment.sh`. This is important for testing later.

   The provided `template.yaml` file assumes a deployment in us-east-1. If deploying to an alternate region, update the ARN for the [Lambda Insights extension](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Lambda-Insights-extension-versions.html) and the [Lambda Web Adapter](https://github.com/awslabs/aws-lambda-web-adapter?tab=readme-ov-file#lambda-functions-packaged-as-zip-package-for-aws-managed-runtimes).

## Testing

Ensure that `O_API_ENDPOINT` has been updated with your endpoint, e.g. https://<api-id>.execute-api.<region>.amazonaws.com/<stage>

1. Run make `curl.post.sync` to make a synchronous request to the API endpoint with the Strands Agent application. This is a synchronous request to the agent, which could take 30-40 seconds to respond.
2. Run make `curl.post.stream` to make a non-buffered streaming request to the API endpoint with the Strands Agent application. Note that this currently will also return a synchronous response, taking a similar amount of time as the sync request, as API Gateway does not yet support response streaming from Lambda.

## Make Commands

- `make layer`: Creates the Lambda layer with Strands Agent dependencies
- `make apigw`: Deploys the API Gateway and Lambda function

## Troubleshooting

If you encounter any issues:
1. Ensure all environment variables are properly set in `etc/environment.sh`
2. Verify AWS credentials are correctly configured
3. Check AWS CloudWatch logs for Lambda function errors
4. Ensure the S3 bucket specified in `BUCKET` exists, is accessible, and has versioning enabled
