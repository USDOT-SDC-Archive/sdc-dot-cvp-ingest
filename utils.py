# title           : utils.py
# description     : Utils module
# author          : Volpe Center (https://www.volpe.dot.gov/)
# license         : MIT license
# ==============================================================================

from enum import Enum
import json
import logging
import os
import ntpath
from datetime import datetime

logger = logging.getLogger()


class DataType(Enum):
    UNKNOWN = 0
    BSM = 1
    SPEEDDATA = 2
    ENVDATA = 3
    TIM = 4
    PIKALERT = 5
    RWIS = 6


def get_filename(key):
    """return just the file name without prefixes"""
    tags = key.split("/")
    filename = tags[-1]
    return filename


def get_datebased_folder_name():
    currenttime = datetime.now()
    return '{}/{}/{}/'.format(currenttime.strftime('%Y'),
                           currenttime.strftime('%m'),
                           currenttime.strftime('%d'))


def determine_target_key(target_data_key, source_key):
    filename = ntpath.basename(source_key)
    path = os.path.dirname(source_key)

    return path + '/' + get_datebased_folder_name() + filename


def determine_target_bucket(source_bucket, target_bucket_suffix):
    if source_bucket == "dev-dot-sdc-cvp-wydot-ingest":
        return "dev-dot-sdc-raw-submissions-911061262852-us-east-1"
    if source_bucket.startswith("dev-"):
        return "dev-{}".format(target_bucket_suffix)
    if source_bucket.startswith("test-"):
        return "test-{}".format(target_bucket_suffix)
    else:
        return target_bucket_suffix


def get_data_type_based_on_key_wydot(key):
    """Check key for specific indicator of data type."""

    # ignoring case.
    first_folder_name = key.split('/')[0].lower()

    if 'bsm' in first_folder_name:
        return DataType.BSM
    if 'speeddata' in first_folder_name:
        return DataType.SPEEDDATA
    if 'envdata' in first_folder_name:
        return DataType.ENVDATA
    if 'tim' in first_folder_name:
        return DataType.TIM
    if 'rwis' in first_folder_name:
        return DataType.RWIS

    return DataType.UNKNOWN


def get_target_key_wydot(file_content, key, last_modified=None):
    """Construct target key based on data content (date, )"""

    logging.info('last_modified: {}'.format(last_modified))
    logging.info('key: {}'.format(key))
    target_key = None

    try:
        data_type = get_data_type_based_on_key_wydot(key)

        if data_type == DataType.BSM:
            json_content = json.loads(file_content)
            datetime_file = json_content['metadata']['recordGeneratedAt']\
                .replace('-', '').replace(':', '').replace('.', '')[:-5]
            location = '{:0.1f}N_{:0.1f}E'.format(
                json_content['payload']['data']['coreData']['position']['latitude'],
                json_content['payload']['data']['coreData']['position']['longitude'])

            target_key = 'wydot/BSM/{}/{}/{}'.format(datetime_file, location, key[len(data_type.name + '/'):])

        if data_type == DataType.SPEEDDATA:
            if 'PostedSpd' in file_content[:500]:
                all_lines = file_content.split('\n')
                first_line = all_lines[1].split(',')
                datetime_file = first_line[0].lstrip()
                date = datetime_file.split(" ")[0].split("/")
                time = datetime_file.split(" ")[1]
                date_str = "{}{}{}".format(date[2].zfill(4), date[0].zfill(2), date[1].zfill(2))
                datetime_file = "{}T{}Z".format(date_str, time.replace(':', '').zfill(6))

                target_key = 'wydot/SpeedData/{}/{}/{}'.format(datetime_file, "I-80", key[len(data_type.name + '/'):])
            else:
                all_lines = file_content.split('\n')
                first_line = all_lines[1].split(',')
                datetime_file = first_line[0].lstrip().replace(' ', 'T').replace(':', '') + 'Z'

                target_key = 'wydot/SpeedData/{}/{}/{}'.format(datetime_file, "I-80", key[len(data_type.name + '/'):])

        if data_type == DataType.ENVDATA:
            first_line = file_content.lstrip().split('\n')[0].split(',')
            datetime_file = first_line[0].replace(' ', 'T').replace('-', '').replace(':', '') + 'Z'
            env_text = first_line[2]
            for part in first_line[3:]:
                env_text = env_text + ',' + part
            json_content = json.loads(env_text)
            location = '{:0.1f}N_{:0.1f}E'.format(float(json_content[0]['GPSLat']),
                                                  float(json_content[0]['GPSLong']))

            target_key = 'wydot/EnvData/{}/{}/{}'.format(datetime_file, location, key[len(data_type.name + '/'):])

        if data_type == DataType.TIM:
            json_content = json.loads(file_content)
            date_time = json_content['metadata']['recordGeneratedAt']\
                            .replace('-', '').replace(':', '').replace('.', '')[:-5]
            location = '{:0.1f}N_{:0.1f}E'.format(
                float(json_content['metadata']['receivedMessageDetails']['locationData']['latitude']),
                float(json_content['metadata']['receivedMessageDetails']['locationData']['longitude']))

            target_key = 'wydot/TIM/{}/{}/{}'.format(date_time, location, key[len(data_type.name + '/'):])

        if data_type == DataType.RWIS:
            splitter = key.split('/')
            monthyear = splitter[1]
            datetime_object = datetime.strptime(monthyear, '%B%Y')

            fullorinput = splitter[2].split(' ')[0].upper()
            file_extension = os.path.splitext(key)[1]
            filename = os.path.basename(key)

            target_key = 'wydot/RWIS/{}/{}/{}/{}/{}'.format(datetime_object.strftime('%Y'), datetime_object.strftime('%m'), fullorinput, file_extension[1:].upper(), filename)

        if data_type == DataType.UNKNOWN:
            today = datetime.today()
            target_key = 'wydot/unknownDataType/{}/{}'.format(today.strftime('%Y%m%d'), ntpath.basename(key))


        logging.info('target_key: {}'.format(target_key))

        return target_key

    except Exception as e:
        logging.error(e)
        logging.error('Exception when trying to parse input: {}'.format(key))
        raise e


def get_target_key_thea(file_content, key, last_modified=None):
    """Construct target key based on data content (date, )"""

    logging.info('last_modified: {}'.format(last_modified))
    logging.info('key: {}'.format(key))

    try:
        target_key = 'thea/{}'.format(key)
        logging.info('target_key: {}'.format(target_key))

        return target_key

    except Exception as e:
        logging.error(e)
        logging.error('Exception when trying to parse input: {}'.format(key))
        raise e

