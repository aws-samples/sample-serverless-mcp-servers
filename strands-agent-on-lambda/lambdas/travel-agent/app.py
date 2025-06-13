import logger
import agent
import json
import jwt
import os
from user import User
l = logger.get()

debug_token = "eyJraWQiOiJiQ3IxdTdPSmhGUk1uQzNPanJPQ3J4aEFqWjFhbXU1UllTeUJQZlVKWExJPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI3NDc4MzQ1OC1hMGQxLTcwOGQtMTRhYS1iYWJjYTViMzY5MGUiLCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV96ZmJtZjRPNWsiLCJ2ZXJzaW9uIjoyLCJjbGllbnRfaWQiOiIzODVwOGJidGgwY3Bxbjc0YmEwaWVmajllZyIsIm9yaWdpbl9qdGkiOiIwNTcwNWFkMS00ODg5LTQ0YjAtOGRhMC01YTc5NmQ3YjQxOGQiLCJldmVudF9pZCI6IjczYjVkMjI5LTM4N2EtNDk2Yy1hNzBkLWMzOTg3M2Y2N2IyNSIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJhdXRoX3RpbWUiOjE3NDk4NDAwMTYsImV4cCI6MTc0OTg0MzYxNiwiaWF0IjoxNzQ5ODQwMDE2LCJqdGkiOiIyNGI2NWU2Ny0xY2NhLTQ3MzctYTBjYy01NzUzMjJjY2E2NjMiLCJ1c2VybmFtZSI6IkFsaWNlIn0.D6EvqsHSjy1QCMVEbsjNPgMz1yu3J696kFGGKdRmPdKDi09Hu56jXpaNxWyipzJ5KPOI4ppu-zS_zje54cmjiHh6riix75hJPZvqqeBvAfKFY6JyXz2XYGCc6PXDgGIqJxE8yOHPcCpcyhoaW-D9t7AxNFbqSIvKslICU2jxLHZLO4GU2ATZgrhGUGwcImx64ufA0fVgVubbfLcJndznMnbgng5VeFM5oDzd0c5bHdJJss6_ffVPbfLZSSqjvpuebzZQniD5RxEvhzQMtcqBwYM9oGC6oJTALSsyHip5M1ePeSY3RjC8H_JoDUzeFUD1aGSIsrmejy6UGlwbUOQQgw"

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
