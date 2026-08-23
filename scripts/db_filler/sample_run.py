import json
import os
import logging
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from urllib.parse import quote
from dotenv import load_dotenv

SCRIPTS_DIR = Path(__file__).resolve().parents[1]
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))
from comic_style import build_comic_prompt

load_dotenv('.env')
load_dotenv('backend_api/.env', override=False)

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

OUTPUT_DIR = 'output'
os.makedirs(OUTPUT_DIR, exist_ok=True)

OPENROUTER_API_KEY = os.getenv('OPENROUTER_API_KEY', '')
POLLINATIONS_API_KEY = os.getenv('POLLINATIONS_AI', '')
TEXT_MODEL = 'google/gemini-3.5-flash'
MAX_WORKERS = int(os.getenv('SAMPLE_RUN_WORKERS', '4'))
WORD_CATEGORY_OVERRIDES = {
    'obfuscate': 'speech',
    'lucid': 'intellect',
    'gregarious': 'character',
    'ubiquitous': 'intellect',
    'ephemeral': 'change',
    'altruistic': 'morality',
    'belligerent': 'conflict',
    'cacophony': 'speech',
    'pristine': 'change',
    'sagacious': 'intellect',
    'lethargic': 'character',
    'magnanimous': 'morality',
    'quixotic': 'intellect',
}
db_config = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', '5432')),
    'database': os.getenv('DB_NAME', 'railway'),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', ''),
}

from openai import OpenAI
openrouter_client = OpenAI(api_key=OPENROUTER_API_KEY, base_url='https://openrouter.ai/api/v1')

def get_db_connection():
    import psycopg2

    database_url = os.getenv('DATABASE_URL')
    if database_url:
        return psycopg2.connect(database_url)
    return psycopg2.connect(**db_config)

