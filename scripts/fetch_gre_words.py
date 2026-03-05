import urllib.request
import json
import re
import os

url = "https://raw.githubusercontent.com/supersaiyanmode/GRE-Words-Magoosh/master/process.dict"
output_file = "assets/raw_gre_words.json"

print(f"Downloading from {url}...")
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
with urllib.request.urlopen(req) as response:
    data = json.loads(response.read().decode())

print(f"Parsing {len(data)} words...")
words_list = []
for word, html in data.items():
    # Extract meaning
    meaning_match = re.search(r'<div class="flashcard-text"><p><strong>.*?:</strong>(.*?)</p></div>', html, re.IGNORECASE)
    meaning = meaning_match.group(1).strip() if meaning_match else ""
    
    # Extract example
    example_match = re.search(r'<div class="flashcard-example"><p>(.*?)</p></div>', html, re.IGNORECASE)
    example = example_match.group(1).strip() if example_match else ""
    
    # Clean up strong tags inside the example
    example = re.sub(r'</?strong>', '', example, flags=re.IGNORECASE)
    
    words_list.append({
        "word": word,
        "meaning": meaning,
        "example": example
    })

os.makedirs('assets', exist_ok=True)
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(words_list, f, indent=4)

print(f"Successfully downloaded and saved {len(words_list)} words to {output_file}")
