import json
import logging
from services.openrouter_service import OpenRouterService

logger = logging.getLogger(__name__)

class VocabularyGenerationAgent:
    def __init__(self, openrouter_service: OpenRouterService):
        self.openrouter = openrouter_service
        self.categories = ['sat', 'gre', 'toefl', 'academic', 'common', 'business', 'science']
        self.difficulties = ['basic', 'intermediate', 'advanced']

    def generate_word_prompt(self, category, difficulty, index):
        return f'''Generate a vocabulary word for {category.upper()} preparation at {difficulty} level.
Return as JSON with exactly this structure (no markdown, no extra text):
{{
    "word": "english_word",
    "meaning": "clear definition",
    "mnemonic": "Hindi-English mnemonic phrase",
    "example": "example sentence using the word",
    "synonyms": ["syn1", "syn2", "syn3"],
    "antonyms": ["ant1", "ant2"],
    "difficulty": "{difficulty}",
    "category": "{category}",
    "setIds": ["{category}"]
}}

Word #{index}:'''

    def generate_single_word(self, category, difficulty, index):
        prompt = self.generate_word_prompt(category, difficulty, index)

        try:
            response = self.openrouter.generate_text(prompt, json_mode=True, temperature=0.9)

            if not response:
                return None

            word_data = json.loads(response)

            required = ['word', 'meaning', 'difficulty', 'category']
            if not all(field in word_data and word_data[field] for field in required):
                logger.warning(f'Invalid word data from AI: {word_data}')
                return None

            return word_data

        except json.JSONDecodeError as e:
            logger.error(f'JSON parse error: {e}, response: {response}')
            return None
        except Exception as e:
            logger.error(f'Error generating word: {e}')
            return None

    def generate_words_batch(self, count, category, difficulty, start_index=0):
        words = []
        for i in range(count):
            word = self.generate_single_word(category, difficulty, start_index + i)
            if word:
                words.append(word)
            if (i + 1) % 10 == 0:
                logger.info(f'Generated {i + 1}/{count} words for {category}/{difficulty}')
        return words

    def run(self, target_count, category_distribution=None):
        logger.info(f'Starting VocabularyGenerationAgent, target: {target_count} words')

        if category_distribution is None:
            category_distribution = {cat: 1.0/len(self.categories) for cat in self.categories}

        all_words = []
        current_index = 1000

        for category, ratio in category_distribution.items():
            category_count = int(target_count * ratio)

            basic_count = int(category_count * 0.30)
            intermediate_count = int(category_count * 0.50)
            advanced_count = category_count - basic_count - intermediate_count

            if basic_count > 0:
                words = self.generate_words_batch(basic_count, category, 'basic', current_index)
                all_words.extend(words)
                current_index += basic_count

            if intermediate_count > 0:
                words = self.generate_words_batch(intermediate_count, category, 'intermediate', current_index)
                all_words.extend(words)
                current_index += intermediate_count

            if advanced_count > 0:
                words = self.generate_words_batch(advanced_count, category, 'advanced', current_index)
                all_words.extend(words)
                current_index += advanced_count

        logger.info(f'Generated {len(all_words)} new words')
        return all_words