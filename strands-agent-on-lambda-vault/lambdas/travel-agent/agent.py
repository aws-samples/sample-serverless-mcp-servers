from strands.types.exceptions import MCPClientInitializationError
from strands import Agent
from strands.session import S3SessionManager

import agent_config
import logging
from user import User

l = logging.getLogger(__name__)
l.setLevel(logging.INFO)

def prompt(user: User, text: str):
    l.info(f"user.id={user.id}, user.name={user.name}")

    try:
        # Get agent configuration
        config = agent_config.get_agent_config(user)
        
        # Create S3SessionManager
        session_manager = S3SessionManager(
            bucket=config["bucket_name"],
            session_id=config["session_id"],
            prefix="agent_sessions"
        )
        
        # Create agent with session manager
        agent = Agent(
            model=config["model"],
            system_prompt=config["system_prompt"],
            tools=config["tools"],
            session_manager=session_manager
        )
        
    except Exception as e:
        l.error(f"Error initializing agent: {str(e)}", exc_info=True)
        return 'Failed to initialize MCP Client, see logs'

    # Process the prompt - session is automatically loaded and saved by the session manager
    agent_response = agent(text)
    
    response_text = agent_response.message["content"][0]["text"]
    return response_text
