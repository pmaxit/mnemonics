import os
from dotenv import load_dotenv

load_dotenv()

OPENROUTER_API_KEY = os.getenv('OPENROUTER_API_KEY', '')
OPENROUTER_BASE_URL = 'https://openrouter.ai/api/v1'

IMAGE_MODEL = 'google/gemini-2.5-flash-image'
TEXT_MODEL = 'google/gemini-3.5-flash'

VOCABULARY_FILE = 'assets/vocabulary.json'
HIVE_DATA_DIR = 'hive_data'

TARGET_WORD_COUNT = 2000
EXISTING_WORDS_COUNT = 13

DIFFICULTY_DISTRIBUTION = {
    'basic': 0.30,
    'intermediate': 0.50,
    'advanced': 0.20
}

CATEGORIES = ['sat', 'gre', 'toefl', 'academic', 'common', 'business', 'science']

MAX_RETRIES = 3
BATCH_SIZE = 50
RATE_LIMIT_DELAY = 0.5