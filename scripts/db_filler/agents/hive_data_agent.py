import logging
from services.hive_service import HiveService
from services.vocabulary_service import VocabularyService

logger = logging.getLogger(__name__)

class HiveDataAgent:
    def __init__(self, hive_service):
        self.hive = hive_service

    def run(self, vocabulary_file):
        logger.info('Starting HiveDataAgent')

        vocab_service = VocabularyService(vocabulary_file)
        words = vocab_service.load_vocabulary()

        if not words:
            logger.warning('No words found for Hive data generation')
            return

        logger.info(f'Generating Hive data for {len(words)} words')

        user_word_data = self.hive.generate_user_word_data(words)
        self.hive.save_user_word_data(user_word_data)

        review_activity = self.hive.generate_review_activity(user_word_data, count=len(words) * 5)
        self.hive.save_review_activity(review_activity)

        user_settings = self.hive.generate_user_settings()
        self.hive.save_user_settings(user_settings)

        user_info = self.hive.generate_user_info()
        self.hive.save_user_info(user_info)

        logger.info('Hive data generation complete')