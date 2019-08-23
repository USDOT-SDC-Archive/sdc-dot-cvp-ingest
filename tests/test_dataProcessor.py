import os
import pytest
from unittest.mock import patch, MagicMock
from lambdas import dataProcessor
from moto import mock_s3
from test_common_functions import CreateBucketPlaceFile
from botocore.exceptions import ClientError, ParamValidationError

# global variables
target_key = 'cv/thea/'
source_key = 'bsm/file.csv'

event_data = {
  "Records":
  [
    {
      "s3": {
        "bucket": {
          "name": "test"
        },
        "object": {
          "key": source_key,
          "size": 3
        }
      }
    }
  ]
}

# declare environment variables
os.environ['TARGET_DATA_BUCKET'] = 'random_target_bucket'
os.environ['TARGET_DATA_KEY'] = target_key


@mock_s3
def test_lambda_handler():
    with CreateBucketPlaceFile("test", os.environ['TARGET_DATA_BUCKET']):
        dataProcessor.lambda_handler(event_data, '')


@mock_s3
def test_lambda_handler_current_size_greater_chunk_size():
    event_data_2 = event_data.copy()
    event_data_2["Records"][0]["s3"]["object"]["size"] = 100000001
    with CreateBucketPlaceFile("test", os.environ['TARGET_DATA_BUCKET']):
        with pytest.raises(ClientError):
            dataProcessor.lambda_handler(event_data_2, '')


@mock_s3
def test_lambda_handler_current_size_equal_chunk_size():
    event_data_2 = event_data.copy()
    event_data_2["Records"][0]["s3"]["object"]["size"] = 100000000
    with CreateBucketPlaceFile("test", os.environ['TARGET_DATA_BUCKET']):
        with pytest.raises(ParamValidationError):
            dataProcessor.lambda_handler(event_data_2, '')


@mock_s3
def test_lambda_handler_source_bucket_none():
    with CreateBucketPlaceFile(None, os.environ['TARGET_DATA_BUCKET'], key=target_key):
        dataProcessor.lambda_handler(event_data, '')


@mock_s3
def test_lambda_handler_target_bucket_none():
    with CreateBucketPlaceFile("test", None, key=target_key):
        dataProcessor.lambda_handler(event_data, '')


@mock_s3
def test_lambda_handler_no_target_data_key():
    del os.environ['TARGET_DATA_KEY']
    try:
        with CreateBucketPlaceFile("test", os.environ['TARGET_DATA_BUCKET']):
            dataProcessor.lambda_handler(event_data, '')
    finally:
        os.environ['TARGET_DATA_KEY'] = target_key
