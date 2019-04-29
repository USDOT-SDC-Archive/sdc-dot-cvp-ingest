import unittest
import utils
import datetime
import logging

class TestCVPepUtils(unittest.TestCase):
    def test_get_datebased_folder_name(self):
        current_time = datetime.datetime.now()
        date_str = '{}/{}/{}/'.format(
            current_time.strftime('%Y'),
            current_time.strftime('%m'),
            current_time.strftime('%d'))

        self.assertEqual(utils.get_datebased_folder_name(), date_str)

    def test_determine_target_key(self):
        date_str = utils.get_datebased_folder_name()

        target_data_key = 'cv/wydot/'

        self.assertEqual(target_data_key + "BSM/{}file.txt".format(date_str),
                         utils.determine_target_key(target_data_key, target_data_key + "BSM/file.txt"))

        target_data_key = 'cv/thea/'

        self.assertEqual(target_data_key + "BSM/{}file.txt".format(date_str),
                         utils.determine_target_key(target_data_key, target_data_key + "BSM/file.txt"))
        self.assertEqual(target_data_key + "TIM/{}file.txt".format(date_str),
                         utils.determine_target_key(target_data_key, target_data_key + "TIM/file.txt"))
        self.assertEqual(target_data_key + "SPAT/{}file.txt".format(date_str),
                         utils.determine_target_key(target_data_key, target_data_key + "SPAT/file.txt"))
        self.assertEqual(target_data_key + "SOMETHING_ELSE/{}file.txt".format(date_str),
                         utils.determine_target_key(target_data_key, target_data_key + "SOMETHING_ELSE/file.txt"))
        self.assertEqual(target_data_key + "SOMETHING_ELSE/{}bsm_file.txt".format(date_str),
                         utils.determine_target_key(target_data_key, target_data_key + "SOMETHING_ELSE/bsm_file.txt"))


if __name__ == '__main__':
    unittest.main()
