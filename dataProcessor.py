# title           : dataProcessor.py
# description     : AWS Lambda script;
#                   processes manual uploads to manual ingest bucket
# author          : Volpe Center (https://www.volpe.dot.gov/)
# license         : MIT license
# ==============================================================================

from __future__ import print_function

import logging
import boto3
import urllib
import os
import utils

logger = logging.getLogger()
logger.setLevel(logging.INFO)  # necessary to make sure aws is logging
logger.info('Loading function')


def lambda_handler(event, context):
    """AWS Lambda handler. processes manual uploads to manual ingest bucket"""
    s3 = boto3.client('s3')

    # Get the object from the event and show its content
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])  # .encode('utf8'))

    logging.info('source_bucket: {}'.format(source_bucket))
    logging.info('key: {}'.format(key))

    try:
        target_bucket = os.environ['TARGET_DATA_BUCKET']
        target_data_key = os.environ['TARGET_DATA_KEY']
        target_key = os.path.join(target_data_key, key)
        copy_source = {'Bucket': source_bucket, 'Key': key}

        target_key = utils.determine_target_key(target_data_key, target_key)

        logging.info('target_bucket: {}'.format(target_bucket))
        logging.info('target_data_key: {}'.format(target_data_key))
        logging.info('target_key: {}'.format(target_key))
        logging.info('copy_source: {}'.format(copy_source))

        response = s3.copy_object(
            Bucket=target_bucket,
            Key=target_key,
            CopySource=copy_source,
            ServerSideEncryption='AES256')

        logging.debug('Copied {} to {}/{}, response: {}'.format(copy_source, target_bucket, target_key, response['ResponseMetadata']))

        if response.get('CopyObjectResult', False):
            response = s3.delete_object(
                Bucket=source_bucket,
                Key=key
            )

        logging.debug('Deleted {}/{}, response: {}'.format(source_bucket, key, response['ResponseMetadata']))

    except Exception as e:
        logging.error(e)
        logging.error("Received error: {0}".format(e), exc_info=True)
        logging.error('Exception copying and or deleting object {} from bucket {}.'.format(key, source_bucket))
        raise e

