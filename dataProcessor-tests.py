import unittest
import dataProcessor
import json
import logging
import sys
import boto3
import os
from moto import mock_s3

class TestLambdaHandler(unittest.TestCase):
    def setUp(self):
        json_event_data = """{
          "Records":
          [
            {
              "s3": {
                "bucket": {
                  "name": "test"
                },
                "object": {
                  "key": "bsm/file.csv"
                }
              }
            }
          ]
        }""".encode('utf-8')
        self.event_data = json.loads(json_event_data)

        json_wrong_event_data = """{
          "Records":
          [
            {
            }
          ]
        }""".encode('utf-8')
        self.wrong_event_data = json.loads(json_wrong_event_data)

    @mock_s3
    def test_lambda_handler_wydot(self):
        source_bucket = 'test'
        target_bucket = 'random_target_bucket'
        target_key = 'cv/wydot/'
        key = 'bsm/file.csv'

        self.basic_template(source_bucket, target_bucket, target_key, key)

    @mock_s3
    def test_lambda_handler_thea(self):
        source_bucket = 'test'
        target_bucket = 'random_target_bucket'
        target_key = 'cv/thea/'
        key = 'bsm/file.csv'

        self.basic_template(source_bucket, target_bucket, target_key, key)

    def basic_template(self, source_bucket, target_bucket, target_key, key):
        os.environ['TARGET_DATA_BUCKET'] = target_bucket
        os.environ['TARGET_DATA_KEY'] = target_key

        conn = boto3.resource('s3')
        conn.create_bucket(Bucket=source_bucket)
        conn.create_bucket(Bucket=target_bucket)

        # Arrange
        # create object
        bucket = conn.Bucket(source_bucket)
        bucket.put_object(Body='ola', Key=key)

        bucket = conn.Bucket(target_bucket)
        count = 0
        for obj in bucket.objects.all():
            print(obj)
            count += 1

        self.assertTrue(count == 0, "Should be empty")

        # Act
        dataProcessor.lambda_handler(self.event_data, '')

        # Assert
        bucket = conn.Bucket(target_bucket)
        count = 0
        for obj in bucket.objects.all():
            print(obj)
            self.assertTrue(obj.key.startswith(target_key), "wrong destination folder")
            self.assertTrue(obj.key.endswith(os.path.basename(key)), "invalid filename")
            count += 1

        self.assertTrue(count == 1, "Should have new file")


    @mock_s3
    def test_lambda_handler_with_wrong_event_data(self):
        conn = boto3.resource('s3')
        conn.create_bucket(Bucket='asd')

        self.assertRaises(KeyError, dataProcessor.lambda_handler, self.wrong_event_data, '')


if __name__ == '__main__':
    unittest.main()
