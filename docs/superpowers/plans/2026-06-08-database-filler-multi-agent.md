# Database Filler - Multi-Agent Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Populate the Mnemonics app database with 2000 vocabulary words (enrich 13 existing + generate 1987 new) and simulate user learning data using a multi-agent orchestrator with OpenRouter AI.

**Architecture:** Hierarchical multi-agent system with one Orchestrator Agent coordinating three specialized sub-agents (VocabularyEnrichmentAgent, VocabularyGenerationAgent, HiveDataAgent) plus an ImageGeneratorAgent. All agents communicate via defined interfaces and share OpenRouter API access.

**Tech Stack:** Python, Google ADK (Agent Development Kit), OpenRouter API (OpenAI-compatible), Hive for local data, Flutter assets JSON for vocabulary.

---

## File Structure

```
scripts/
├── db_filler/
│   ├── __init__.py
│   ├── main.py                    # Orchestrator entry point
│   ├── agents/
│   │   ├── __init__.py
│   │   ├── orchestrator.py        # Main coordinator agent
│   │   ├── vocabulary_enricher.py  # Enriches existing words with AI
│   │   ├── vocabulary_generator.py # Generates new words with AI
│   │   ├── hive_data_agent.py      # Populates Hive user data
│   │   └── image_generator.py      # Generates images via Grok
│   ├── services/
│   │   ├── __init__.py
│   │   ├── openrouter_service.py   # OpenRouter API client
│   │   ├── vocabulary_service.py   # Vocabulary read/write
│   │   └── hive_service.py         # Hive database operations
│   └── utils/
│       ├── __init__.py
│       └── config.py               # API keys, settings
```

---

## Task 1: Create Project Structure and Dependencies

**Files:**
- Create: `scripts/db_filler/__init__.py`
- Create: `scripts/db_filler/agents/__init__.py`
- Create: `scripts/db_filler/services/__init__.py`
- Create: `scripts/db_filler/utils/__init__.py`
- Create: `scripts/db_filler/requirements.txt`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p scripts/db_filler/agents scripts/db_filler/services scripts/db_filler/utils
touch scripts/db_filler/__init__.py scripts/db_filler/agents/__init__.py scripts/db_filler/services/__init__.py scripts/db_filler/utils/__init__.py
```

- [ ] **Step 2: Create requirements.txt**

```
google-adk>=0.1.0
openai>=1.0.0
python-dotenv>=1.0.0
requests>=2.31.0
hive>=2.0.0
Pillow>=10.0.0
aiohttp>=3.9.0
asyncio-throttle>=1.0.0
```

- [ ] **Step 3: Create config.py**

```python
import os
from dotenv import load_dotenv

load_dotenv()

OPENROUTER_API_KEY = os.getenv('OPENROUTER_API_KEY', '')
OPENROUTER_BASE_URL = 'https://openrouter.ai/api/v1'

IMAGE_MODEL = 'x-ai/grok-imagine-image-quality'
TEXT_MODEL = 'google/gemma-4-12b-instruct'

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
RATE_LIMIT_DELAY = 0.5  # seconds between API calls
```

---

## Task 2: Implement OpenRouter Service

**Files:**
- Create: `scripts/db_filler/services/openrouter_service.py`

- [ ] **Step 1: Write the service**

```python
import time
import json
import logging
from typing import Optional, Dict, Any, List
from openai import OpenAI
from tenacity import retry, stop_after_attempt, wait_exponential

logger = logging.getLogger(__name__)

class OpenRouterService:
    def __init__(self, api_key: str):
        self.client = OpenAI(
            api_key=api_key,
            base_url='https://openrouter.ai/api/v1'
        )

    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=10))
    def generate_text(self, prompt: str, model: str = 'google/gemma-4-12b-instruct', 
                      temperature: float = 0.7, json_mode: bool = False) -> str:
        messages = [{'role': 'user', 'content': prompt}]
        
        response = self.client.chat.completions.create(
            model=model,
            messages=messages,
            temperature=temperature,
            response_format={'type': 'json_object'} if json_mode else None
        )
        
        return response.choices[0].message.content

    def generate_text_batch(self, prompts: List[str], model: str = 'google/gemma-4-12b-instruct',
                           temperature: float = 0.7) -> List[str]:
        results = []
        for prompt in prompts:
            try:
                result = self.generate_text(prompt, model, temperature)
                results.append(result)
                time.sleep(0.5)  # Rate limiting
            except Exception as e:
                logger.error(f'Error generating text: {e}')
                results.append('')
        return results

    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=10))
    def generate_image(self, prompt: str, model: str = 'x-ai/grok-imagine-image-quality') -> str:
        response = self.client.images.generate(
            model=model,
            prompt=prompt,
            size='512x512',
            response_format='url'
        )
        
        return response.data[0].url

    def generate_image_batch(self, prompts: List[str], model: str = 'x-ai/grok-imagine-image-quality') -> List[str]:
        results = []
        for prompt in prompts:
            try:
                result = self.generate_image(prompt, model)
                results.append(result)
                time.sleep(1.0)  # Rate limiting for images
            except Exception as e:
                logger.error(f'Error generating image: {e}')
                results.append('')
        return results
