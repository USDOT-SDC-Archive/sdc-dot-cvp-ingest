import base64
import boto3
import os
from datetime import datetime
import uuid

def lambda_handler(event, context):
    output = []

    # TODO: split out the ARN part
    stream_name = event['deliveryStreamArn']
    print(f"Context is {context}")
    print(f"Full event is {event}")

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
        ymd_prefix = f"{dt.year}/{dt.month}/{dt.day}/"
        key_name = f"{stream_name}-{dt.year}-{dt.month}-{dt.day}-{dt.hour}-{dt.minute}-{dt.second}-{uuid.uuid1()}.gz"
        full_key = f"{key_prefix}/{ymd_prefix}/{key_name}"

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
        
        # TODO: Figure out how we get the file key?
        # response = s3_client.put_object(
        #     Body=file_content, 
        #     Bucket=target_bucket,
        #     Key=file_key)
        
        # print(f"Uploaded object with ETag {response['ETag']}")

        # TOOD

        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': record['data']
        }
        output.append(output_record)

    print('Successfully processed {} records.'.format(len(event['records'])))

    return {'records': output}
