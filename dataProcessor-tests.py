import pytest
import dataProcessor
import json
import logging
import sys
import boto3
import os
from moto import mock_s3

class TestLambdaHandler(object):
    def setup(self):
        json_small_event_data = """{
          "Records":
          [
            {
              "s3": {
                "bucket": {
                  "name": "test"
                },
                "object": {
                  "key": "bsm/file.csv",
                  "size": 9001
                }
              }
            }
          ]
        }""".encode('utf-8')
        self.small_event_data = json.loads(json_small_event_data)
        
        json_large_event_data = """{
          "Records":
          [
            {
              "s3": {
                "bucket": {
                  "name": "test"
                },
                "object": {
                  "key": "bsm/file.csv",
                  "size": 110000000
                }
              }
            }
          ]
        }""".encode('utf-8')
        self.large_event_data = json.loads(json_large_event_data)

        json_wrong_event_data = """{
          "Records":
          [
            {
            }
          ]
        }""".encode('utf-8')
        self.wrong_event_data = json.loads(json_wrong_event_data)

    @mock_s3
    def test_lambda_handler_no_environ_variable(self):
        source_bucket = 'test'
        target_bucket = 'random_target_bucket'
        target_key = 'cv/thea/'
        key = 'bsm/file.csv'
        bodyfile = 'ola'

        self.error_template(source_bucket, target_bucket, target_key, key, bodyfile, self.small_event_data, False, True)

    @mock_s3
    def test_lambda_handler_wydot(self):
        source_bucket = 'test'
        target_bucket = 'random_target_bucket'
        target_key = 'cv/wydot/'
        key = 'bsm/file.csv'
        bodyfile = 'ola'
        
        self.basic_template(source_bucket, target_bucket, target_key, key, bodyfile, self.small_event_data)
        
    @mock_s3
    def test_lambda_handler_thea(self):
        source_bucket = 'test'
        target_bucket = 'random_target_bucket'
        target_key = 'cv/thea/'
        key = 'bsm/file.csv'
        bodyfile = 'ola'

        self.basic_template(source_bucket, target_bucket, target_key, key, bodyfile, self.small_event_data)
    
    @mock_s3
    def test_lambda_handler_with_wrong_event_data(self):
        conn = boto3.resource('s3')
        conn.create_bucket(Bucket='asd')

        pytest.raises(KeyError)

    @mock_s3
    def test_lambda_handler_raise_exception(self):
        source_bucket = 'test'
        target_bucket = 'random_target_bucket'
        target_key = 'cv/thea/'
        key = 'bsm/file.csv'
        bodyfile = 'ola'

        self.error_template(source_bucket, target_bucket, target_key, key, bodyfile, self.large_event_data, True, True)

    @mock_s3
    def test_lambda_handler_thea(self):
        source_bucket = 'test'
        target_bucket = 'wrong name'
        target_key = 'cv/thea/'
        key = 'bsm/file.csv'
        bodyfile = 'ola'

        self.error_template(source_bucket, target_bucket, target_key, key, bodyfile, self.small_event_data, True, False)

    @mock_s3
    def test_lambda_handler_large_file(self):
        source_bucket = 'test'
        target_bucket = 'random_target_bucket'
        target_key = 'cv/thea/'
        key = 'bsm/file.csv'
        
        f = open("110mbfile.txt", "w")
        f.close()
        os.truncate("110mbfile.txt", 110000000)

        f = open("110mbfile.txt", "rb")

        self.basic_template(source_bucket, target_bucket, target_key, key, f, self.large_event_data)
        f.close()

    @mock_s3
    def basic_template(self, source_bucket, target_bucket, target_key, key, bodyfile, self_event_data):
        os.environ['TARGET_DATA_BUCKET'] = target_bucket
        os.environ['TARGET_DATA_KEY'] = target_key

        conn = boto3.resource('s3')
        conn.create_bucket(Bucket=source_bucket)
        conn.create_bucket(Bucket=target_bucket)

        # Arrange
        # create object
        bucket = conn.Bucket(source_bucket)
        bucket.put_object(Body=bodyfile, Key=key)

        bucket = conn.Bucket(target_bucket)
        count = len(list(bucket.objects.all()))
        assert count == 0, "Should be empty"

        # Act
        dataProcessor.lambda_handler(self_event_data, '')

        # Assert
        bucket = conn.Bucket(target_bucket)
        count = 0
        for obj in bucket.objects.all():
            print(obj)
            assert obj.key.startswith(target_key), "wrong destination folder"
            assert obj.key.endswith(os.path.basename(key)), "invalid filename"
            count += 1

        assert count == 1, "Should have new file"

        bucket = conn.Bucket(source_bucket)
        count = len(list(bucket.objects.all()))
        assert count == 0, "Should be empty"

    @mock_s3
    def error_template(self, source_bucket, target_bucket, target_key, key, bodyfile, self_event_data, define_target_bucket, correct_bucket):
        if define_target_bucket:
            os.environ['TARGET_DATA_KEY'] = target_key
            os.environ['TARGET_DATA_BUCKET'] = target_bucket
        if not correct_bucket:
            target_bucket = 'purposefullyincorrectbucketname'
        conn = boto3.resource('s3')
        conn.create_bucket(Bucket=source_bucket)
        conn.create_bucket(Bucket=target_bucket)

        # Arrange
        # create object
        bucket = conn.Bucket(source_bucket)
        bucket.put_object(Body=bodyfile, Key=key)

        bucket = conn.Bucket(target_bucket)
        count = len(list(bucket.objects.all()))
        assert count == 0, "Should be empty"

        # Act
        try:
            dataProcessor.lambda_handler(self_event_data, '')
        except Exception as e:
            assert e is not None