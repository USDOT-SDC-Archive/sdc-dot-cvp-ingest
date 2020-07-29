import os

import pytest
from botocore.exceptions import ClientError, ParamValidationError
import data_processor
from moto import mock_s3
import json
import boto3
from datetime import datetime

TARGET_KEY = 'cv/thea/'
SOURCE_KEY = 'bsm/file.csv'
BUCKET_NAME = 'test'
DESTINATION_BUCKET_NAME = 'random_target_bucket'
event_data = {
    "Records":
        [
            {
                "s3": {
                    "bucket": {
                        "name": BUCKET_NAME
                    },
                    "object": {
                        "key": SOURCE_KEY,
                        "size": 3
                    }
                }
            }
        ]
}

s3 = boto3.client('s3', region_name="us-east-1")

@pytest.fixture(autouse=True)
def run_around_tests(mocker):
    mocks3 = mock_s3()
    mocks3.start()
    os.environ['TARGET_DATA_BUCKET'] = 'random_target_bucket'
    os.environ['BUCKET_PATH_MAPPING'] = json.dumps({BUCKET_NAME: TARGET_KEY})
    s3.create_bucket(Bucket=BUCKET_NAME)
    s3.put_object(Bucket=BUCKET_NAME, Body='body', Key=SOURCE_KEY)
    s3.create_bucket(Bucket=DESTINATION_BUCKET_NAME)

    yield

    del os.environ['TARGET_DATA_BUCKET']
    del os.environ['BUCKET_PATH_MAPPING']
    mocks3.stop()


def test_lambda_handler_uploads_file_to_destination_bucket():
    data_processor.lambda_handler(event_data, None)
    
    now = datetime.now()
    s3.head_object(Bucket=DESTINATION_BUCKET_NAME, Key=f'{TARGET_KEY}{now.strftime("%Y")}/{now.strftime("%m")}/{now.strftime("%d")}/{SOURCE_KEY}')


def test_create_upload_chunks_divides_files_evenly():
    test_cases = [{'file_size': 10, 'chunk_size': 3, 'expected': ['bytes=0-2', 'bytes=3-5', 'bytes=6-8', 'bytes=9-9']},
                  {'file_size': 10, 'chunk_size': 10, 'expected': ['bytes=0-9']},
                  {'file_size': 7, 'chunk_size': 10, 'expected': ['bytes=0-6'] }]

    for test_case in test_cases:
        result = data_processor.create_upload_chunks(test_case['file_size'], test_case['chunk_size'])

        assert test_case['expected'] == result