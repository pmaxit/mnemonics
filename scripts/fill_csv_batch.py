import csv
import json
import os

input_json = "assets/raw_gre_words.json"
output_csv = "assets/Vocabulary - Sheet1.csv"
batch_size = 50

# Load existing CSV to avoid duplicates
existing_words = set()
try:
    with open(output_csv, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            existing_words.add(row['word'].lower())
except FileNotFoundError:
    pass

# Load raw JSON words
with open(input_json, 'r', encoding='utf-8') as f:
    words_list = json.load(f)

# Find new words to add
words_to_add = []
for item in words_list:
    word = item['word'].lower()
    if word not in existing_words:
        # Provide placeholders for now
        words_to_add.append({
            'word': item['word'],
            'meaning': item['meaning'],
            'mnemonic': '',  # Placeholder
            'image': '',     # Placeholder
            'video': 'https://storage.googleapis.com/word_vocabulary/words/lucid/movie.mov', # Default video for now
            'example': item['example'],
            'synonyms': '',  # Placeholder
            'antonyms': '',  # Placeholder
            'difficulty': 'medium', # Default
            'category': 'academic', # Default
            'setIds': 'gre' # Default
        })

print(f"Found {len(words_to_add)} new words to add.")

# Add in batches
if words_to_add:
    batch = words_to_add[:batch_size]
    
    file_exists = os.path.isfile(output_csv)
    with open(output_csv, 'a', encoding='utf-8', newline='') as f:
        fieldnames = ['word', 'meaning', 'mnemonic', 'image', 'video', 'example', 'synonyms', 'antonyms', 'difficulty', 'category', 'setIds']
        writer = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_MINIMAL)
        
        if not file_exists:
            writer.writeheader()
            
        for row in batch:
            writer.writerow(row)
            
    print(f"Added {len(batch)} words to {output_csv}.")
    print(f"{len(words_to_add) - len(batch)} words remaining.")
else:
    print("No new words to add.")
