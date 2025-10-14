import os
import boto3
import asyncio
import logging
import httpx
from a2a.client import A2ACardResolver, ClientConfig, ClientFactory
from a2a.types import Message, Part, Role, TextPart
from uuid import uuid4

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DEFAULT_TIMEOUT = 300 # set request timeout to 5 minutes

ssm = boto3.client('ssm')
parameter = ssm.get_parameter(Name=os.getenv("SERVER_ENDPOINT_URL"))
public_server_endpoint = parameter['Parameter']['Value']

def create_message(*, role: Role = Role.user, text: str) -> Message:
    return Message(
        kind="message",
        role=role,
        parts=[Part(TextPart(kind="text", text=text))],
        message_id=uuid4().hex,
    )

async def send_sync_message(message: str, base_url: str = public_server_endpoint):
    async with httpx.AsyncClient(timeout=DEFAULT_TIMEOUT) as httpx_client:
        # Get agent card
        resolver = A2ACardResolver(httpx_client=httpx_client, base_url=base_url)
        agent_card = await resolver.get_agent_card()

        # Create client using factory
        config = ClientConfig(
            httpx_client=httpx_client,
            streaming=False,  # Use non-streaming mode for sync response
        )
        factory = ClientFactory(config)
        client = factory.create(agent_card)

        # Create and send message
        msg = create_message(text=message)

        # With streaming=False, this will yield exactly one result
        async for event in client.send_message(msg):
            if isinstance(event, Message):
                logger.info(event.model_dump_json(exclude_none=True, indent=2))
                return event
            elif isinstance(event, tuple) and len(event) == 2:
                # (Task, UpdateEvent) tuple
                task, update_event = event
                logger.info(f"Task: {task.model_dump_json(exclude_none=True, indent=2)}")
                if update_event:
                    logger.info(f"Update: {update_event.model_dump_json(exclude_none=True, indent=2)}")
                return task
            else:
                # Fallback for other response types
                logger.info(f"Response: {str(event)}")
                return event


def lambda_handler(event, context):
    result = asyncio.run(send_sync_message("what is 101 * 11"))

    return {
        'statusCode': 200,
        'body': result.model_dump_json(exclude_none=True, indent=2)
    }