```

---

## Task 3: Implement Vocabulary Service

**Files:**
- Create: `scripts/db_filler/services/vocabulary_service.py`

- [ ] **Step 1: Write the service**

```python
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
```

---

## Task 4: Implement Hive Service

**Files:**
- Create: `scripts/db_filler/services/hive_service.py`

- [ ] **Step 1: Write the service**

```python
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
            is_learned = random.random() < 0.3  # 30% learned
            review_count = random.randint(0, 10) if is_learned else 0
            
            if is_learned:
                last_reviewed = now - timedelta(days=random.randint(1, 30))
                first_learned = last_reviewed - timedelta(days=random.randint(1, 60))
                correct_answers = random.randint(0, review_count)
                next_review = now + timedelta(days=random.randint(1, 14))
                learning_stage = 'mastered' if random.random() < 0.6 else 'learning'
            else:
                last_reviewed = None
                first_learned = None
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
```

---

## Task 5: Implement VocabularyEnrichmentAgent

**Files:**
- Create: `scripts/db_filler/agents/vocabulary_enricher.py`

- [ ] **Step 1: Write the agent**

```python
import logging
from typing import List, Dict, Any
from ..services.openrouter_service import OpenRouterService
from ..services.vocabulary_service import VocabularyService

logger = logging.getLogger(__name__)

