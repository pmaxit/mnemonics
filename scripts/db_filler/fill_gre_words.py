import json
import logging
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from urllib.parse import quote

import psycopg2

SCRIPTS_DIR = Path(__file__).resolve().parents[1]
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))
from comic_style import build_comic_prompt
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv('.env')
load_dotenv('backend_api/.env', override=False)

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

SOURCE_PATH = os.getenv('GRE_SOURCE_PATH', 'assets/raw_gre_words.json')
OUTPUT_DIR = Path(os.getenv('GRE_OUTPUT_DIR', 'output'))
GENERATED_DIR = Path(os.getenv('GRE_GENERATED_DIR', 'generated/gre'))
LIMIT = int(os.getenv('GRE_WORD_LIMIT', '500'))
OFFSET = int(os.getenv('GRE_WORD_OFFSET', '0'))
MAX_WORKERS = int(os.getenv('GRE_WORKERS', '6'))
TEXT_MODEL = os.getenv('GRE_TEXT_MODEL', 'google/gemini-3.5-flash')
IMAGE_MODEL = os.getenv('POLLINATIONS_IMAGE_MODEL', 'gptimage')
IMAGE_MODE = os.getenv('POLLINATIONS_IMAGE_MODE', 'generate')
SKIP_COMPLETED = os.getenv('GRE_SKIP_COMPLETED', '1') not in ('0', 'false', 'False')

OPENROUTER_API_KEY = os.getenv('OPENROUTER_API_KEY', '')
POLLINATIONS_API_KEY = os.getenv('POLLINATIONS_AI', '')

ALLOWED_CATEGORIES = ['speech', 'intellect', 'character', 'conflict', 'morality', 'change']

CATEGORY_KEYWORDS = {
    'speech': [
        'speak', 'speech', 'express', 'expression', 'term', 'word', 'words', 'language',
        'rhetoric', 'read', 'write', 'flattery', 'praise', 'criticize', 'tell', 'argue',
        'conversation', 'eloquent', 'communication', 'verbal', 'question', 'answer',
    ],
    'intellect': [
        'intellect', 'intellectual', 'knowledge', 'understand', 'think', 'discern',
        'judgment', 'wise', 'careful', 'analyze', 'study', 'learn', 'mind', 'idea',
        'reason', 'rational', 'perceive', 'insight', 'memory', 'abstract',
    ],
    'character': [
        'personality', 'temperament', 'refinement', 'social', 'lazy', 'diligent',
        'confident', 'modest', 'proud', 'timid', 'bold', 'calm', 'poise', 'behavior',
        'attitude', 'habit', 'manner', 'reserved', 'sociable', 'courteous',
    ],
    'conflict': [
        'anger', 'angry', 'dispute', 'offended', 'attack', 'war', 'oppose', 'opposition',
        'hostile', 'aggressive', 'intimidate', 'threat', 'fight', 'argue', 'quarrel',
        'resist', 'force', 'menacing', 'revenge', 'condemn',
    ],
    'morality': [
        'moral', 'ethic', 'honest', 'dishonest', 'good', 'evil', 'fault', 'responsibility',
        'blame', 'promise', 'obligation', 'selfish', 'generous', 'charity', 'virtue',
        'corrupt', 'innocent', 'guilty', 'justice', 'fair',
    ],
    'change': [
        'change', 'become', 'grow', 'decay', 'dissolve', 'short', 'temporary', 'decline',
        'increase', 'decrease', 'alter', 'transform', 'shift', 'recover', 'weaken',
        'strengthen', 'old', 'new', 'vanish', 'fade',
    ],
}

openrouter_client = OpenAI(api_key=OPENROUTER_API_KEY, base_url='https://openrouter.ai/api/v1')


def get_db_connection():
    database_url = os.getenv('DATABASE_URL')
    if database_url:
        return psycopg2.connect(database_url)

    return psycopg2.connect(
        host=os.getenv('DB_HOST', 'localhost'),
        port=int(os.getenv('DB_PORT', '5432')),
        database=os.getenv('DB_NAME', 'railway'),
        user=os.getenv('DB_USER', 'postgres'),
        password=os.getenv('DB_PASSWORD', ''),
    )


