# title           : data_processor.py
# description     : AWS Lambda script;
#                   processes manual uploads to manual ingest bucket
# author          : Volpe Center (https://www.volpe.dot.gov/)
# license         : MIT license
# ==============================================================================
#

from __future__ import print_function

import logging
import boto3
import urllib
import os
import time
import json
from datetime import datetime

CHUNK_SIZE = 1073741824 # 1 GB

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    raw_source_key = event['Records'][0]['s3']['object']['key']
    logging.info(f'raw_source_key: {raw_source_key}')
    source_key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])
    logging.info(f'source_bucket: {source_bucket}')
    logging.info(f'source_key: {source_key}')

    file_size = event['Records'][0]['s3']['object']['size']

    target_bucket = os.environ['TARGET_DATA_BUCKET']
    mirror_bucket = os.environ['MIRROR_DATA_BUCKET']
    target_data_folder_path = bucket_destination_mapping()[source_bucket]
    mirror_data_folder_path = mirror_destination_mapping()[mirror_bucket]
    source_key_path = os.path.dirname(source_key)
    source_key_filename = os.path.basename(source_key)
    now = datetime.now()
    target_key = os.path.join(target_data_folder_path, source_key_path, now.strftime('%Y'), now.strftime('%m'), now.strftime('%d'), source_key_filename)
    mirror_key = os.path.join(mirror_data_folder_path, source_key_path, now.strftime('%Y'), now.strftime('%m'), now.strftime('%d'), source_key_filename)

    logging.info(f'target_bucket: {target_bucket}')
    logging.info(f'target_key: {target_key}')
    logging.info(f'mirror_bucket: {mirror_bucket}')
    logging.info(f'mirror_key: {target_key}')

    chunk_ranges = create_upload_chunks(file_size)
    logging.info(f'file_size: {file_size}')
    logging.info(f'uploading file in chunks: {chunk_ranges}')

    upload_file(chunk_ranges, source_bucket, source_key, target_bucket, target_key, mirror_bucket, mirror_key)


def upload_file(chunk_ranges, source_bucket, source_key, target_bucket, target_key, mirror_bucket, mirror_key):
    s3 = boto3.client('s3')
    copy_source = {'Bucket': source_bucket, 'Key': source_key}
    copy_time_start = time.perf_counter()
    # create a multipart upload connection and store the upload id for the connection
    multipart_id = s3.create_multipart_upload(Bucket=target_bucket, Key=target_key, ServerSideEncryption='AES256')['UploadId']
    mirror_multipart_id = s3.create_multipart_upload(Bucket=target_bucket, Key=target_key, ServerSideEncryption='AES256')['UploadId']
    e_tags = []
    mirror_e_tags = []

    for i, copy_source_range in enumerate(chunk_ranges, start=1):
        logging.info(f'uploading chunk: {copy_source_range}')
        copy_part_start = time.perf_counter()

        response = s3.upload_part_copy(CopySourceRange=copy_source_range,
                                        CopySource=copy_source,
                                        Bucket=target_bucket,
                                        Key=target_key,
                                        UploadId=multipart_id,
                                        PartNumber=i)

        mirror_response = s3.upload_part_copy(CopySourceRange=copy_source_range,
                                        CopySource=copy_source,
                                        Bucket=mirror_bucket,
                                        Key=mirror_key,
                                        UploadId=mirror_multipart_id,
                                        PartNumber=i)

        copy_part_stop = time.perf_counter()
        copy_part_time = copy_part_stop - copy_part_start
        logging.info(f'Chunk: {copy_source_range} took {copy_part_time} seconds')

        e_tag = response['CopyPartResult']['ETag']
        e_tags.append({'ETag': e_tag, 'PartNumber': i})

        mirror_e_tag = mirror_response['CopyPartResult']['ETag']
        mirror_e_tags.append({'ETag': mirror_e_tag, 'PartNumber': i})

    multipart_upload_parts = {'Parts': e_tags}
    response = s3.complete_multipart_upload(Bucket=target_bucket,
                                            Key=target_key,
                                            MultipartUpload=multipart_upload_parts,
                                            UploadId=multipart_id)

    mirror_multipart_upload_parts = {'Parts': mirror_e_tags}
    response = s3.complete_multipart_upload(Bucket=mirror_bucket,
                                            Key=mirror_key,
                                            MultipartUpload=mirror_multipart_upload_parts,
                                            UploadId=mirror_multipart_id)

    copy_time_end = time.perf_counter()
    copy_time = copy_time_end - copy_time_start
    logging.info(f'Upload complete, upload took {copy_time}')

    s3.delete_object(Bucket=source_bucket, Key=source_key)


def create_upload_chunks(file_size, chunk_size = CHUNK_SIZE):
    full_chunks = int(file_size / chunk_size)
    remainder_chunk = file_size % chunk_size
    chunks = []
    for i in range(0, full_chunks):
        chunks.append(f'bytes={i * chunk_size}-{(i + 1) * chunk_size - 1}')
    if remainder_chunk > 0:
        chunks.append(f'bytes={full_chunks * chunk_size}-{file_size - 1}')
    return chunks


def bucket_destination_mapping():
    return json.loads(os.environ['BUCKET_PATH_MAPPING'])

def mirror_destination_mapping():
    return json.loads(os.environ['MIRROR_BUCKET_PATH_MAPPING'])