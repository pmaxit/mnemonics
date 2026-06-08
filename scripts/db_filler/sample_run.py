import json
import os
import logging
import time
import subprocess
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

OUTPUT_DIR = 'output'
os.makedirs(OUTPUT_DIR, exist_ok=True)

OPENROUTER_API_KEY = os.getenv('OPENROUTER_API_KEY', '')
POLLINATIONS_API_KEY = os.getenv('POLLINATIONS_AI', '')
TEXT_MODEL = 'google/gemini-3.5-flash'

from openai import OpenAI
openrouter_client = OpenAI(api_key=OPENROUTER_API_KEY, base_url='https://openrouter.ai/api/v1')

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
3. 3 example sentences
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
    prompt = f'''A 4-panel cartoon comic strip telling a story to explain the word "{word}" meaning "{meaning}".
Style: Colorful cartoon with comic book panels. Each panel shows a sequential story with characters.
Panel 1: [Setup/intro], Panel 2: [Conflict/problem], Panel 3: [Climax], Panel 4: [Resolution with the word's meaning revealed].
No text or words in the images. Clean cartoon style, vibrant colors, funny expressions.'''
    encoded_prompt = prompt.replace('"', '\\"')

    try:
        result = subprocess.run(
            ['npx', '@pollinations/cli', 'gen', 'image', f'"{encoded_prompt}"', '--model', 'flux', '--output', f'generated/{word.replace(" ", "_")}.png'],
            capture_output=True,
            text=True,
            timeout=120,
            env={**os.environ, 'POLLINATIONS_API_KEY': POLLINATIONS_API_KEY}
        )

        if result.returncode == 0:
            image_path = f'generated/{word.replace(" ", "_")}.png'
            if os.path.exists(image_path):
                return image_path
        logger.error(f'Image gen failed: {result.stderr}')
        return f'https://gen.pollinations.ai/image/{meaning[:50]}?model=flux'
    except Exception as e:
        logger.error(f'Error generating image for {word}: {e}')
        return f'https://gen.pollinations.ai/image/{meaning[:50]}?model=flux'

def process_word(word_data, index):
    word = word_data['word']
    meaning = word_data['meaning']

    logger.info(f'[{index}] Processing: {word}')

    result = {
        'word': word,
        'meaning': meaning,
        'mnemonic': word_data.get('mnemonic', ''),
        'example': word_data.get('example', ''),
        'synonyms': word_data.get('synonyms', []),
        'antonyms': word_data.get('antonyms', []),
        'difficulty': word_data.get('difficulty', 'intermediate'),
        'category': word_data.get('category', 'common'),
        'setIds': word_data.get('setIds', ['common'])
    }

    time.sleep(0.5)

    ai_mnemonic = generate_mnemonic(word, meaning)
    result['aiMnemonic'] = ai_mnemonic
    logger.info(f'  -> AI Mnemonic: {ai_mnemonic[:80]}...')

    time.sleep(0.5)

    ai_insights = generate_insights(word, meaning)
    result['aiInsights'] = ai_insights
    logger.info(f'  -> AI Insights generated')

    image_path = generate_image_cli(word, meaning)
    result['image'] = image_path
    logger.info(f'  -> Image: {image_path}')

    return result

def main():
    logger.info('Starting sample run with 10 words using Pollinations AI')

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    os.makedirs('generated', exist_ok=True)

    with open('assets/vocabulary.json', 'r') as f:
        all_words = json.load(f)

    sample_words = all_words[:10]
    logger.info(f'Loaded {len(sample_words)} words to process')

    results = []
    for i, word_data in enumerate(sample_words):
        try:
            result = process_word(word_data, i + 1)
            results.append(result)
        except Exception as e:
            logger.error(f'Error processing word: {e}')

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
    logger.info(f'Output files:')
    logger.info(f'  - {output_json}')
    logger.info(f'  - generated/ (images)')
    logger.info('='*60)

if __name__ == '__main__':
    main()