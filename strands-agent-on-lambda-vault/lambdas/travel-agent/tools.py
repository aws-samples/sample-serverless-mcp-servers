from urllib import request
import json
from strands import tool
from datetime import datetime

@tool(name="get_user_location", description="Retrieves user's address based on the IP address")
def get_user_location(ip: str) -> str:
    print(f'> tool_get_user_location ip={ip}')
    resp = request.urlopen(f"http://ip-api.com/json/{ip}").read()
    resp = json.loads(resp.decode('utf-8'))
    addr = f"{resp['city']} {resp['region']}, {resp['country']}"
    print(f'> tool_get_user_location addr={addr}')
    return addr

@tool(name="get_todays_date", description="Retrieves today's date for accuracy")
def get_todays_date() -> str:
    today = datetime.today().strftime('%Y-%m-%d')
    print(f'> get_todays_date today={today}')
    return today
