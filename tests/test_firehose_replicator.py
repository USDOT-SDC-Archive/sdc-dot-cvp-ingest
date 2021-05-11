import os
import pytest
import boto3
import base64
from moto import mock_s3
from firehose_replicator import firehose_replicator

ECS_BUCKET_NAME = "the-ecs-bucket"
ECS_OBJECT_PREFIX = "cv/oss4its"
os.environ["ECS_BUCKET_NAME"] = ECS_BUCKET_NAME
os.environ["ECS_OBJECT_PREFIX"] = ECS_OBJECT_PREFIX


@mock_s3
def test_lambda_handler():
    # create pre-req bucket
    s3_client = boto3.client('s3')
    bucket_name = ECS_BUCKET_NAME
    bucket = s3_client.create_bucket(Bucket=bucket_name)

    context = {}
    # To avoid confusion, we'll take a raw string and base-64 encode it
    # This is not to be confused with the bytes/string encode/decode
    raw_data = '{"ticker_symbol":"QXZ", "sector":"HEALTHCARE", "change":-0.05, "price":84.51}'
    encoded_data = base64.b64encode(bytes(raw_data, 'utf-8'))
    event = {
        'deliveryStreamArn': 'arn:aws:firehose:us-east-1:1234:deliverystream/the-wydot-alert',
        'records': [
            {
                'recordId': '49611067473050108458553460260926887448688655020649873410000000',
                'data': encoded_data.decode('utf-8'),
                'approximateArrivalTimestamp': 1600890092089
            }
        ]
    }

    firehose_replicator.lambda_handler(event, context)

