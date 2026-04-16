import json
import boto3
# Paste this into your lambda function in AWS Lambda. Make sure to set up the appropriate IAM role with permissions to access DynamoDB and to create an API Gateway trigger for this function.
# This Lambda function updates a visitor count in a DynamoDB table and returns the updated count.

# Initialize the DynamoDB resource
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('cloud-resume-stats')

def lambda_handler(event, context):
    # 1. Update the item in DynamoDB
    response = table.update_item(
        Key={'id': 'visitors'},
        UpdateExpression='ADD #c :val',
        ExpressionAttributeNames={'#c': 'count'},
        ExpressionAttributeValues={':val': 1},
        ReturnValues='UPDATED_NEW'
    )
    
    # 2. Extract the new count
    new_count = str(response['Attributes']['count'])
    
    # 3. Return the count with CORS headers (Critical for websites!)
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET'
        },
        'body': new_count
    }