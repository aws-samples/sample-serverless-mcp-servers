# A2A Lambda Python - Async with Push Notifications

An advanced Agent-to-Agent (A2A) communication system demonstrating asynchronous task processing with push notifications. This project showcases how AI agents can communicate through HTTP APIs with real-time updates via webhooks, built on AWS Lambda, API Gateway, LangGraph, and the A2A SDK.

## What is A2A with Push Notifications?

The A2A (Agent-to-Agent) protocol enables AI agents to communicate and collaborate. This implementation adds **push notifications** for asynchronous, long-running tasks:

1. **Client sends a request** to the server agent with a webhook URL
2. **Server immediately acknowledges** the request and returns a task ID
3. **Server processes asynchronously** using LangGraph agents
4. **Server pushes updates** to the client's webhook as the task progresses
5. **Client receives real-time notifications** about task status, artifacts, and completion

This pattern is ideal for:
- Long-running AI operations (complex reasoning, multi-step workflows)
- Resource-intensive tasks (large data processing, multiple API calls)
- Multi-agent orchestration with intermediate updates
- Decoupled client-server architectures

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client API    │───▶│  Client Lambda  │───▶│  Server API     │───▶│  Server Lambda  │
│   Gateway       │    │   (A2A Client)  │    │   Gateway       │    │ (Currency Agent │
│                 │    │                 │    │                 │    │  + LangGraph)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                                              │
         │                       ▼                                              │
         │              ┌─────────────────┐                                     │
         │              │   Parameter     │                                     │
         │              │     Store       │                                     │
         │              │ - Server URL    │                                     │
         │              │ - Webhook URL   │                                     │
         │              └─────────────────┘                                     │
         │                                                                      │
         │                                                                      │
         │              ┌─────────────────┐                                     │
         └─────────────▶│  Webhook Lambda │◀────────────────────────────────────┘
                        │  (Push Notif    │         Push Notifications
                        │   Handler)      │         (Task Updates)
                        └─────────────────┘
```

## How Push Notifications Work

### Flow Diagram

```
Client                    Server                    LangGraph Agent
  │                         │                              │
  │  1. POST /summary       │                              │
  │  + webhook URL          │                              │
  ├────────────────────────▶│                              │
  │                         │                              │
  │  2. Task Created        │                              │
  │  (202 Accepted)         │                              │
  │◀────────────────────────┤                              │
  │                         │                              │
  │                         │  3. Start Processing         │
  │                         ├─────────────────────────────▶│
  │                         │                              │
  │  4. Push: Working       │                              │
  │  (Tool Execution)       │                              │
  │◀────────────────────────┤                              │
  │                         │                              │
  │                         │  5. Tool Results             │
  │                         │◀─────────────────────────────┤
  │                         │                              │
  │  6. Push: Processing    │                              │
  │  (Generating Response)  │                              │
  │◀────────────────────────┤                              │
  │                         │                              │
  │                         │  7. Final Response           │
  │                         │◀─────────────────────────────┤
  │                         │                              │
  │  8. Push: Completed     │                              │
  │  (Final Artifact)       │                              │
  │◀────────────────────────┤                              │
