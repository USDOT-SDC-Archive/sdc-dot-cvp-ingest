# title           : dataProcessor.py
# description     : AWS Lambda script;
#                   processes manual uploads to manual ingest bucket
# author          : Volpe Center (https://www.volpe.dot.gov/)
# license         : MIT license
# ==============================================================================

from __future__ import print_function

import logging
import boto3
import urllib.parse
import os
import utils

logger = logging.getLogger()
logger.setLevel(logging.INFO)  # necessary to make sure aws is logging
logger.info('Loading function')


def lambda_handler(event, context):
    """AWS Lambda handler. processes manual uploads to manual ingest bucket"""
    s3 = boto3.client('s3')
    s3res = boto3.resource('s3')

    # Get the object from the event and show its content
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(
        event['Records'][0]['s3']['object']['key'])  # .encode('utf8')

    logging.info('source_bucket: {}'.format(source_bucket))
    logging.info('key: {}'.format(key))

    # Get the size of the file from event dictionary
    size = event['Records'][0]['s3']['object']['size']

    try:
        target_bucket = os.environ['TARGET_DATA_BUCKET']
        target_data_key = os.environ['TARGET_DATA_KEY']

        try:
            target_key = os.path.join(target_data_key, key)
        except:
            target_key = None
        copy_source = {'Bucket': source_bucket, 'Key': key}

        # Copy chunk size in bytes:  1073741824 = 1GB
        chunk_size = int(os.environ['COPY_CHUNK_SIZE_BYTES'])

        # Max File Size Supported:  32212254720 = 30GB
        max_file_size_supported = int(os.environ['MAX_SIZE_SUPPORTED_BYTES'])

        # Check to ensure all parameters are valid
        if target_bucket is None:
            logging.error('target_bucket is null')
            return
        if target_key is None:
            logging.error('target_key is null')
            return
        elif target_data_key is None:
            logging.error('target_data_key is null')
            return
        elif s3res.Bucket(target_bucket).creation_date is None:
            logging.error('target bucket doesn\'t exist')
            return
        if s3res.Bucket(source_bucket).creation_date is None:
            logging.error('source bucket doesn\'t exist')
            return
        elif chunk_size <= 0:
            logging.error(
                'COPY_CHUNK_SIZE_BYTES environment variable not set or not greater than 0')
            return
        elif max_file_size_supported <= 0:
            logging.error(
                'MAX_SIZE_SUPPORTED_BYTES environment variable not set or not greater than 0')
            return
        elif size > max_file_size_supported:
            logging.error('file size of {:,d} is greater than max file size supported {:,d}'.format(
                size, max_file_size_supported))
            return
        else:
            logging.info('initial validation of all parameters passed')

        target_key = utils.determine_target_key(target_key)

        logging.info('target_bucket: {}'.format(target_bucket))
        logging.info('target_data_key: {}'.format(target_data_key))
        logging.info('target_key: {}'.format(target_key))
        logging.info('copy_source: {}'.format(copy_source))

        copy_time_start = time.perf_counter()
        # create a multipart upload connection and store the upload id for the connection
        multi_id = (s3.create_multipart_upload(Bucket=target_bucket,
                                               Key=target_key,
                                               ServerSideEncryption='AES256'))['UploadId']

        current_size = size
        logging.info('Copy File Size: {}'.format(size))
        logging.info('Chunk size: {}'.format(chunk_size))
        parts = []

        # loop through the file chunk_size at a time until the file has no more bytes left
        i = 1
        while current_size > 0:
            # set the next range of bytes to grab based on what is left
            if(current_size < chunk_size):
                bytes_to_copy = current_size
                csr = 'bytes=' + str(size - current_size) + '-' + str(size - 1)
                current_size = 0
            elif(current_size >= chunk_size):
                bytes_to_copy = chunk_size
                csr = 'bytes=' + str(size - current_size) + \
                    '-' + str(size - current_size + chunk_size - 1)
                current_size -= chunk_size
            logging.info(
                'Requesting upload_part_copy for byte range: {} of the total: {}'.format(csr, size))

            copy_part_start = time.perf_counter()

            # send the range of bytes from the file to AWS
            response = s3.upload_part_copy(CopySourceRange=csr,
                                           CopySource=copy_source,
                                           Bucket=target_bucket,
                                           Key=target_key,
                                           UploadId=multi_id,
                                           PartNumber=i)

            copy_part_stop = time.perf_counter()
            copy_part_time = copy_part_stop - copy_part_start
            logging.info('...Copied {:d} bytes in {:0.4f} seconds (GB per min = {:0.4f})'.format(
                bytes_to_copy, copy_part_time, ((60 / copy_part_time) * (bytes_to_copy / (1024 * 1024 * 1024)))))

            e_tag = (response['CopyPartResult'])['ETag']
            parts.append({'ETag': e_tag, 'PartNumber': i})
            i += 1

        copy_time_end = time.perf_counter()
        copy_time = copy_time_end - copy_time_start
        # create multipart upload parts dictionary
        logging.info(
            'all file chunks copied - requesting complete_multipart_upload')
        mpu = {'Parts': parts}

        # complete the multipart upload connection
        response = s3.complete_multipart_upload(Bucket=target_bucket,
                                                Key=target_key,
                                                MultipartUpload=mpu,
                                                UploadId=multi_id)

        # if the response was received, meaning the upload was successful, delete the source file
        if response is not None:
            logging.info(
                'complete_multipart_upload returned - requesting delete of source file')
            logging.info('...Copied total of {:d} bytes in {:0.4f} seconds (GB per min = {:0.4f})'.format(
                size, copy_time, ((60 / copy_time) * (size / (1024 * 1024 * 1024)))))
            response = s3.delete_object(Bucket=source_bucket, Key=key)
            logging.info('source file deleted')

        logging.info('Succeeded')

    except Exception as e:
        logging.error(e)
        logging.error("Received error: {0}".format(e), exc_info=True)
        logging.error('Exception copying and or deleting object {} from bucket {}.'.format(
            key, source_bucket))
        raise e