def create_vocabulary_table(conn):
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS vocabulary (
            id SERIAL PRIMARY KEY,
            word VARCHAR(255) NOT NULL UNIQUE,
            meaning TEXT NOT NULL,
            mnemonic TEXT,
            example TEXT,
            synonyms TEXT,
            antonyms TEXT,
            difficulty VARCHAR(50) DEFAULT 'intermediate',
            category VARCHAR(100) DEFAULT 'common',
            image_url TEXT,
            video_url TEXT,
            set_ids TEXT,
            ai_mnemonic TEXT,
            ai_insights TEXT,
            definition TEXT,
            phrases TEXT,
            example_sentences TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    conn.commit()
    cursor.close()

def parse_ai_insights(ai_insights):
    try:
        data = json.loads(ai_insights) if ai_insights else {}
    except json.JSONDecodeError:
        logger.warning('Could not parse aiInsights JSON')
        return '', [], []

    definition = data.get('definition', '')
    phrases = data.get('common_phrases') or data.get('phrases') or []
    example_sentences = data.get('example_sentences') or data.get('exampleSentences') or []
    return definition, phrases, example_sentences

def upsert_vocabulary_word(conn, word_data):
    word = word_data.get('word', '').strip()
    if not word:
        return False

    meaning = word_data.get('meaning', '').strip()
    mnemonic = word_data.get('mnemonic', '')
    example = word_data.get('example', '')
    synonyms = ','.join(word_data.get('synonyms', [])) if isinstance(word_data.get('synonyms'), list) else ''
    antonyms = ','.join(word_data.get('antonyms', [])) if isinstance(word_data.get('antonyms'), list) else ''
    difficulty = word_data.get('difficulty', 'intermediate')
    category = word_data.get('category', 'common')
    image_url = word_data.get('image', '')
    video_url = word_data.get('video', '')
    set_ids = ''
    ai_mnemonic = word_data.get('aiMnemonic', '')
    ai_insights = word_data.get('aiInsights', '')
    definition = word_data.get('definition', '')

    phrases = word_data.get('phrases', [])
    phrases = json.dumps(phrases) if isinstance(phrases, list) else ''

    example_sentences = word_data.get('exampleSentences', [])
    example_sentences = json.dumps(example_sentences) if isinstance(example_sentences, list) else ''

    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO vocabulary (word, meaning, mnemonic, example, synonyms, antonyms,
                               difficulty, category, image_url, video_url, set_ids,
                               ai_mnemonic, ai_insights, definition, phrases, example_sentences)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (word) DO UPDATE SET
            meaning = EXCLUDED.meaning,
            mnemonic = EXCLUDED.mnemonic,
            example = EXCLUDED.example,
            synonyms = EXCLUDED.synonyms,
            antonyms = EXCLUDED.antonyms,
            difficulty = EXCLUDED.difficulty,
            category = EXCLUDED.category,
            image_url = EXCLUDED.image_url,
            video_url = EXCLUDED.video_url,
            set_ids = EXCLUDED.set_ids,
            ai_mnemonic = EXCLUDED.ai_mnemonic,
            ai_insights = EXCLUDED.ai_insights,
            definition = EXCLUDED.definition,
            phrases = EXCLUDED.phrases,
            example_sentences = EXCLUDED.example_sentences,
            updated_at = CURRENT_TIMESTAMP
    ''', (word, meaning, mnemonic, example, synonyms, antonyms, difficulty, category,
          image_url, video_url, set_ids, ai_mnemonic, ai_insights, definition,
          phrases, example_sentences))
    conn.commit()
    cursor.close()
    return True

def generate_mnemonic(word, meaning):
    prompt = f'''Create a short, engaging mnemonic to help remember the word "{word}" meaning "{meaning}".
Make it visual and memorable with a bizarre or funny association. Keep it to 1-2 short sentences.'''

    try:
        response = openrouter_client.chat.completions.create(
            model=TEXT_MODEL,
            messages=[{'role': 'user', 'content': prompt}]
        )
        return response.choices[0].message.content
    except Exception as e:
        logger.error(f'Error generating mnemonic for {word}: {e}')
        return ''

def generate_insights(word, meaning):
    prompt = f'''For the word "{word}" (meaning: "{meaning}"), provide:
1. A short definition
2. 10 short phrases where the word is naturally used (2-4 words each)
3. 5 concise example sentences using the word in different real-world contexts (health, politics, daily life, etc.). Each must be a real sentence showing the word in action — never meta commentary about learning the word.
4. 3 synonyms
5. A memory tip

Return as JSON: {{"definition": "...", "common_phrases": [...], "example_sentences": [...], "synonyms": [...], "memory_tip": "..."}}
'''
    try:
        response = openrouter_client.chat.completions.create(
            model=TEXT_MODEL,
            messages=[{'role': 'user', 'content': prompt}],
            response_format={'type': 'json_object'}
        )
        return response.choices[0].message.content
    except Exception as e:
        logger.error(f'Error generating insights for {word}: {e}')
        return '{}'

def generate_image_cli(word, meaning):
    prompt = build_comic_prompt(word, meaning)
    image_path = Path('generated') / f'{word.replace(" ", "_")}.png'

    try:
        result = subprocess.run(
            ['polli', 'gen', 'image', prompt, '--model', 'grok-imagine', '--output', str(image_path)],
            capture_output=True,
            text=True,
            timeout=120,
            env={**os.environ, 'POLLINATIONS_API_KEY': POLLINATIONS_API_KEY}
        )

        if result.returncode == 0 and image_path.exists():
            upload = subprocess.run(
                ['polli', 'upload', str(image_path)],
                capture_output=True,
                text=True,
                timeout=120,
                env={**os.environ, 'POLLINATIONS_API_KEY': POLLINATIONS_API_KEY}
            )
            if upload.returncode == 0:
                return upload.stdout.strip()
            logger.error(f'Image upload failed: {upload.stderr}')

        logger.error(f'Image gen failed: {result.stderr}')
        return f'https://gen.pollinations.ai/image/{quote(prompt)}?model=grok-imagine'
    except Exception as e:
        logger.error(f'Error generating image for {word}: {e}')
        return f'https://gen.pollinations.ai/image/{quote(prompt)}?model=grok-imagine'

def process_word(word_data, index):
    word = word_data['word']
    meaning = word_data['meaning']
    word_key = word.lower()

    logger.info(f'[{index}] Processing: {word}')

    result = {
        'word': word,
        'meaning': meaning,
        'mnemonic': word_data.get('mnemonic', ''),
        'example': word_data.get('example', ''),
        'synonyms': word_data.get('synonyms', []),
        'antonyms': word_data.get('antonyms', []),
        'difficulty': word_data.get('difficulty', 'intermediate'),
        'category': WORD_CATEGORY_OVERRIDES.get(
            word_key, word_data.get('category', 'common')),
    }

    ai_mnemonic = generate_mnemonic(word, meaning)
    result['aiMnemonic'] = ai_mnemonic
    logger.info(f'[{index}] -> AI Mnemonic: {ai_mnemonic[:80]}...')

    ai_insights = generate_insights(word, meaning)
    result['aiInsights'] = ai_insights
    definition, phrases, example_sentences = parse_ai_insights(ai_insights)
    result['definition'] = definition
    result['phrases'] = phrases
    result['exampleSentences'] = example_sentences
    logger.info(f'[{index}] -> AI Insights generated')

    image_path = generate_image_cli(word, meaning)
    result['image'] = image_path
    logger.info(f'[{index}] -> Image: {image_path}')

    return result

def process_words_parallel(sample_words, conn):
    indexed_results = []
    db_count = 0

    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        future_to_index = {
            executor.submit(process_word, word_data, i + 1): i
            for i, word_data in enumerate(sample_words)
        }

        for future in as_completed(future_to_index):
            index = future_to_index[future]
            try:
                result = future.result()
                indexed_results.append((index, result))
                if upsert_vocabulary_word(conn, result):
                    db_count += 1
                    logger.info(f'[{index + 1}] -> DB upserted: {result["word"]}')
            except Exception as e:
                word = sample_words[index].get('word', f'#{index + 1}')
                logger.error(f'Error processing word {word}: {e}')

    indexed_results.sort(key=lambda item: item[0])
    return [result for _, result in indexed_results], db_count

def main():
    logger.info('Starting run for all words using Pollinations AI')

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    os.makedirs('generated', exist_ok=True)

    with open('assets/vocabulary.json', 'r') as f:
        all_words = json.load(f)

    sample_words = all_words
    logger.info(f'Loaded {len(sample_words)} words to process')
    logger.info(f'Processing in parallel with {MAX_WORKERS} workers')

    conn = get_db_connection()
    try:
        create_vocabulary_table(conn)
        results, db_count = process_words_parallel(sample_words, conn)
    finally:
        conn.close()

    output_json = os.path.join(OUTPUT_DIR, 'vocabulary_sample.json')
    with open(output_json, 'w') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    logger.info(f'Saved JSON to {output_json}')

    image_urls = [{'word': r['word'], 'image': r['image']} for r in results]
    image_json = os.path.join(OUTPUT_DIR, 'image_urls.json')
    with open(image_json, 'w') as f:
        json.dump(image_urls, f, indent=2)
    logger.info(f'Saved image URLs to {image_json}')

    logger.info('='*60)
    logger.info(f'Sample run complete! Processed {len(results)} words')
    logger.info(f'Database rows upserted: {db_count}')
    logger.info(f'Output files:')
    logger.info(f'  - {output_json}')
    logger.info(f'  - generated/ (images)')
    logger.info('='*60)

if __name__ == '__main__':
    main()
