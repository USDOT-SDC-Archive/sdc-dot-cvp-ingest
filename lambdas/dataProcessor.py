# title           : dataProcessor.py
# description     : AWS Lambda script;
#                   processes manual uploads to manual ingest bucket
# author          : Volpe Center (https://www.volpe.dot.gov/)
# license         : MIT license
# ==============================================================================

from __future__ import print_function

import logging
import os
import urllib.parse

import boto3
from lambdas import utils

logger = logging.getLogger()
logger.setLevel(logging.INFO)  # necessary to make sure aws is logging
logger.info('Loading function')


def lambda_handler(event, *args, **kwargs):
    """AWS Lambda handler. processes manual uploads to manual ingest bucket"""
    s3 = boto3.client('s3')
    s3res = boto3.resource('s3')

    # Get the object from the event and show its content
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])

    logging.info('source_bucket: {}'.format(source_bucket))
    logging.info('key: {}'.format(key))

    try:
        target_bucket = os.environ['TARGET_DATA_BUCKET']
        target_data_key = os.environ.get('TARGET_DATA_KEY')
        try:
            target_key = os.path.join(target_data_key, key)
        except:
            target_key = None
        copy_source = {'Bucket': source_bucket, 'Key': key}

        # verify that everything exists
        if s3res.Bucket(target_bucket).creation_date is None:
            logging.error('target bucket doesn\'t exist')
            return
        if s3res.Bucket(source_bucket).creation_date is None:
            logging.error('source bucket doesn\'t exist')
            return
        if target_bucket is None:
            logging.error('target_bucket is null')
            return
        if target_data_key is None:
            logging.error('target_data_key is null')
            return
        if target_key is None:
            logging.error('target_key is null')
            return
        if copy_source is None:
            logging.error('copy_source is null')
            return

        target_key = utils.determine_target_key(target_key)

        logging.info('target_bucket: {}'.format(target_bucket))
        logging.info('target_data_key: {}'.format(target_data_key))
        logging.info('target_key: {}'.format(target_key))
        logging.info('copy_source: {}'.format(copy_source))

        # create a multipart upload connection and store the upload id for the connection
        multi_id = (s3.create_multipart_upload(Bucket=target_bucket, Key=target_key, ServerSideEncryption='AES256'))[
            'UploadId']

        # define the size of each data chunk, currently at 100MB
        size = event['Records'][0]['s3']['object']['size']
        current_size = size
        logging.info('Copy File Size: {}'.format(size))
        chunk_size = 100000000  # 100MB
        logging.info('Chunk size: {}'.format(chunk_size))
        parts = []

        # loop through the file chunk_size at a time until the file has no more bytes left
        i = 1
        while current_size > 0:
            csr = None
            # set the next range of bytes to grab based on what is left
            if current_size < chunk_size:
                csr = 'bytes=' + str(size - current_size) + '-' + str(size - 1)
                current_size = 0
            elif current_size > chunk_size:
                csr = 'bytes=' + str(size - current_size) + '-' + str(size - current_size + chunk_size - 1)
                current_size -= chunk_size
            logging.info('Current Byte Range: {} of the total: {}'.format(csr, size))

            # send the range of bytes from the file to AWS
            response = s3.upload_part_copy(CopySourceRange=csr, CopySource=copy_source, Bucket=target_bucket,
                                           Key=target_key, UploadId=multi_id, PartNumber=i)
            e_tag = response['CopyPartResult']['ETag']
            parts.append({'ETag': e_tag, 'PartNumber': i})
            i += 1

        # create multipart upload parts dictionary
        mpu = {'Parts': parts}

        # complete the multipart upload connection
        response = s3.complete_multipart_upload(Bucket=target_bucket, Key=target_key, MultipartUpload=mpu,
                                                UploadId=multi_id)

        # if the response was received, meaning the upload was successful, delete the source file
        if response is not None:
            s3.delete_object(Bucket=source_bucket, Key=key)

        logging.info('Succeeded')

    except Exception as e:
        logging.error(e)
        logging.error("Received error: {0}".format(e), exc_info=True)
        logging.error('Exception copying and or deleting object {} from bucket {}.'.format(key, source_bucket))
        raise e
