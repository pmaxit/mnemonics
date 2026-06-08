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
                time.sleep(0.5)
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
                time.sleep(1.0)
            except Exception as e:
                logger.error(f'Error generating image: {e}')
                results.append('')
        return results