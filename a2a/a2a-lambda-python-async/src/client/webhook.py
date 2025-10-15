import json

def lambda_handler(event, context):
    print('Webhook invoked')
    print(json.dumps(event, indent=2))
    
    return {
        'statusCode': 200,
        'body': json.dumps('Event payload printed to logs')
    }
