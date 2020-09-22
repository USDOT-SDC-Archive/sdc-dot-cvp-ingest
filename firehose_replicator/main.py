import base64
import boto3

def lambda_handler(event, context):
    output = []

    for record in event['records']:
        print(record['recordId'])
        payload = base64.b64decode(record['data'])

        # TODO: push to ecs
        # s3_client = boto3.client('s3')
        # target_bucket = 'dev-dot-sdc-raw-submissions-505135622787-us-east-1'
        # file_content = b'hello'
        # file_key = 'hello_from_quarantine.txt'
        # # target bucket must allow PUT from source ARN:
        # # arn:aws:lambda:us-east-1:911061262852:function:dev-put-s3-object-into-ecs
        
        # response = s3_client.put_object(
        #     Body=file_content, 
        #     Bucket=target_bucket,
        #     Key=file_key)
        
        # print(f"Uploaded object with ETag {response['ETag']}")

        # TOOD

        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': base64.b64encode(payload)
        }
        output.append(output_record)

    print('Successfully processed {} records.'.format(len(event['records'])))

    return {'records': output}
