# title           : utils.py
# description     : Utils module
# author          : Volpe Center (https://www.volpe.dot.gov/)
# license         : MIT license
# ==============================================================================

import logging
import os
import ntpath
from datetime import datetime

logger = logging.getLogger()


def get_datebased_folder_name():
    current_time = datetime.now()
    return '{}/{}/{}/'.format(current_time.strftime('%Y'),
                              current_time.strftime('%m'),
                              current_time.strftime('%d'))


def determine_target_key(source_key):
    filename = ntpath.basename(source_key)
    path = os.path.dirname(source_key)

    return path + '/' + get_datebased_folder_name() + filename
