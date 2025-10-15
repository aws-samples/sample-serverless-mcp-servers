# A2A Lambda Python

An Agent-to-Agent (A2A) communication system built with AWS Lambda, API Gateway, and the Strands framework. This project demonstrates how to create a client-server architecture where AI agents can communicate with each other through HTTP APIs.

## Architecture

The project consists of two main components:

- **Client Lambda**: Acts as an A2A client that sends messages to the server agent
- **Server Lambda**: Hosts a calculator agent that can perform arithmetic operations

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client API    │───▶│  Client Lambda  │───▶│  Server API     │───▶│  Server Lambda  │
│   Gateway       │    │   (A2A Client)  │    │   Gateway       │    │ (Calculator     │
└─────────────────┘    └─────────────────┘    └─────────────────┘    │     Agent)      │
                                │                                    └─────────────────┘
                                ▼
                       ┌─────────────────┐
                       │   Parameter     │
                       │     Store       │
                       │ (Server Endpoint│
                       │      URL)       │
                       └─────────────────┘
```

## Features

- **A2A Communication**: Client and server agents communicate using the A2A protocol
- **Calculator Agent**: Server hosts a Strands agent with calculator capabilities
- **AWS Bedrock Integration**: Uses Claude Sonnet 4 model for AI processing
- **Parameter Store**: Stores server endpoint URL for dynamic configuration
- **Observability**: Includes X-Ray tracing and structured logging
- **ARM64 Architecture**: Optimized for AWS Graviton processors

## Prerequisites

- AWS CLI configured with appropriate permissions
- AWS SAM CLI installed
- Python 3.13
- Docker (for local testing)

## Project Structure

```
a2a-lambda-python/
├── src/
│   ├── client/
│   │   ├── client.py           # A2A client Lambda function
│   │   └── requirements.txt    # Client dependencies
│   └── server/
│       ├── server.py           # A2A server Lambda function
│       ├── run.sh              # Server startup script
│       └── requirements.txt    # Server dependencies
├── template.yaml               # SAM template
├── samconfig.toml              # SAM configuration
├── openapi-client.yaml         # Client API specification
├── openapi-server.yaml         # Server API specification
└── README.md
```

## Dependencies

### Client
- `boto3`: AWS SDK for Python
- `strands-agents`: AI agent framework
- `strands-agents-tools`: Additional tools for agents
- `strands-agents[a2a]`: A2A communication support

### Server
- All client dependencies plus:
- `uvicorn`: ASGI server for FastAPI

## Deployment

### 1. Build the application
```bash
sam build
```

### 2. Deploy to AWS
```bash
sam deploy --guided
```

For subsequent deployments:
```bash
sam deploy
```

### 3. Configuration Parameters

The deployment accepts these parameters:
- `StageName`: API Gateway stage name (default: `dev`)
- `ServerEndpointUrlName`: Parameter Store key for server URL (default: `ServerEndpointUrl`)

## Usage

### Testing the Client

The client Lambda automatically sends a test calculation request (`101 * 11`) to the server agent. You can invoke it via:

1. **API Gateway**: 
   ```bash
   curl -X POST https://your-client-api.execute-api.region.amazonaws.com/dev/summary/
   ```

2. **Direct Lambda invocation**:
   ```bash
   aws lambda invoke --function-name a2a-lambda-python-A2AClientFunction response.json
   ```

### Server Endpoints

The server exposes several A2A protocol endpoints:
- `GET /agent-card`: Returns agent capabilities
- `POST /messages`: Send messages to the agent
- `GET /health`: Health check endpoint

## Local Development

### Start the server locally
```bash
cd src/server
python server.py
```

The server will be available at `http://127.0.0.1:8000`

### Test with SAM Local
```bash
# Start API Gateway locally
sam local start-api

# Invoke function locally
sam local invoke A2AClientFunction
```

## IAM Permissions

The Lambda functions have permissions for:
- **CloudWatch Logs**: Creating log groups and streams
- **X-Ray**: Distributed tracing
- **Bedrock**: Invoking Claude Sonnet 4 model
- **Parameter Store**: Reading server endpoint URL

## Monitoring

- **CloudWatch Logs**: Structured JSON logging with 7-day retention
- **X-Ray Tracing**: Distributed tracing enabled for both functions
- **API Gateway Logs**: Access logging for both APIs

## Environment Variables

### Client Function
- `SERVER_ENDPOINT_URL`: Parameter Store key containing server URL

### Server Function
- `AWS_LAMBDA_EXEC_WRAPPER`: Lambda Web Adapter configuration
- `AWS_LWA_READINESS_CHECK_PATH`: Health check path
- `AWS_LWA_PORT`: Server port (8000)

## Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure the Lambda execution role has all required permissions
2. **Timeout Issues**: Increase function timeout if calculations take longer
3. **Parameter Store Access**: Verify the parameter exists and is accessible

### Logs

Check CloudWatch logs for both functions:
```bash
# Client logs
aws logs tail /aws/lambda/a2a-lambda-python-A2AClientFunction --follow

# Server logs  
aws logs tail /aws/lambda/a2a-lambda-python-A2AServerFunction --follow
```

## Cleanup

To remove all resources:
```bash
sam delete
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally and with SAM
5. Submit a pull request

## License

This project is licensed under the MIT-0 License.