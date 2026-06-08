import logging
from agents.image_generator import ImageGeneratorAgent
from agents.vocabulary_enricher import VocabularyEnrichmentAgent
from agents.vocabulary_generator import VocabularyGenerationAgent
from agents.hive_data_agent import HiveDataAgent
from services.openrouter_service import OpenRouterService
from services.vocabulary_service import VocabularyService
from services.hive_service import HiveService
from utils.config import (
    OPENROUTER_API_KEY, VOCABULARY_FILE, HIVE_DATA_DIR,
    TARGET_WORD_COUNT
)

logger = logging.getLogger(__name__)

class OrchestratorAgent:
    def __init__(self):
        self.openrouter = OpenRouterService(OPENROUTER_API_KEY)
        self.vocab_service = VocabularyService(VOCABULARY_FILE)
        self.hive_service = HiveService(HIVE_DATA_DIR)

        self.enrichment_agent = VocabularyEnrichmentAgent(self.openrouter)
        self.generation_agent = VocabularyGenerationAgent(self.openrouter)
        self.hive_agent = HiveDataAgent(self.hive_service)
        self.image_agent = ImageGeneratorAgent(self.openrouter)

    def run(self):
        logger.info('='*60)
        logger.info('Starting Database Filler Orchestrator')
        logger.info('='*60)

        existing_words = self.vocab_service.load_vocabulary()
        logger.info(f'Loaded {len(existing_words)} existing words')

        logger.info('Phase 2: Enriching existing words...')
        enriched_words = self.enrichment_agent.enrich_batch(existing_words)

        logger.info('Phase 3: Generating images for existing words...')
        enriched_words = self.image_agent.generate_images_batch(enriched_words)

        new_words_needed = TARGET_WORD_COUNT - len(enriched_words)
        logger.info(f'Phase 4: Generating {new_words_needed} new words...')
        new_words = self.generation_agent.run(new_words_needed)

        logger.info('Phase 5: Generating images for new words...')
        new_words = self.image_agent.generate_images_batch(new_words)

        all_words = enriched_words + new_words
        logger.info(f'Saving {len(all_words)} total words...')
        self.vocab_service.save_vocabulary(all_words)

        logger.info('Phase 7: Populating Hive database...')
        self.hive_agent.run(VOCABULARY_FILE)

        logger.info('='*60)
        logger.info('Database filler complete!')
        logger.info(f'Total words: {len(all_words)}')
        logger.info('='*60)