def categorize_word(word, meaning):
    text = f'{word} {meaning}'.lower()
    scores = {
        category: sum(1 for keyword in keywords if keyword in text)
        for category, keywords in CATEGORY_KEYWORDS.items()
    }
    best_category = max(scores, key=scores.get)
    if scores[best_category] > 0:
        return best_category

    return ALLOWED_CATEGORIES[sum(ord(ch) for ch in word.lower()) % len(ALLOWED_CATEGORIES)]


def generate_enrichment(word, meaning, example):
    prompt = f'''Act as a GRE vocabulary tutor for Indian learners.

Word: "{word}"
Meaning: "{meaning}"
Example: "{example}"

Return EXACTLY valid JSON with this shape and no markdown:
{{
  "mnemonic": "1-2 short sentences. Use English only. Make a vivid, funny, visual sound-based association for remembering the word.",
  "definition": "short GRE-friendly definition",
  "common_phrases": ["2-4 word phrase", "..."],
  "example_sentences": ["sentence 1", "sentence 2", "sentence 3"],
  "synonyms": ["synonym 1", "synonym 2", "synonym 3"],
  "antonyms": ["antonym 1", "antonym 2"]
}}

Use 8-10 common_phrases. Keep everything concise and learner-friendly.'''

    try:
        response = openrouter_client.chat.completions.create(
            model=TEXT_MODEL,
            messages=[{'role': 'user', 'content': prompt}],
            response_format={'type': 'json_object'},
            temperature=0.7,
        )
        return json.loads(response.choices[0].message.content)
    except Exception as e:
        logger.error(f'Error generating enrichment for {word}: {e}')
        return {
            'mnemonic': '',
            'definition': meaning,
            'common_phrases': [],
            'example_sentences': [example] if example else [],
            'synonyms': [],
            'antonyms': [],
        }


def build_image_prompt(word, meaning, category):
    return build_comic_prompt(word, meaning, category=category)


def generate_image(word, meaning, category):
    prompt = build_image_prompt(word, meaning, category)

    if IMAGE_MODE == 'url':
        return f'https://gen.pollinations.ai/image/{quote(prompt)}?model={IMAGE_MODEL}'

    image_path = GENERATED_DIR / f'{word.replace(" ", "_").replace("/", "_")}.png'

    try:
        result = subprocess.run(
            ['polli', 'gen', 'image', prompt, '--model', IMAGE_MODEL, '--output', str(image_path)],
            capture_output=True,
            text=True,
            timeout=180,
            env={**os.environ, 'POLLINATIONS_API_KEY': POLLINATIONS_API_KEY},
        )
        if result.returncode == 0 and image_path.exists():
            upload = subprocess.run(
                ['polli', 'upload', str(image_path)],
                capture_output=True,
                text=True,
                timeout=120,
                env={**os.environ, 'POLLINATIONS_API_KEY': POLLINATIONS_API_KEY},
            )
            if upload.returncode == 0:
                return upload.stdout.strip()
            logger.error(f'Image upload failed for {word}: {upload.stderr}')
        else:
            logger.error(f'Image generation failed for {word}: {result.stderr}')
    except Exception as e:
        logger.error(f'Error generating image for {word}: {e}')

    return f'https://gen.pollinations.ai/image/{quote(prompt)}?model={IMAGE_MODEL}'


