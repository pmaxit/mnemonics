import logging
from services.openrouter_service import OpenRouterService
from services.vocabulary_service import VocabularyService

logger = logging.getLogger(__name__)

class VocabularyEnrichmentAgent:
    def __init__(self, openrouter_service: OpenRouterService):
        self.openrouter = openrouter_service

    def enrich_word(self, word_data):
        word = word_data['word']
        meaning = word_data['meaning']

        logger.info(f'Enriching word: {word}')

        try:
            mnemonic_prompt = f'''Create a short, engaging mnemonic to help remember the word "{word}" meaning "{meaning}".
Make it visual and memorable with a bizarre or funny association. Keep it to 1-2 short sentences.'''

            ai_mnemonic = self.openrouter.generate_text(mnemonic_prompt, temperature=0.8)

            insights_prompt = f'''For the word "{word}" (meaning: "{meaning}"), provide:
1. A short definition
2. 10 short phrases where the word is naturally used (2-4 words each)
3. 3 example sentences
4. 3 synonyms
5. A memory tip

Return as JSON: {{"definition": "...", "common_phrases": [...], "example_sentences": [...], "synonyms": [...], "memory_tip": "..."}}
'''

            ai_insights = self.openrouter.generate_text(insights_prompt, json_mode=True)

            word_data['aiMnemonic'] = ai_mnemonic
            word_data['aiInsights'] = ai_insights

            return word_data

        except Exception as e:
            logger.error(f'Error enriching word {word}: {e}')
            return word_data

    def enrich_batch(self, words):
        enriched = []
        for word_data in words:
            result = self.enrich_word(word_data)
            enriched.append(result)
        return enriched

    def run(self, vocabulary_file):
        logger.info('Starting VocabularyEnrichmentAgent')
        vocab_service = VocabularyService(vocabulary_file)
        words = vocab_service.load_vocabulary()

        if not words:
            logger.warning('No words found to enrich')
            return []

        enriched_words = self.enrich_batch(words)
        vocab_service.save_vocabulary(enriched_words)

        logger.info(f'Enriched {len(enriched_words)} words')
        return enriched_words