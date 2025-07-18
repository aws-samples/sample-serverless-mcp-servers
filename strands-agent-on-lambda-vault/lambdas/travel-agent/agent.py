from strands.types.exceptions import MCPClientInitializationError

import agent_state_manager
import logging
from user import User
l = logging.getLogger(__name__)
l.setLevel(logging.INFO)

def prompt(user: User, text: str):
    l.info(f"user.id={user.id}, user.name={user.name}")

    try:
        agent = agent_state_manager.restore(user)
    except Exception as e:

        l.info(type(e))

        # l.error(e)
        return 'Failed to initialize MCP Client, see logs'

    agent_response = agent(text)

    agent_state_manager.save(user, agent)
    response_text = agent_response.message["content"][0]["text"]
    return response_text
