import os
import boto3
import asyncio
import logging
import httpx
from uuid import uuid4
from a2a.client import A2AClient, A2ACardResolver, ClientConfig, ClientFactory
from a2a.types import Message, Part, Role, TextPart, PushNotificationConfig

DEFAULT_TIMEOUT = 300

ssm = boto3.client('ssm')
params_response = ssm.get_parameters(Names=[os.getenv("SERVER_ENDPOINT_URL"), os.getenv("WEBHOOK_URL_PARAM_KEY")])
for param in params_response['Parameters']:
    if param['Name'] == os.getenv("SERVER_ENDPOINT_URL"):
        PUBLIC_SERVER_ENDPOINT = param['Value']

    if param['Name'] == os.getenv("WEBHOOK_URL_PARAM_KEY"):
        CLIENT_WEBHOOK = param['Value'] 

async def send_with_push_notifications(message: str, context_id: str = None):
    async with httpx.AsyncClient(timeout=300) as httpx_client:
        # Get agent card
        resolver = A2ACardResolver(
            httpx_client=httpx_client,
            base_url=PUBLIC_SERVER_ENDPOINT
        )
        agent_card = await resolver.get_agent_card()
        
        # Create push notification config
        push_config = PushNotificationConfig(
            url=CLIENT_WEBHOOK
        )
        
        # Create client
        config = ClientConfig(
            httpx_client=httpx_client,
            push_notification_configs=[push_config],
            streaming=True,
        )
        factory = ClientFactory(config)
        client = factory.create(agent_card)
        
        # Create message
        msg = Message(
            kind="message",
            role=Role.user,
            parts=[Part(TextPart(kind="text", text=message))],
            message_id=uuid4().hex,
        )
        
        # Send message with push notifications
        results = []
        async for event in client.send_message(msg):
            results.append(event)
        
        # return results    

def lambda_handler(event, context):
    message = event.get('message', 'How much is 100 USD in INR?')    
    result = asyncio.run(send_with_push_notifications(message))
    
    # return {
    #     'statusCode': 200,
    #     'body': {
    #         'message': 'Request sent with push notifications',
    #         'result': 'Message sent to server'
    #     }
    # }

# if __name__ == '__main__':
#     asyncio.run(send_with_push_notifications('How much is 100 USD in INR?'))
#     print("Server invoked")