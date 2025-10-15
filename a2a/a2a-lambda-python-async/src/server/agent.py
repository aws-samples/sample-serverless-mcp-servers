import os
import httpx
import boto3
from langchain_aws import ChatBedrock
from langgraph.prebuilt import create_react_agent
from langgraph.checkpoint.memory import MemorySaver
from langchain_core.tools import tool
from pydantic import BaseModel
from typing import Literal, Any, AsyncIterable
from langchain_core.runnables import RunnableConfig
from langchain_core.messages import AIMessage, ToolMessage

# Memory for conversation persistence
memory = MemorySaver()

session = boto3.Session(region_name=os.getenv("AWS_REGION"))
bedrock_client = session.client('bedrock-runtime')

@tool
def get_exchange_rate(
    currency_from: str = 'USD',
    currency_to: str = 'EUR',
    currency_date: str = 'latest',
):
    """Use this to get current exchange rate."""
    try:
        response = httpx.get(
            f'https://api.frankfurter.app/{currency_date}',
            params={'from': currency_from, 'to': currency_to},
        )
        response.raise_for_status()
        data = response.json()
        
        if 'error' in data:
            return {'error': data['error']}
        
        return data
    except httpx.HTTPError as e:
        return {'error': f'API request failed: {e}'}


class ResponseFormat(BaseModel):
    """Respond to the user in this format."""
    status: Literal['input_required', 'completed', 'error'] = 'input_required'
    message: str


class CurrencyAgent:
    """Currency conversion agent using LangGraph."""
    
    SYSTEM_INSTRUCTION = """You are a helpful currency conversion assistant.
    
    Your job is to help users convert between different currencies using current exchange rates.
    
    Guidelines:
    - Always ask for clarification if the user's request is incomplete
    - Use the get_exchange_rate tool to fetch real-time exchange rates
    - Provide clear, concise responses
    - If you need more information, set status to 'input_required'
    - When you have all the information needed, set status to 'completed'
    """
    
    RESPONSE_FORMAT_INSTRUCTION = """Always respond in the specified format with status and message."""
    
    SUPPORTED_CONTENT_TYPES = ['text/plain']
    

    def __init__(self):
        self.model = ChatBedrock(
            model_id='us.anthropic.claude-sonnet-4-20250514-v1:0',
            client=bedrock_client
        )
        self.tools = [get_exchange_rate]
        self.graph = create_react_agent(
            self.model,
            tools=self.tools,
            checkpointer=memory,
            prompt=self.SYSTEM_INSTRUCTION,
            response_format=(self.RESPONSE_FORMAT_INSTRUCTION, ResponseFormat),
        )
    
    def invoke(self, query: str, sessionId: str) -> dict[str, Any]:
        """Invoke the agent synchronously."""
        config: RunnableConfig = {'configurable': {'thread_id': sessionId}}
        self.graph.invoke({'messages': [('user', query)]}, config)
        return self.get_agent_response(config)
    
    async def stream(
        self, query: str, sessionId: str
    ) -> AsyncIterable[dict[str, Any]]:
        """Stream agent responses asynchronously."""
        inputs: dict[str, Any] = {'messages': [('user', query)]}
        config: RunnableConfig = {'configurable': {'thread_id': sessionId}}
        
        for item in self.graph.stream(inputs, config, stream_mode='values'):
            message = item['messages'][-1]
            
            if isinstance(message, AIMessage) and message.tool_calls:
                yield {
                    'is_task_complete': False,
                    'require_user_input': False,
                    'content': 'Looking up the exchange rates...',
                }
            elif isinstance(message, ToolMessage):
                yield {
                    'is_task_complete': False,
                    'require_user_input': False,
                    'content': 'Processing the exchange rates..',
                }
        
        yield self.get_agent_response(config)
    
    def get_agent_response(self, config: dict) -> dict[str, Any]:
        """Get the final agent response."""
        state = self.graph.get_state(config)
        last_message = state.values['messages'][-1]
        
        if hasattr(last_message, 'content'):
            content = last_message.content
        else:
            content = str(last_message)
        
        # Determine if task is complete or needs user input
        is_task_complete = 'completed' in content.lower()
        require_user_input = 'input_required' in content.lower()
        
        return {
            'is_task_complete': is_task_complete,
            'require_user_input': require_user_input,
            'content': content,
        }