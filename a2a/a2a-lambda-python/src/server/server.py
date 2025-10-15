import os
import boto3
import uvicorn
import json
import logging
from strands_tools.calculator import calculator
from strands import Agent
from strands.multiagent.a2a import A2AServer
from strands.models import BedrockModel

logging.basicConfig(level=logging.INFO)

# Create AWS session
session = boto3.Session(
    region_name='us-east-1',
)

# Configure the model to be used by all agents
bedrock_model = BedrockModel(
    model_id="us.anthropic.claude-sonnet-4-20250514-v1:0",
    boto_session=session
)

# Create a Strands agent
strands_agent = Agent(
    model=bedrock_model,
    name="Calculator Agent",
    description="A calculator agent that can perform basic arithmetic operations.",
    tools=[calculator],
    callback_handler=None
)

ssm = boto3.client('ssm')
parameter = ssm.get_parameter(Name=os.getenv("SERVER_ENDPOINT_URL"))
public_server_endpoint = parameter['Parameter']['Value']

# Create A2A server (streaming enabled by default)
a2a_server = A2AServer(agent=strands_agent, http_url=public_server_endpoint, serve_at_root=True)
app = a2a_server.to_fastapi_app()

# for route in app.routes:
#     if hasattr(route, "methods"):  # API routes have methods
#         print(f"Path: {route.path}")
#         print(f"Name: {route.name}")
#         print(f"Methods: {route.methods}")
#         print("---")

@app.get('/health')
async def health():
    return 'Ok'

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
