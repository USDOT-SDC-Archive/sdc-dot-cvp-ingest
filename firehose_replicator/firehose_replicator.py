import base64
import boto3
import json
import os
from datetime import datetime
import uuid

def lambda_handler(event, context):
    output = []
    s3_output = []
    stream_name = event['deliveryStreamArn'].split('/')[1]
    target_bucket = os.environ.get('ECS_BUCKET_NAME')
    key_prefix = os.environ.get('ECS_OBJECT_PREFIX')
    full_key = "replicator_empty_key"

    # TODO: Get timestamp (key) from last record
    # TODO: Bundle all records in single object akin to firehose
    for record in event['records']:
        print(f"Processing record {record['recordId']} ...")
        file_content = base64.b64decode(record['data'])
        timestamp_ns = record['approximateArrivalTimestamp']
        timestamp_s = timestamp_ns / 1000
        dt = datetime.fromtimestamp(timestamp_s)
        ymdh_prefix = f"{dt.year:02}/{dt.month:02}/{dt.day:02}/{dt.hour:02}"
        key_name = f"{stream_name}-{dt.year}-{dt.month:02}-{dt.day:02}-{dt.hour:02}-{dt.minute:02}-{dt.second:02}-{uuid.uuid1()}.gz"
        full_key = f"{key_prefix}/{ymdh_prefix}/{key_name}"

        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': record['data']
        }
        output.append(output_record)
        s3_output.append(record['data'])

    s3_client = boto3.client('s3')
    print(f"About push {full_key} into {target_bucket}...")
    
    response = s3_client.put_object(
        Body=bytes(json.dumps(s3_output)), 
        Bucket=target_bucket,
        Key=full_key,
        ServerSideEncryption='AES256')
    
    print(f"Uploaded {full_key} with ETag {response['ETag']}")
    print('Successfully processed {} records.'.format(len(event['records'])))

    return {'records': output}
