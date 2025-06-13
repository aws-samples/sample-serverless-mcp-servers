import boto3
import logging
import os
import json
import agent_builder
from user import User

ddb = boto3.resource('dynamodb')
agent_state_table = ddb.Table(os.environ['STATE_TABLE_NAME'])
l = logging.getLogger(__name__)
l.setLevel(logging.INFO)

def save(user: User, agent):
    l.info(f"saving agent state for user.id={user.id}")
    agent_state_table.put_item(Item={
        'user_id': user.id,
        'state': json.dumps(agent.messages),
    })


def restore(user: User):
    l.info(f"restoring agent state for user.id={user.id}")
    ddb_response = agent_state_table.get_item(Key={'user_id': user.id})
    item = ddb_response.get('Item')
    if item:
        messages=json.loads(item['state'])
    else:
        messages = []

    print(f"messages={messages}")
    return agent_builder.build(user, messages)



