from user import User
import jwt
from strands.tools.mcp.mcp_client import MCPClient
from mcp.client.streamable_http import streamablehttp_client
import os
import logging

jwt_signature_secret = os.environ['JWT_SIGNATURE_SECRET']
mcp_endpoint = os.getenv("MCP_ENDPOINT")

l = logging.getLogger(__name__)

mcp_tools = {}
mcp_clients = {}

def get_mcp_tools_for_user(user: User):
    if user.id in mcp_tools and user.id in mcp_clients:
        l.info(f"existing mcp client/tools found for user.id={user.id}")
        return mcp_tools[user.id]

    l.info(f"mcp client/tools for user.id={user.id} not found. creating.")

    token = jwt.encode({
        "sub":"travel-agent",
        "user_id": user.id,
        "user_name": user.name,
    }, jwt_signature_secret, algorithm="HS256")
    l.info(token)

    mcp_client = MCPClient(lambda: streamablehttp_client(
        url=mcp_endpoint,
        headers={"Authorization": f"Bearer {token}"},
    ))

    mcp_client.start()
    tools = mcp_client.list_tools_sync()

    mcp_clients[user.id] = mcp_client
    mcp_tools[user.id] = tools
    return mcp_tools[user.id]

