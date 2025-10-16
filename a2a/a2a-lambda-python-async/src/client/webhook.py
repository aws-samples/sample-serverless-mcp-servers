import json

def lambda_handler(event, context):
    print('Webhook invoked')
    result = json.dumps(event['body'], indent=2)

    print(result)
    
    return {
        'statusCode': 200,
        'body': result
    }
