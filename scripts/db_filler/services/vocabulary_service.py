import json
import os
import logging
from typing import List, Dict, Any

logger = logging.getLogger(__name__)

class VocabularyService:
    def __init__(self, file_path: str):
        self.file_path = file_path

    def load_vocabulary(self) -> List[Dict[str, Any]]:
        if not os.path.exists(self.file_path):
            logger.warning(f'Vocabulary file not found: {self.file_path}')
            return []

        with open(self.file_path, 'r') as f:
            return json.load(f)

    def save_vocabulary(self, vocabulary: List[Dict[str, Any]]) -> None:
        os.makedirs(os.path.dirname(self.file_path), exist_ok=True)
        with open(self.file_path, 'w') as f:
            json.dump(vocabulary, f, indent=2, ensure_ascii=False)
        logger.info(f'Saved {len(vocabulary)} words to {self.file_path}')

    def add_words(self, new_words: List[Dict[str, Any]]) -> None:
        existing = self.load_vocabulary()
        existing_words = {w['word'] for w in existing}

        for word in new_words:
            if word['word'] not in existing_words:
                existing.append(word)

        self.save_vocabulary(existing)

    def update_words(self, updates: List[Dict[str, Any]]) -> None:
        existing = self.load_vocabulary()
        word_map = {w['word']: w for w in existing}

        for update in updates:
            word = update['word']
            if word in word_map:
                word_map[word].update(update)

        self.save_vocabulary(list(word_map.values()))

    def get_word_count(self) -> int:
        return len(self.load_vocabulary())