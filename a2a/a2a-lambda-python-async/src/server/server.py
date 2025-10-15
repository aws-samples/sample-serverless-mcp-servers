import os
import uvicorn
import httpx
import boto3
from a2a.server.apps import A2AFastAPIApplication
from a2a.server.request_handlers import DefaultRequestHandler
from a2a.types import (
    AgentCapabilities,
    AgentCard,
    AgentSkill,
)
from a2a.server.tasks import (
    InMemoryPushNotificationConfigStore,
    BasePushNotificationSender,
    InMemoryTaskStore,
    DatabaseTaskStore,
)
from agent_executor import CurrencyAgentExecutor

ssm = boto3.client('ssm')
parameter = ssm.get_parameter(Name=os.getenv("SERVER_ENDPOINT_URL"))
public_server_endpoint = parameter['Parameter']['Value']

def get_agent_card():
    """Returns the Agent Card for the Currency Agent."""
    capabilities = AgentCapabilities(
        streaming=True, 
        pushNotifications=True
    )
    
    skill = AgentSkill(
        id='convert_currency',
        name='Currency Exchange Rates Tool',
        description='Helps with exchange values between various currencies',
        tags=['currency conversion', 'currency exchange'],
        examples=['What is exchange rate between USD and GBP?'],
    )
    
    return AgentCard(
        name='Currency Agent',
        description='Helps with exchange rates for currencies',
        url=public_server_endpoint,
        version='1.0.0',
        defaultInputModes=['text/plain'],
        defaultOutputModes=['text/plain'],
        capabilities=capabilities,
        skills=[skill]
    )

# Server startup configuration
httpx_client = httpx.AsyncClient()

# 1. Create push notification config store
push_config_store = InMemoryPushNotificationConfigStore()

# 2. Create push notification sender
push_sender = BasePushNotificationSender(
    httpx_client=httpx_client,
    config_store=push_config_store
)

# 3. Create request handler with all components
request_handler = DefaultRequestHandler(
    agent_executor=CurrencyAgentExecutor(),
    task_store=InMemoryTaskStore(),
    push_config_store=push_config_store,
    push_sender=push_sender
)

# 4. Create A2A server application
app = A2AFastAPIApplication(
    agent_card=get_agent_card(),
    http_handler=request_handler
).build()

@app.get('/health')
async def health():
    return 'Ok'    

if __name__ == '__main__':
    uvicorn.run(app, host="127.0.0.1", port=8000)
