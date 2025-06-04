import boto3
import base64
import json
import os

s3 = boto3.client('s3')
textract = boto3.client('textract')

def lambda_handler(event, context):
    try:
        # If API Gateway passed a string, parse it
        if isinstance(event, str):
            event = json.loads(event)

        # If API Gateway passed through 'body' as a raw string
        if 'body' in event:
            if isinstance(event['body'], str):
                event = json.loads(event['body'])
            else:
                event = event['body']

        filename = event['filename']
        encoded_content = event['filedata']

        decoded_file = base64.b64decode(encoded_content)

        bucket_name = os.environ['BUCKET_NAME']
        s3.put_object(
            Bucket=bucket_name,
            Key=filename,
            Body=decoded_file
        )

        response = textract.detect_document_text(
            Document={'S3Object': {'Bucket': bucket_name, 'Name': filename}}
        )

        # Extract plain text lines from Textract
        lines = []
        for block in response['Blocks']:
            if block['BlockType'] == 'LINE':
                lines.append(block['Text'])

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'File processed successfully',
                'extracted_text': lines
            })
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
