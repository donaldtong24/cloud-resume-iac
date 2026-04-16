import json
import boto3

# Initialize the DynamoDB resource
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('cloud-resume-stats-iac')

def lambda_handler(event, context):
    # Atomic increment of the 'count' attribute for the 'visitors' item
    response = table.update_item(
        Key={'id': 'visitors'},
        UpdateExpression='ADD #count :inc',
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
            'Access-Control-Allow-Origin': '*', # Adjust this later for better security!
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'GET,OPTIONS'
        },
        'body': json.dumps({'count': int(new_count)})
    }