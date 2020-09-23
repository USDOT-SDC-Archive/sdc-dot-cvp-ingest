import base64
import boto3
import os
from datetime import datetime
import uuid

def lambda_handler(event, context):
    output = []

    # TODO: split out the ARN part
    # arn:aws:firehose:us-east-1:911061262852:deliverystream/dev-dot-sdc-cvpep-wydot-alert
    stream_name = event['deliveryStreamArn'].split('/')[1]
    # print(f"Context is {context}")
    # print(f"Full event is {event}")

    for record in event['records']:
        print(f"Processing record {record['recordId']} ...")
        
        file_content = base64.b64decode(record['data'])
        timestamp_ns = record['approximateArrivalTimestamp']
        timestamp_s = timestamp_ns / 1000
        dt = datetime.fromtimestamp(timestamp_s)
        
        # 'deliveryStreamArn': 'arn:aws:firehose:us-east-1:911061262852:deliverystream/dev-dot-sdc-cvpep-wydot-alert'

        # deliveryStreamArn is available as an attribute but should probably use env var
        # e.g. cv/wydot/alert/
        # key_prefix = os.environ.get('KEY_PREFIX')
        key_prefix = 'cv/wydot/alert'
        ymdh_prefix = f"{dt.year:02}/{dt.month:02}/{dt.day:02}/{dt.hour:02}"
        key_name = f"{stream_name}-{dt.year}-{dt.month:02}-{dt.day:02}-{dt.hour:02}-{dt.minute:02}-{dt.second:02}-{uuid.uuid1()}.gz"
        full_key = f"{key_prefix}/{ymdh_prefix}/{key_name}"

        # TODO: push to ecs
        # TODO: get timestamp?

        # normal destination
        # cv/wydot/alert/2020/09/22/21/dev-dot-sdc-cvpep-wydot-alert-8-2020-09-22-21-35-05-36dc0d56-9d8d-4e04-8a3d-4d034dc3fade.gz


        s3_client = boto3.client('s3')
        target_bucket = os.environ.get('ECS_BUCKET_NAME')
        # file_content = payload
        # file_key = 'hello_from_quarantine.txt'
        # target bucket must allow PUT from source ARN:
        # arn:aws:lambda:us-east-1:911061262852:function:dev-put-s3-object-into-ecs
        
        print(f"About to put {full_key} into {target_bucket} with content {file_content}...")
        
        response = s3_client.put_object(
            Body=file_content, 
            Bucket=target_bucket,
            Key=full_key,
            ServerSideEncryption='AES256')
        
        print(f"Uploaded object {full_key} with ETag {response['ETag']}")

        # TODO

        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': record['data']
        }
        output.append(output_record)

    print('Successfully processed {} records.'.format(len(event['records'])))

    return {'records': output}
