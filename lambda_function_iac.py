import json
import boto3

# Initialize the DynamoDB resource
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('cloud-resume-stats-iac')

def lambda_handler(event, context):
    # Instead of reading the count, adding 1 in Python, and then writing it back to the database, I used DynamoDB's native ADD expression
    # If 1,000 people visit my site at the exact same moment, DynamoDB handles the math internally.
    #  A 'read-then-write' approach would result in lost counts due to race conditions
    # an atomic update ensures every single visit is recorded accurately
    response = table.update_item(
        Key={'id': 'visitors'},
        UpdateExpression='ADD #count :inc', # Atomic increment of the 'count' attribute for the 'visitors' item
        ExpressionAttributeNames={'#count': 'count'},
        ExpressionAttributeValues={':inc': 1},
        ReturnValues='UPDATED_NEW'
    )
    
    # Extract the new count
    new_count = response['Attributes']['count']

    # Return the response with CORS headers so your website can read it
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': 'https://thedonaldtong.com',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'GET,OPTIONS'
        },
        'body': json.dumps({'count': int(new_count)})
    }