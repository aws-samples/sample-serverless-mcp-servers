import logger
import agent
import json
import jwt
import os
from user import User
l = logger.get()

debug_token = "add-your-debug-jwt-here"

JWT_SIGNATURE_SECRET = os.environ['JWT_SIGNATURE_SECRET'] # Used for signing tokens to MCP Servers

COGNITO_JWKS_URL = os.environ['COGNITO_JWKS_URL']
jwks_client = jwt.PyJWKClient(COGNITO_JWKS_URL)

def get_jwt_claims(authorization_header):
    jwt_string = authorization_header.split(" ")[1]
    # print(jwt_string)
    signing_key = jwks_client.get_signing_key_from_jwt(jwt_string)
    claims = jwt.decode(jwt_string, signing_key.key, algorithms=["RS256"])
    # print(claims)
    return claims

def handler(event: dict, ctx):
    l.info("> handler")
    try:
        claims = get_jwt_claims(event["headers"]["Authorization"])
        user = User(id=claims["sub"], name=claims["username"])
        l.info(f"jwt parsed. user.id={user.id} user.name={user.name}")
    except Exception as e:
        l.error("failed to parse jwt: ", exc_info=True)
        return {
            "statusCode": 401,
            "body": 'Unauthorized'
        }

    source_ip = event["requestContext"]["identity"]["sourceIp"]
    request_body: dict = json.loads(event["body"])
    prompt_text = request_body["text"]
    composite_prompt = f"User name: {user.name}\n"
    composite_prompt += f"User IP: {source_ip}\n"
    composite_prompt += f"User prompt: {prompt_text}"
    l.info(f"composite_prompt={composite_prompt}")
    
    response_text = agent.prompt(user, composite_prompt)
    l.info(f"response_text={response_text}")
    
    return {
        "statusCode": 200,
        "body": json.dumps({"text": response_text})
    }


if __name__ == "__main__":
    l.info("in __main__, you're probably testing, right?")
    body = json.dumps({
        "text": "Can I rent a mercedes?"
    })
    event = {
        "requestContext": {
            "identity": {
                "sourceIp": "70.200.50.45"
            }
        },
        "headers": {
            "Authorization": f"Bearer {debug_token}"
        },
        "body": body
    }

    l.info('round 1')
    handler_response1 = handler(event, None)
    l.info(f"handler_response1: {handler_response1}")

    # print('round 2')
    # handler_response2 = handler(event, None)
    # l.info(f"handler_response2: {handler_response2}")