```

### Push Notification Events

The server sends these event types to the webhook:

1. **Task Status Update** (`task/status/update`)
   - `state`: `submitted`, `working`, `input_required`, `completed`, `failed`
   - `message`: Optional message from the agent
   - `timestamp`: ISO 8601 timestamp

2. **Task Artifact Update** (`task/artifact/update`)
   - `artifact`: The generated content/result
   - `append`: Whether to append or replace
   - `lastChunk`: Whether this is the final chunk

## Features

- **Asynchronous Processing**: Long-running tasks don't block the client
- **Real-time Updates**: Webhook notifications for task progress
- **LangGraph Integration**: Sophisticated agent workflows with tools
- **Currency Conversion Agent**: Example agent with external API integration
- **AWS Bedrock**: Claude Sonnet 4 for AI processing
- **Conversation Memory**: Persistent context across interactions
- **Parameter Store**: Dynamic configuration management
- **Observability**: X-Ray tracing and structured logging

## Project Structure

```
a2a-lambda-python-async/
├── src/
│   ├── client/
│   │   ├── client.py           # A2A client with push notification config
│   │   ├── webhook.py          # Webhook handler for push notifications
│   │   └── requirements.txt    # Client dependencies
│   └── server/
│       ├── server.py           # A2A server with FastAPI
│       ├── agent.py            # LangGraph currency agent
│       ├── agent_executor.py   # A2A executor bridging to LangGraph
│       ├── helpers.py          # Task and event processing utilities
│       ├── run.sh             # Server startup script
│       └── requirements.txt    # Server dependencies
├── template.yaml              # SAM template
├── samconfig.toml            # SAM configuration
├── openapi-client.yaml       # Client API specification
├── openapi-server.yaml       # Server API specification
└── README.md
```

## Prerequisites

- AWS CLI configured with appropriate permissions
- AWS SAM CLI installed
- Python 3.13
- Docker (for local testing)
- AWS Bedrock access (Claude Sonnet 4 model enabled)

## Dependencies

### Client
- `boto3`: AWS SDK for Python
- `a2a-sdk`: A2A protocol implementation

### Server
- `boto3`: AWS SDK for Python
- `langchain-aws`: LangChain AWS integrations
- `langgraph-api`: LangGraph for agent workflows
- `a2a-sdk[http-server]`: A2A server implementation
- `uvicorn`: ASGI server for FastAPI

## Setup and Deployment

### 1. Build the Application

```bash
sam build
```

This compiles the Lambda functions and installs dependencies.

### 2. Deploy to AWS

For first-time deployment:

```bash
sam deploy --guided
```

You'll be prompted for:
- **Stack Name**: e.g., `a2a-lambda-python-async`
- **AWS Region**: e.g., `us-east-1`
- **Confirm changes**: `N` (for faster deployments)
- **Allow IAM role creation**: `Y`
- **Save to samconfig.toml**: `Y`

For subsequent deployments:

```bash
sam deploy
```

### 3. Verify Deployment

After deployment, note the outputs:

```bash
# Get stack outputs
aws cloudformation describe-stacks \
  --stack-name a2a-lambda-python-async \
  --query 'Stacks[0].Outputs'
```

You should see:
- `A2AClientInvokeApiEndpoint`: Client API endpoint
- `A2AClientWebhookEndpoint`: Webhook URL for push notifications
- `A2AServerApiEndpoint`: Server API endpoint

### 4. Test the System

#### Option A: Via API Gateway

```bash
# Invoke the client (which will trigger async processing)
curl -X POST https://your-client-api.execute-api.region.amazonaws.com/dev/summary/ \
  -H "Content-Type: application/json" \
  -d '{"message": "How much is 100 USD in EUR?"}'
```

#### Option B: Direct Lambda Invocation

```bash
aws lambda invoke \
  --function-name a2a-lambda-python-async-A2AClientFunction \
  --payload '{"message": "What is the exchange rate between USD and GBP?"}' \
  response.json

cat response.json
```

#### Option C: Watch Webhook Logs

Monitor the webhook receiving push notifications:

```bash
sam logs -n A2AClientWebhookFunction --stack-name a2a-lambda-python-async --tail
```

You'll see real-time updates as the server processes the request.

## Configuration

### Environment Variables

#### Client Lambda
- `SERVER_ENDPOINT_URL`: Parameter Store key for server URL
- `WEBHOOK_URL_PARAM_KEY`: Parameter Store key for webhook URL

#### Server Lambda
- `AWS_LAMBDA_EXEC_WRAPPER`: Lambda Web Adapter configuration
- `AWS_LWA_READINESS_CHECK_PATH`: Health check path (`/health`)
- `AWS_LWA_PORT`: Server port (`8000`)

### Parameter Store Values

The deployment automatically creates:

1. **Server Endpoint URL** (`/a2a-async/config/ServerEndpointUrl`)
   - Value: `https://{ServerApi}.execute-api.{region}.amazonaws.com`
   - Used by client to locate the server

2. **Client Webhook URL** (`/a2a-async/config/ClientWebhookUrl`)
   - Value: `https://{ClientApi}.execute-api.{region}.amazonaws.com/dev/notify`
   - Used by server to send push notifications

## How It Works

### 1. Client Sends Request

```python
# client.py
push_config = PushNotificationConfig(url=CLIENT_WEBHOOK)
config = ClientConfig(
    httpx_client=httpx_client,
    push_notification_configs=[push_config],
    streaming=True,
)
client = factory.create(agent_card)
async for event in client.send_message(msg):
    # Process initial response
```

### 2. Server Receives and Processes

```python
# server.py
request_handler = DefaultRequestHandler(
    agent_executor=CurrencyAgentExecutor(),
    task_store=InMemoryTaskStore(),
    push_config_store=push_config_store,
    push_sender=push_sender
)
```

### 3. Agent Executes with Tools

