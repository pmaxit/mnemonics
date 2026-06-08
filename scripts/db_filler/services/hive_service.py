import json
import os
import logging
from datetime import datetime, timedelta
from typing import List, Dict, Any
import random

logger = logging.getLogger(__name__)

class HiveService:
    def __init__(self, data_dir: str):
        self.data_dir = data_dir

    def _ensure_dir(self):
        os.makedirs(self.data_dir, exist_ok=True)

    def generate_user_word_data(self, words: List[Dict[str, Any]], user_id: str = 'default_user') -> List[Dict[str, Any]]:
        data = []
        now = datetime.now()

        for word_data in words:
            is_learned = random.random() < 0.3

            if is_learned:
                last_reviewed = now - timedelta(days=random.randint(1, 30))
                first_learned = last_reviewed - timedelta(days=random.randint(1, 60))
                review_count = random.randint(1, 10)
                correct_answers = random.randint(0, review_count)
                next_review = now + timedelta(days=random.randint(1, 14))
                learning_stage = 'mastered' if random.random() < 0.6 else 'learning'
            else:
                last_reviewed = None
                first_learned = None
                review_count = 0
                correct_answers = 0
                next_review = None
                learning_stage = 'newWord'

            data.append({
                'word': word_data['word'],
                'notes': '',
                'isLearned': is_learned,
                'nextReview': next_review.isoformat() if next_review else None,
                'reviewCount': review_count,
                'lastReviewedAt': last_reviewed.isoformat() if last_reviewed else None,
                'firstLearnedAt': first_learned.isoformat() if first_learned else None,
                'correctAnswers': correct_answers,
                'totalAnswers': review_count,
                'learningStage': learning_stage,
                'easeFactor': round(random.uniform(2.0, 2.8), 2),
                'interval': random.randint(1, 30) if is_learned else 0,
                'repetitions': random.randint(0, 5) if is_learned else 0,
                'hasBeenTested': review_count > 0,
                'aiMnemonic': word_data.get('aiMnemonic', ''),
                'aiInsights': word_data.get('aiInsights', '')
            })

        return data

    def generate_review_activity(self, user_word_data: List[Dict[str, Any]], count: int = 100) -> List[Dict[str, Any]]:
        activities = []
        now = datetime.now()

        for _ in range(count):
            word_entry = random.choice(user_word_data)
            rating = random.choice(['easy', 'medium', 'hard'])
            reviewed_at = now - timedelta(days=random.randint(0, 30))

            activities.append({
                'word': word_entry['word'],
                'reviewedAt': reviewed_at.isoformat(),
                'rating': rating
            })

        return activities

    def generate_user_settings(self) -> Dict[str, Any]:
        return {
            'dailyGoal': 60,
            'languageCodes': ['en'],
            'reviewFrequency': 30
        }

    def generate_user_info(self) -> Dict[str, Any]:
        now = datetime.now()
        return {
            'id': 'default_user',
            'name': 'Demo User',
            'email': 'demo@mnemonics.app',
            'joinedDate': (now - timedelta(days=90)).isoformat(),
            'profileImageUrl': None,
            'bio': 'Vocabulary enthusiast learning with mnemonics!',
            'preferredLanguages': ['en'],
            'timezone': 'UTC',
            'subscriptionType': 'free',
            'lastActiveDate': now.isoformat(),
            'preferences': {
                'theme': 'system',
                'notifications': True,
                'soundEffects': True
            }
        }

    def save_user_word_data(self, data: List[Dict[str, Any]]) -> None:
        self._ensure_dir()
        file_path = os.path.join(self.data_dir, 'user_word_data.json')
        with open(file_path, 'w') as f:
            json.dump(data, f, indent=2)
        logger.info(f'Saved {len(data)} user word data records')

    def save_review_activity(self, data: List[Dict[str, Any]]) -> None:
        self._ensure_dir()
        file_path = os.path.join(self.data_dir, 'review_activity.json')
        with open(file_path, 'w') as f:
            json.dump(data, f, indent=2)
        logger.info(f'Saved {len(data)} review activity records')

    def save_user_settings(self, data: Dict[str, Any]) -> None:
        self._ensure_dir()
        file_path = os.path.join(self.data_dir, 'user_settings.json')
        with open(file_path, 'w') as f:
            json.dump(data, f, indent=2)
        logger.info('Saved user settings')

    def save_user_info(self, data: Dict[str, Any]) -> None:
        self._ensure_dir()
        file_path = os.path.join(self.data_dir, 'user_info.json')
        with open(file_path, 'w') as f:
            json.dump(data, f, indent=2)
        logger.info('Saved user info')