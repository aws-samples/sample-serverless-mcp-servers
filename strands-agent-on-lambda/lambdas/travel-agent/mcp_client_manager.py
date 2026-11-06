from dataclasses import dataclass
from user import User
import boto3
import jwt
import time
from strands.tools.mcp.mcp_client import MCPClient
from mcp.client.streamable_http import streamablehttp_client
import os
import logging

l = logging.getLogger(__name__)

# Load the JWT signature secret once, during function init. Fails fast if
# it's not configured or can't be read - never falls back to a default value.
JWT_SIGNATURE_SECRET_ARN = os.environ['JWT_SIGNATURE_SECRET_ARN']
jwt_signature_secret = boto3.client('secretsmanager').get_secret_value(
    SecretId=JWT_SIGNATURE_SECRET_ARN
)['SecretString']

mcp_endpoint = os.getenv("MCP_ENDPOINT")

# Lifetime of the JWT the Agent presents to the MCP Server.
TOKEN_TTL_SECONDS = 15 * 60
# Replace the token (and its MCP client) this long before it expires, so a
# request in flight never uses an expired token. Must be > function timeout.
TOKEN_REFRESH_MARGIN_SECONDS = 60


@dataclass
class _UserMcpSession:
    client: MCPClient
    tools: list
    expires_at: float


# Per-user MCP clients, reused across warm invocations until their token nears expiry
_sessions: dict[str, _UserMcpSession] = {}


def _stop(user_id: str):
    session = _sessions.pop(user_id)
    try:
        session.client.stop(None, None, None)
    except Exception:
        l.warning(f"failed to stop mcp client for user.id={user_id}", exc_info=True)


def _evict_expiring(now: float):
    for user_id in [uid for uid, s in _sessions.items() if s.expires_at - TOKEN_REFRESH_MARGIN_SECONDS <= now]:
        l.info(f"mcp client token for user.id={user_id} is expiring, evicting")
        _stop(user_id)


def get_mcp_tools_for_user(user: User):
    now = time.time()
    _evict_expiring(now)

    if user.id in _sessions:
        l.info(f"existing mcp client/tools found for user.id={user.id}")
        return _sessions[user.id].tools

    l.info(f"mcp client/tools for user.id={user.id} not found. creating.")

    issued_at = int(now)
    expires_at = issued_at + TOKEN_TTL_SECONDS
    token = jwt.encode({
        "sub": "travel-agent",
        "user_id": user.id,
        "user_name": user.name,
        "iat": issued_at,
        "exp": expires_at,
    }, jwt_signature_secret, algorithm="HS256")

    mcp_client = MCPClient(lambda: streamablehttp_client(
        url=mcp_endpoint,
        headers={"Authorization": f"Bearer {token}"},
    ))

    mcp_client.start()
    tools = mcp_client.list_tools_sync()

    _sessions[user.id] = _UserMcpSession(client=mcp_client, tools=tools, expires_at=expires_at)
    return tools