```python
# agent.py
@tool
def get_exchange_rate(currency_from: str, currency_to: str):
    """Fetch real-time exchange rates"""
    response = httpx.get(f'https://api.frankfurter.app/latest', ...)
    return response.json()

# LangGraph agent with memory
graph = create_react_agent(
    model,
    tools=[get_exchange_rate],
    checkpointer=memory,
)
```

### 4. Server Pushes Updates

```python
# agent_executor.py
async for item in self.agent.stream(query, task.contextId):
    task_artifact_update_event, task_status_event = (
        process_streaming_agent_response(task, item)
    )
    event_queue.enqueue_event(task_artifact_update_event)
    event_queue.enqueue_event(task_status_event)
```

### 5. Webhook Receives Notifications

```python
# webhook.py
def lambda_handler(event, context):
    # Log the push notification
    print(json.dumps(event, indent=2))
    return {'statusCode': 200}
```

## Local Development

### Start Server Locally

```bash
cd src/server
python server.py
```

Server runs at `http://127.0.0.1:8000`

### Test Endpoints

```bash
# Health check
curl http://127.0.0.1:8000/health

# Get agent card
curl http://127.0.0.1:8000/agent-card

# Send message (requires full A2A client setup)
```

### SAM Local Testing

```bash
# Start API Gateway locally
sam local start-api

# Invoke client function
sam local invoke A2AClientFunction -e events/test-event.json
```

## Monitoring and Troubleshooting

### CloudWatch Logs

```bash
# Client logs
sam logs -n A2AClientFunction --stack-name a2a-lambda-python-async --tail

# Server logs
sam logs -n A2AServerFunction --stack-name a2a-lambda-python-async --tail

# Webhook logs
sam logs -n A2AClientWebhookFunction --stack-name a2a-lambda-python-async --tail
```

### X-Ray Tracing

View distributed traces in AWS X-Ray console to see:
- Client → Server communication
- Server → Bedrock API calls
- Server → External API (Frankfurter) calls
- Push notification delivery

### Common Issues

1. **No Push Notifications Received**
   - Check webhook Lambda logs
   - Verify Parameter Store has correct webhook URL
   - Ensure server has `pushNotifications: true` in agent card

2. **Bedrock Access Denied**
   - Verify IAM role has Bedrock permissions
   - Check model ID is correct for your region
   - Ensure Bedrock model access is enabled in AWS console

3. **Timeout Errors**
   - Increase Lambda timeout in `template.yaml`
   - Check external API availability (Frankfurter)
   - Review agent tool execution time

4. **Parameter Store Errors**
   - Verify parameters exist: `aws ssm get-parameter --name /a2a-async/config/ServerEndpointUrl`
   - Check IAM permissions for SSM access

## IAM Permissions

The Lambda execution role includes:

- **CloudWatch Logs**: Log group creation and writing
- **X-Ray**: Distributed tracing
- **Bedrock**: Model invocation (Claude Sonnet 4)
- **Parameter Store**: Reading configuration values
- **Lambda**: Function invocation (for webhooks)

## Cleanup

To remove all resources:

```bash
sam delete --stack-name a2a-lambda-python-async
```

This will delete:
- Lambda functions (Client, Server, Webhook)
- API Gateways (Client API, Server API)
- IAM roles and policies
- CloudWatch log groups
- Parameter Store entries

Confirm deletion when prompted.

## Advanced Usage

### Custom Agent Implementation

Replace the currency agent with your own:

```python
# agent.py
class MyCustomAgent:
    def invoke(self, query: str, sessionId: str) -> dict:
        # Your synchronous logic
        pass
    
    async def stream(self, query: str, sessionId: str):
        # Your streaming logic
        yield {...}
```

### Multiple Webhook Handlers

Add different handlers for different event types:

```python
# webhook.py
def lambda_handler(event, context):
    body = json.loads(event['body'])
    event_kind = body.get('kind')
    
    if event_kind == 'task/status/update':
        handle_status_update(body)
    elif event_kind == 'task/artifact/update':
        handle_artifact_update(body)
```

### Database Task Store

Replace in-memory storage with DynamoDB:

```python
# server.py
from a2a.server.tasks import DatabaseTaskStore

task_store = DatabaseTaskStore(
    table_name='a2a-tasks',
    region_name='us-east-1'
)
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally and with SAM
5. Submit a pull request

## Resources

- [A2A Protocol Specification](https://github.com/anthropics/anthropic-sdk-python)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [AWS SAM Documentation](https://docs.aws.amazon.com/serverless-application-model/)
- [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)

## License

This project is licensed under the the MIT-0 License License.
