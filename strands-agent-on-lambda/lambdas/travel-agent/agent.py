from strands import Agent
from strands.session.s3_session_manager import S3SessionManager
import os
import logging
from user import User
import mcp_client_manager
import tools
from agent_config import model, system_prompt

l = logging.getLogger(__name__)
l.setLevel(logging.INFO)

SESSION_STORE_BUCKET_NAME = os.environ['SESSION_STORE_BUCKET_NAME']
l.info(f"SESSION_STORE_BUCKET_NAME={SESSION_STORE_BUCKET_NAME}")

def prompt(user: User, composite_prompt: str):
    l.info(f"user.id={user.id}, user.name={user.name}")

    session_manager = S3SessionManager(
        session_id=f"session_for_user_{user.id}",
        bucket=SESSION_STORE_BUCKET_NAME,
        prefix="agent_sessions"
    )

    try:
        mcp_tools = mcp_client_manager.get_mcp_tools_for_user(user)
        agent = Agent(
            model=model,
            agent_id="travel_agent",
            session_manager=session_manager,
            system_prompt=system_prompt,
            callback_handler=None,
            tools=[tools] + mcp_tools,

        )
        agent_response = agent(composite_prompt)
        response_text = agent_response.message["content"][0]["text"]
        return response_text

    except Exception as e:

        l.info(type(e))

        # l.error(e)
        return 'Failed to initialize MCP Client, see logs'

