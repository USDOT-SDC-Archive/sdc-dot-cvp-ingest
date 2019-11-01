from lambdas import utils
import datetime


class TestCVPepUtils(object):
    def test_get_datebased_folder_name(self):
        current_time = datetime.datetime.now()
        date_str = '{}/{}/{}/'.format(
            current_time.strftime('%Y'),
            current_time.strftime('%m'),
            current_time.strftime('%d'))

        assert utils.get_datebased_folder_name() == date_str

    def test_determine_target_key(self):
        date_str = utils.get_datebased_folder_name()

        target_data_key = 'cv/wydot/'

        assert target_data_key + "BSM/{}file.txt".format(date_str) == utils.determine_target_key(
            target_data_key + "BSM/file.txt"
        )

        target_data_key = 'cv/thea/'

        assert target_data_key + "BSM/{}file.txt".format(date_str) == utils.determine_target_key(
            target_data_key + "BSM/file.txt"
        )
        assert target_data_key + "TIM/{}file.txt".format(date_str) == utils.determine_target_key(
            target_data_key + "TIM/file.txt"
        )
        assert target_data_key + "SPAT/{}file.txt".format(date_str) == utils.determine_target_key(
            target_data_key + "SPAT/file.txt"
        )
        assert target_data_key + "SOMETHING_ELSE/{}file.txt".format(date_str) == utils.determine_target_key(
            target_data_key + "SOMETHING_ELSE/file.txt"
        )
        assert target_data_key + "SOMETHING_ELSE/{}bsm_file.txt".format(date_str) == utils.determine_target_key(
            target_data_key + "SOMETHING_ELSE/bsm_file.txt"
        )