def process_word(word_data, index):
    word = word_data.get('word', '').strip()
    meaning = word_data.get('meaning', '').strip()
    example = word_data.get('example', '').strip()

    if not word or not meaning:
        raise ValueError(f'Invalid word data at index {index}')

    category = categorize_word(word, meaning)
    logger.info(f'[{index}] Processing {word} ({category})')

    enrichment = generate_enrichment(word, meaning, example)
    image_url = generate_image(word, meaning, category)

    result = {
        'word': word,
        'meaning': meaning,
        'mnemonic': enrichment.get('mnemonic', ''),
        'example': example,
        'synonyms': enrichment.get('synonyms', []),
        'antonyms': enrichment.get('antonyms', []),
        'difficulty': 'advanced',
        'category': category,
        'image': image_url,
        'video': '',
        'aiMnemonic': enrichment.get('mnemonic', ''),
        'aiInsights': json.dumps(enrichment, ensure_ascii=False),
        'definition': enrichment.get('definition', meaning),
        'phrases': enrichment.get('common_phrases', []),
        'exampleSentences': enrichment.get('example_sentences', []),
    }
    logger.info(f'[{index}] Generated {word}: {image_url}')
    return result


def upsert_vocabulary_word(word_data):
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(
            '''
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
            ''',
            (
                word_data['word'],
                word_data['meaning'],
                word_data.get('mnemonic', ''),
                word_data.get('example', ''),
                ','.join(word_data.get('synonyms', [])),
                ','.join(word_data.get('antonyms', [])),
                word_data.get('difficulty', 'advanced'),
                word_data['category'],
                word_data.get('image', ''),
                word_data.get('video', ''),
                '',
                word_data.get('aiMnemonic', ''),
                word_data.get('aiInsights', ''),
                word_data.get('definition', ''),
                json.dumps(word_data.get('phrases', []), ensure_ascii=False),
                json.dumps(word_data.get('exampleSentences', []), ensure_ascii=False),
            ),
        )
        conn.commit()
        cursor.close()
    finally:
        conn.close()


def get_completed_words(words):
    if not SKIP_COMPLETED:
        return set()

    word_names = [word_data.get('word', '').strip() for word_data in words]
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(
            '''
            SELECT word FROM vocabulary
            WHERE word = ANY(%s)
              AND image_url IS NOT NULL AND image_url <> ''
              AND ai_mnemonic IS NOT NULL AND ai_mnemonic <> ''
              AND ai_insights IS NOT NULL AND ai_insights <> ''
              AND category = ANY(%s)
            ''',
            (word_names, ALLOWED_CATEGORIES),
        )
        completed = {row[0] for row in cursor.fetchall()}
        cursor.close()
        return completed
    finally:
        conn.close()


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    GENERATED_DIR.mkdir(parents=True, exist_ok=True)

    with open(SOURCE_PATH, 'r') as f:
        all_words = json.load(f)

    selected_words = all_words[OFFSET:OFFSET + LIMIT]
    completed_words = get_completed_words(selected_words)
    if completed_words:
        selected_words = [
            word_data for word_data in selected_words
            if word_data.get('word', '').strip() not in completed_words
        ]
    logger.info(
        f'Processing {len(selected_words)} GRE words from {SOURCE_PATH} '
        f'(offset={OFFSET}, skipped={len(completed_words)}, image_model={IMAGE_MODEL}, '
        f'image_mode={IMAGE_MODE}, workers={MAX_WORKERS})'
    )

    results = []
    db_count = 0
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        future_to_index = {
            executor.submit(process_word, word_data, OFFSET + i + 1): i
            for i, word_data in enumerate(selected_words)
        }

        for future in as_completed(future_to_index):
            index = future_to_index[future]
            word = selected_words[index].get('word', f'#{OFFSET + index + 1}')
            try:
                result = future.result()
                upsert_vocabulary_word(result)
                results.append((index, result))
                db_count += 1
                logger.info(f'[{OFFSET + index + 1}] DB upserted: {word}')
            except Exception as e:
                logger.error(f'Error processing {word}: {e}')

    results.sort(key=lambda item: item[0])
    output_path = OUTPUT_DIR / f'gre_words_{OFFSET + 1}_{OFFSET + len(selected_words)}.json'
    with open(output_path, 'w') as f:
        json.dump([result for _, result in results], f, indent=2, ensure_ascii=False)

    logger.info('=' * 60)
    logger.info(f'Completed GRE fill. Processed={len(results)} DB upserted={db_count}')
    logger.info(f'Backup JSON: {output_path}')
    logger.info('=' * 60)


if __name__ == '__main__':
    main()
