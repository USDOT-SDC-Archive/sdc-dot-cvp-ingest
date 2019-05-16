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
    s3res = boto3.resource('s3')

    # define the size of each data chunk, currently at 100MB
    size = event['Records'][0]['s3']['object']['size']
    
    # Get the object from the event and show its content
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])  # .encode('utf8')
    #LoggerUtility.logInfo(event)
    #LoggerUtility.logInfo("Atri")
    logging.info('source_bucket: {}'.format(source_bucket))
    logging.info('key: {}'.format(key))

    try:
        target_bucket = os.environ['TARGET_DATA_BUCKET']
        target_data_key = os.environ['TARGET_DATA_KEY']
        target_key = os.path.join(target_data_key, key)
        copy_source = {'Bucket': source_bucket, 'Key': key}
        
        if (s3res.Bucket(target_bucket).creation_date is None):
            logging.error('target bucket doesn\'t exist')
            return
        if (s3res.Bucket(source_bucket).creation_date is None):
            logging.error('source bucket doesn\'t exist')
            return
        if (target_bucket is None):
            logging.error('target_bucket is null')
            return
        if (target_data_key is None):
            logging.error('target_data_key is null')
            return
        if (target_key is None):
            logging.error('target_key is null')
            return
        if (copy_source is None):
            logging.error('copy_source is null')
            return
        
        target_key = utils.determine_target_key(target_data_key, target_key)
        
        logging.info('target_bucket: {}'.format(target_bucket))
        logging.info('target_data_key: {}'.format(target_data_key))
        logging.info('target_key: {}'.format(target_key))
        logging.info('copy_source: {}'.format(copy_source))
        
        # create a multipart upload connection and store the upload id for the connection
        multiId = (s3.create_multipart_upload(Bucket=target_bucket, Key=target_key, ServerSideEncryption='AES256'))['UploadId']
        
        currentSize = size
        logging.info('Copy File Size: {}'.format(size))
        chunkSize = 100000000 # 100MB
        logging.info('Chunk size: {}'.format(chunkSize))
        parts = []
        
        # loop through the file chunkSize at a time until the file has no more bytes left
        i = 1
        while currentSize > 0:
            # set the next range of bytes to grab based on what is left
            if(currentSize < chunkSize):
                csr = 'bytes=' + str(size - currentSize) + '-' + str(size - 1)
                currentSize = 0
            elif(currentSize > chunkSize):
                csr = 'bytes=' + str(size - currentSize) + '-' + str(size - currentSize + chunkSize - 1)
                currentSize -= chunkSize
            logging.info('Current Byte Range: {} of the total: {}'.format(csr, size))
            
            # send the range of bytes from the file to AWS
            response = s3.upload_part_copy(CopySourceRange=csr, CopySource=copy_source, Bucket=target_bucket, Key=target_key, UploadId=multiId, PartNumber=i)
            eTag = (response['CopyPartResult'])['ETag']
            parts.append({'ETag': eTag, 'PartNumber': i})
            i+= 1
        
        # create multipart upload parts dictionary
        mpu = {'Parts': parts}
        
        # complete the multipart upload connection
        response = s3.complete_multipart_upload(Bucket=target_bucket, Key=target_key, MultipartUpload=mpu, UploadId=multiId)
        
        # if the response was received, meaning the upload was successful, delete the source file
        if response is not None:
            response = s3.delete_object(Bucket=source_bucket, Key=key)
        
        logging.info('Succeeded')
    except Exception as e:
        logging.error(e)
        logging.error("Received error: {0}".format(e), exc_info=True)
        logging.error('Exception copying and or deleting object {} from bucket {}.'.format(key, source_bucket))
        raise e