class VocabularyEnrichmentAgent:
    def __init__(self, openrouter_service: OpenRouterService):
        self.openrouter = openrouter_service

    def enrich_word(self, word_data: Dict[str, Any]) -> Dict[str, Any]:
        word = word_data['word']
        meaning = word_data['meaning']
        
        logger.info(f'Enriching word: {word}')
        
        try:
            # Generate AI mnemonic
            mnemonic_prompt = f'''Create a short, engaging mnemonic to help remember the word "{word}" meaning "{meaning}". 
Make it visual and memorable with a bizarre or funny association. Keep it to 1-2 short sentences.'''
            
            ai_mnemonic = self.openrouter.generate_text(mnemonic_prompt, temperature=0.8)
            
            # Generate AI insights
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

    def enrich_batch(self, words: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        enriched = []
        for word_data in words:
            result = self.enrich_word(word_data)
            enriched.append(result)
        return enriched

    def run(self, vocabulary_file: str) -> List[Dict[str, Any]]:
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
```

---

## Task 6: Implement ImageGeneratorAgent

**Files:**
- Create: `scripts/db_filler/agents/image_generator.py`

- [ ] **Step 1: Write the agent**

```python
import logging
from typing import List, Dict, Any
from ..services.openrouter_service import OpenRouterService

logger = logging.getLogger(__name__)

class ImageGeneratorAgent:
    def __init__(self, openrouter_service: OpenRouterService):
        self.openrouter = openrouter_service

    def generate_image_prompt(self, word: str, meaning: str) -> str:
        return f'A vivid, memorable illustration for the word "{word}" meaning "{meaning}". Style: colorful, clear, educational, memorable. No text in image.'

    def generate_image_for_word(self, word_data: Dict[str, Any]) -> Dict[str, Any]:
        word = word_data['word']
        meaning = word_data['meaning']
        
        logger.info(f'Generating image for word: {word}')
        
        try:
            prompt = self.generate_image_prompt(word, meaning)
            image_url = self.openrouter.generate_image(prompt)
            word_data['image'] = image_url
            return word_data
        except Exception as e:
            logger.error(f'Error generating image for {word}: {e}')
            return word_data

    def generate_images_batch(self, words: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        results = []
        for word_data in words:
            result = self.generate_image_for_word(word_data)
            results.append(result)
        return results

    def run(self, words: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        logger.info(f'Starting ImageGeneratorAgent for {len(words)} words')
        return self.generate_images_batch(words)
```

---

## Task 7: Implement VocabularyGenerationAgent

**Files:**
- Create: `scripts/db_filler/agents/vocabulary_generator.py`

- [ ] **Step 1: Write the agent**

```python
import json
import logging
import random
from typing import List, Dict, Any
from ..services.openrouter_service import OpenRouterService

logger = logging.getLogger(__name__)

class VocabularyGenerationAgent:
    def __init__(self, openrouter_service: OpenRouterService):
        self.openrouter = openrouter_service
        self.categories = ['sat', 'gre', 'toefl', 'academic', 'common', 'business', 'science']
        self.difficulties = ['basic', 'intermediate', 'advanced']

    def generate_word_prompt(self, category: str, difficulty: str, index: int) -> str:
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

    def generate_single_word(self, category: str, difficulty: str, index: int) -> Dict[str, Any]:
        prompt = self.generate_word_prompt(category, difficulty, index)
        
        try:
            response = self.openrouter.generate_text(prompt, json_mode=True, temperature=0.9)
            
            if not response:
                return None
            
            word_data = json.loads(response)
            
            # Validate required fields
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

    def generate_words_batch(self, count: int, category: str, difficulty: str, start_index: int = 0) -> List[Dict[str, Any]]:
        words = []
        for i in range(count):
            word = self.generate_single_word(category, difficulty, start_index + i)
            if word:
                words.append(word)
            if (i + 1) % 10 == 0:
                logger.info(f'Generated {i + 1}/{count} words for {category}/{difficulty}')
        return words

    def run(self, target_count: int, category_distribution: Dict[str, float] = None) -> List[Dict[str, Any]]:
        logger.info(f'Starting VocabularyGenerationAgent, target: {target_count} words')
        
        if category_distribution is None:
            category_distribution = {cat: 1.0/len(self.categories) for cat in self.categories}
        
        all_words = []
        current_index = 1000  # Start after existing words
        
        for category, ratio in category_distribution.items():
            category_count = int(target_count * ratio)
            
            # Distribute difficulty within category
            basic_count = int(category_count * 0.30)
            intermediate_count = int(category_count * 0.50)
            advanced_count = category_count - basic_count - intermediate_count
            
            # Generate basic words
            if basic_count > 0:
                words = self.generate_words_batch(basic_count, category, 'basic', current_index)
                all_words.extend(words)
                current_index += basic_count
            
            # Generate intermediate words
            if intermediate_count > 0:
                words = self.generate_words_batch(intermediate_count, category, 'intermediate', current_index)
                all_words.extend(words)
                current_index += intermediate_count
            
            # Generate advanced words
            if advanced_count > 0:
                words = self.generate_words_batch(advanced_count, category, 'advanced', current_index)
                all_words.extend(words)
                current_index += advanced_count
        
        logger.info(f'Generated {len(all_words)} new words')
        return all_words
```

---

## Task 8: Implement HiveDataAgent

**Files:**
- Create: `scripts/db_filler/agents/hive_data_agent.py`

- [ ] **Step 1: Write the agent**

```python
import logging
from typing import List, Dict, Any
from ..services.hive_service import HiveService
from ..services.vocabulary_service import VocabularyService

logger = logging.getLogger(__name__)

class HiveDataAgent:
    def __init__(self, hive_service: HiveService):
        self.hive = hive_service

    def run(self, vocabulary_file: str) -> None:
        logger.info('Starting HiveDataAgent')
        
        vocab_service = VocabularyService(vocabulary_file)
        words = vocab_service.load_vocabulary()
        
        if not words:
            logger.warning('No words found for Hive data generation')
            return
        
        logger.info(f'Generating Hive data for {len(words)} words')
        
        # Generate user word data
        user_word_data = self.hive.generate_user_word_data(words)
        self.hive.save_user_word_data(user_word_data)
        
        # Generate review activity
        review_activity = self.hive.generate_review_activity(user_word_data, count=len(words) * 5)
        self.hive.save_review_activity(review_activity)
        
        # Generate user settings
        user_settings = self.hive.generate_user_settings()
        self.hive.save_user_settings(user_settings)
        
        # Generate user info
        user_info = self.hive.generate_user_info()
        self.hive.save_user_info(user_info)
        
        logger.info('Hive data generation complete')
```

---

## Task 9: Implement Orchestrator Agent

**Files:**
- Create: `scripts/db_filler/agents/orchestrator.py`

- [ ] **Step 1: Write the orchestrator**

```python
import logging
from typing import Dict, Any, List
from .vocabulary_enricher import VocabularyEnrichmentAgent
from .vocabulary_generator import VocabularyGenerationAgent
from .hive_data_agent import HiveDataAgent
from .image_generator import ImageGeneratorAgent
from ..services.openrouter_service import OpenRouterService
from ..services.vocabulary_service import VocabularyService
from ..services.hive_service import HiveService
from ..utils.config import (
    OPENROUTER_API_KEY, VOCABULARY_FILE, HIVE_DATA_DIR,
    TARGET_WORD_COUNT, IMAGE_MODEL, TEXT_MODEL
)

logger = logging.getLogger(__name__)

class OrchestratorAgent:
    def __init__(self):
        self.openrouter = OpenRouterService(OPENROUTER_API_KEY)
        self.vocab_service = VocabularyService(VOCABULARY_FILE)
        self.hive_service = HiveService(HIVE_DATA_DIR)
        
        # Initialize sub-agents
        self.enrichment_agent = VocabularyEnrichmentAgent(self.openrouter)
        self.generation_agent = VocabularyGenerationAgent(self.openrouter)
        self.hive_agent = HiveDataAgent(self.hive_service)
        self.image_agent = ImageGeneratorAgent(self.openrouter)

    def run(self):
        logger.info('='*60)
        logger.info('Starting Database Filler Orchestrator')
        logger.info('='*60)
        
        # Phase 1: Load existing vocabulary
        existing_words = self.vocab_service.load_vocabulary()
        logger.info(f'Loaded {len(existing_words)} existing words')
        
        # Phase 2: Enrich existing words with AI
        logger.info('Phase 2: Enriching existing words...')
        enriched_words = self.enrichment_agent.enrich_batch(existing_words)
        
        # Phase 3: Generate images for existing words
        logger.info('Phase 3: Generating images for existing words...')
        enriched_words = self.image_agent.generate_images_batch(enriched_words)
        
        # Phase 4: Generate new words
        new_words_needed = TARGET_WORD_COUNT - len(enriched_words)
        logger.info(f'Phase 4: Generating {new_words_needed} new words...')
        new_words = self.generation_agent.run(new_words_needed)
        
        # Phase 5: Generate images for new words
        logger.info('Phase 5: Generating images for new words...')
        new_words = self.image_agent.generate_images_batch(new_words)
        
        # Phase 6: Combine and save vocabulary
        all_words = enriched_words + new_words
        logger.info(f'Saving {len(all_words)} total words...')
        self.vocab_service.save_vocabulary(all_words)
        
        # Phase 7: Populate Hive data
        logger.info('Phase 7: Populating Hive database...')
        self.hive_agent.run(VOCABULARY_FILE)
        
        logger.info('='*60)
        logger.info('Database filler complete!')
        logger.info(f'Total words: {len(all_words)}')
        logger.info('='*60)
```

---

## Task 10: Create Main Entry Point

**Files:**
- Create: `scripts/db_filler/main.py`

- [ ] **Step 1: Write main.py**

```python
import logging
import sys
import os

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from agents.orchestrator import OrchestratorAgent

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

def main():
    logger = logging.getLogger(__name__)
    logger.info('Starting Database Filler')
    
    try:
        orchestrator = OrchestratorAgent()
        orchestrator.run()
        logger.info('Done!')
    except Exception as e:
        logger.error(f'Error: {e}')
        raise

if __name__ == '__main__':
    main()
```

---

## Task 11: Install Dependencies and Run

- [ ] **Step 1: Install Python dependencies**

```bash
cd scripts/db_filler
pip install -r requirements.txt
```

- [ ] **Step 2: Verify OpenRouter API key is available**

```bash
echo $OPENROUTER_API_KEY
```

Expected: `sk-or-v1-...` (your key)

- [ ] **Step 3: Run the database filler**

```bash
cd /home/puneet/Projects/mnemonics
python scripts/db_filler/main.py
```

Expected output:
```
2024-01-01 12:00:00 - __main__ - INFO - Starting Database Filler
2024-01-01 12:00:01 - agents.orchestrator - INFO - ============================================================
2024-01-01 12:00:01 - agents.orchestrator - INFO - Starting Database Filler Orchestrator
...
```

---

## Task 12: Verify Output

- [ ] **Step 1: Verify vocabulary.json**

```bash
python -c "import json; data=json.load(open('assets/vocabulary.json')); print(f'Total words: {len(data)}'); print(f'Sample word: {data[0]')"
```

Expected: `Total words: 2000`

- [ ] **Step 2: Verify Hive data files**

```bash
ls -la hive_data/
cat hive_data/user_word_data.json | python -c "import json,sys; d=json.load(sys.stdin); print(f'User word data records: {len(d)}')"
```

Expected: `User word data records: 2000`

- [ ] **Step 3: Verify images were generated**

```bash
python -c "import json; data=json.load(open('assets/vocabulary.json')); imgs=[w for w in data if w.get('image')]; print(f'Words with images: {len(imgs)}')"
```

Expected: `Words with images: 2000`

---

## Verification Checklist

- [ ] vocabulary.json has 2000 words
- [ ] All words have: word, meaning, mnemonic, example, difficulty, category
- [ ] All words have: aiMnemonic (generated), aiInsights (generated), image (generated)
- [ ] hive_data/user_word_data.json exists with 2000 records
- [ ] hive_data/review_activity.json exists with ~10000 records
- [ ] hive_data/user_settings.json exists
- [ ] hive_data/user_info.json exists