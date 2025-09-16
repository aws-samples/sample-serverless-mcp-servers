# Stateless MCP on AWS Lambda (Python)

This project demonstrates how to deploy a stateless MCP (Model Context Protocol) server on AWS Lambda using Python. The implementation uses Amazon API Gateway for HTTP endpoints and AWS Lambda as the serverless compute backend.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Python 3.x
- Make
- AWS SAM CLI
- Docker Desktop or Podman for local builds
- MCP Inspector tool for testing

## Project Structure

```
stateless-mcp-on-lambda-python/
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

2. MCP Dependencies:
   - `P_DESCRIPTION`: MCP package version (default: "mcp==1.8.0")
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

2. Deploy the API Gateway and Lambda function:
   ```bash
   make apigw
   ```
   This will create the API Gateway and Lambda function, which will have the MCP dependencies layer attached.

   The provided `template.yaml` file assumes a deployment in us-east-1. If deploying to an alternate region, update the ARN for the [Lambda Insights extension](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Lambda-Insights-extension-versions.html) and the [Lambda Web Adapter](https://github.com/awslabs/aws-lambda-web-adapter?tab=readme-ov-file#lambda-functions-packaged-as-zip-package-for-aws-managed-runtimes).

## Testing

1. After deployment, you'll receive an `outApiEndpoint` value.
2. Use [MCP Inspector](https://modelcontextprotocol.io/docs/tools/inspector#py-pi-package) to test the endpoint:
   - After setting up MCP Inspector, you can start the tool with the following command: `mcp dev src/mcpserver/server.py`
   - Enter the following URL in MCP Inspector: `${outApiEndpoint}/echo/mcp/`
   - NOTE: The trailing `/` at the end of the URL is important, as the MCP SDK will otherwise do a redirect on the backend.
      - Without it, MCP Inspector fails with the following error: "Connection Error, is your MCP server running?"
      - Without it, Postman fails with the following error: "Couldn't run the request: SSE error: Non-200 status code (403)"

## Make Commands

- `make layer`: Creates the Lambda layer with MCP dependencies
- `make apigw`: Deploys the API Gateway and Lambda function

## Additional Context
The `src/mcpserver/server.py` file includes three operating modes:
1. `--mode stdio` which runs the server using the STDIO transport for local testing
2. `--mode streamable-http` which runs the server using Streamable HTTP transport, using a FastMCP server
3. `--mode fastapi` which attaches the FastMCP server to an existing WSGI server, here using a FastAPI server

The latter two modes are similar from a client perspective. The key difference is that when mounting the FastMCP server to a FastAPI server, it does so using a mount, which introduces an additional path component in the URL. For example:
1. `--mode streamable-http` might produce an endpoint as follows: https://<api-id>.execute-api.<region>.amazonaws.com/dev/mcp/
2. `--mode fastapi` might produce an endpoint as follows (notice the additional mount point): https://<api-id>.execute-api.<region>.amazonaws.com/dev/mountpoint/mcp/

## Troubleshooting

If you encounter any issues:
1. Ensure all environment variables are properly set in `etc/environment.sh`
2. Verify AWS credentials are correctly configured
3. Check AWS CloudWatch logs for Lambda function errors
4. Ensure the S3 bucket specified in `BUCKET` exists, is accessible, and has versioning enabled
