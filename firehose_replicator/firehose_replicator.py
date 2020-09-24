import base64
import boto3
import json
import os
from datetime import datetime
import uuid
import gzip

def lambda_handler(event, context):
    output = []
    records_for_s3 = []
    stream_name = event['deliveryStreamArn'].split('/')[1]
    target_bucket = os.environ.get('ECS_BUCKET_NAME')
    key_prefix = os.environ.get('ECS_OBJECT_PREFIX')
    full_key = "replicator_empty_key"

    # TODO: Get timestamp (key) from last record
    # TODO: Bundle all records in single object akin to firehose
    for record in event['records']:
        print(f"Processing record {record['recordId']} ...")
        file_content = base64.b64decode(record['data']).decode('utf-8')
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
        records_for_s3.append(file_content)

    s3_client = boto3.client('s3')
    print(f"About push {full_key} into {target_bucket}...")
    
    # concatenate stuff
    s3_output = ''.join(records_for_s3)

    # TODO: verify gzip
    print(f"Sending payload {s3_output}")
    firehose_body = bytes(s3_output, 'utf-8')
    gzipped_body = gzip.compress(firehose_body)
    response = s3_client.put_object(
        Body=firehose_body, 
        Bucket=target_bucket,
        Key=full_key,
        ServerSideEncryption='AES256',
        ACL='bucket-owner-full-control')
    
    print(f"Uploaded {full_key} with ETag {response['ETag']}")
    print('Successfully processed {} records.'.format(len(event['records'])))

    return {'records': output}
