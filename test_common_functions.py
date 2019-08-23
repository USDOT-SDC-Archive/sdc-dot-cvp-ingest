import os
import boto3
import urllib.parse
from lambdas import utils
from moto import mock_s3
from botocore.validate import ParamValidationError


@mock_s3
class CreateBucketPlaceFile:

    def __init__(self, source_bucket, target_bucket, body="body", key='bsm/file.csv'):
        self.s3 = boto3.client('s3', region_name="us-east-1")
        self.source_key = urllib.parse.unquote_plus(key)

        self.target_key = None
        if os.environ.get('TARGET_DATA_KEY'):
            target_key_part = os.path.join(os.environ['TARGET_DATA_KEY'], key)
            self.target_key = utils.determine_target_key(os.environ['TARGET_DATA_KEY'], target_key_part)

        self.source_bucket = source_bucket
        if self.source_bucket is not None:
            self.s3.create_bucket(Bucket=self.source_bucket)
            self.s3.put_object(Bucket=source_bucket, Body=body, Key=self.source_key)

        self.target_bucket = target_bucket
        if self.target_bucket is not None:
            self.s3.create_bucket(Bucket=self.target_bucket)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, exc_traceback):

        # remove object from source bucket and delete
        if self.source_bucket is not None:
            try:
                self.s3.delete_object(Bucket=self.source_bucket, Key=self.source_key)
            except ParamValidationError:
                pass
            finally:
                self.s3.delete_bucket(Bucket=self.source_bucket)

        # remove object from target bucket and delete
        if self.target_bucket is not None:
            try:
                self.s3.delete_object(Bucket=self.target_bucket, Key=self.target_key)
            except ParamValidationError:
                pass
            finally:
                self.s3.delete_bucket(Bucket=self.target_bucket)