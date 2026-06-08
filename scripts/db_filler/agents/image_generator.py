import logging
from services.openrouter_service import OpenRouterService

logger = logging.getLogger(__name__)

class ImageGeneratorAgent:
    def __init__(self, openrouter_service):
        self.openrouter = openrouter_service

    def generate_image_prompt(self, word, meaning):
        return f'A vivid, memorable illustration for the word "{word}" meaning "{meaning}". Style: colorful, clear, educational, memorable. No text in image.'

    def get_pollinations_url(self, prompt):
        encoded_prompt = prompt.replace(' ', '+').replace('"', '')
        return f'https://image.pollinations.ai/prompt/{encoded_prompt}?width=512&height=512&nologo=true'

    def generate_image_for_word(self, word_data):
        word = word_data['word']
        meaning = word_data['meaning']

        logger.info(f'Generating image for word: {word}')

        try:
            prompt = self.generate_image_prompt(word, meaning)
            image_url = self.get_pollinations_url(prompt)
            word_data['image'] = image_url
            return word_data
        except Exception as e:
            logger.error(f'Error generating image for {word}: {e}')
            return word_data

    def generate_images_batch(self, words):
        results = []
        for word_data in words:
            result = self.generate_image_for_word(word_data)
            results.append(result)
        return results

    def run(self, words):
        logger.info(f'Starting ImageGeneratorAgent for {len(words)} words')
        return self.generate_images_batch(words)