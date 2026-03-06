import csv
import json
import os
import asyncio
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("GEMINI_API_KEY")
if not API_KEY:
    raise ValueError("GEMINI_API_KEY is not set in .env")

genai.configure(api_key=API_KEY)
# We can use modern model like flash or flash-lite
# We'll use gemini-2.5-flash-lite since it aligns with what the app uses.
model_text = genai.GenerativeModel('gemini-2.5-flash-lite')
model_json = genai.GenerativeModel('gemini-2.5-flash-lite', generation_config={"response_mime_type": "application/json"})

input_csv = "assets/Vocabulary - Sheet1.csv"
output_csv = "assets/Vocabulary_with_Insights.csv"

# Batch size per concurrent processing to avoid hitting rate limit too hard
CONCURRENCY_LIMIT = 5

async def generate_mnemonic(word, meaning):
    prompt = f"""
You are an expert at creating highly memorable, slightly bizarre, and effective mnemonics for learning English vocabulary.
Create a short, engaging mnemonic to help remember the following word:

Word: "{word}"
Meaning: "{meaning}"

Instructions:
1. The user speaks Hindi. You can bridge the English word with a similar sounding word in Hindi.
2. Make it visual and funny or bizarre, as these stick best in memory.
3. Keep it to 1-2 short sentences.
4. Don't explain what a mnemonic is, just provide the mnemonic story/association directly.
5. Emphasize the connection between the *sound* of the word and its *meaning*.
"""
    for attempt in range(3):
        try:
            response = await asyncio.to_thread(model_text.generate_content, prompt)
            return response.text.strip() if response.text else ""
        except Exception as e:
            if "429" in str(e):
                print(f"Rate limit hit for mnemonic ({word}). Sleeping 5s... (Attempt {attempt+1}/3)")
                await asyncio.sleep(5)
            else:
                print(f"Error generating mnemonic for {word}: {e}")
                return ""
    return ""

async def generate_word_insights(word):
    prompt = f"""
You are an expert etymologist, linguist, and pop-culture enthusiast.
Provide deep, fascinating insights about the English vocabulary word: "{word}"

Return EXACTLY a valid JSON object with NO OTHER markdown or formatting (DO NOT wrap it in ```json) using the following structure:
{{
  "origin": "Briefly describe the etymology and history of the word.",
  "usage_contexts": "Describe typical scenarios or professional contexts where this word is commonly used.",
  "pop_culture": "Provide 1 or 2 famous quotes, book titles, movie references, or pop-culture moments where this word is notable.",
  "fun_fact": "One surprising or fun fact about this word."
}}
"""
    for attempt in range(3):
        try:
            response = await asyncio.to_thread(model_json.generate_content, prompt)
            text = response.text.strip() if response.text else "{}"
            json.loads(text)
            return text
        except Exception as e:
            if "429" in str(e):
                print(f"Rate limit hit for insights ({word}). Sleeping 5s... (Attempt {attempt+1}/3)")
                await asyncio.sleep(5)
            else:
                print(f"Error generating insights for {word}: {e}")
                return "{}"
    return "{}"

async def process_word(row, semaphore, progress):
    async with semaphore:
        word = row.get("word", "")
        meaning = row.get("meaning", "")
        
        # Check if we already have ai_mnemonic or if it's empty
        ai_mnemonic = row.get("ai_mnemonic", "")
        ai_insights = row.get("ai_insights", "")
        
        if not ai_mnemonic and word and meaning:
            ai_mnemonic = await generate_mnemonic(word, meaning)
            row["ai_mnemonic"] = ai_mnemonic
            
        if (not ai_insights or ai_insights == "{}") and word:
            ai_insights = await generate_word_insights(word)
            row["ai_insights"] = ai_insights
        
        progress["count"] += 1
        if progress["count"] % 10 == 0 or progress["count"] == progress["total"]:
            print(f"Processed {progress['count']} / {progress['total']} words...")
            
        return row
async def main():
    rows = []
    fieldnames = []
    
    with open(input_csv, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        fieldnames = list(reader.fieldnames)
        if "ai_mnemonic" not in fieldnames:
            fieldnames.append("ai_mnemonic")
        if "ai_insights" not in fieldnames:
            fieldnames.append("ai_insights")
            
        for row in reader:
            if None in row:
                del row[None]
            if "ai_mnemonic" not in row:
                row["ai_mnemonic"] = ""
            if "ai_insights" not in row:
                row["ai_insights"] = ""
            rows.append(row)

    print(f"Loaded {len(rows)} words from CSV.")
    
    semaphore = asyncio.Semaphore(CONCURRENCY_LIMIT)
    tasks = []
    
    LIMIT = len(rows) # Process all
    total_to_process = min(len(rows), LIMIT)
    print(f"Processing {total_to_process} words. This will take some time and respect rate limits.")
    progress = {"count": 0, "total": total_to_process}
    
    for row in rows[:total_to_process]:
        tasks.append(process_word(row, semaphore, progress))
        
    final_rows = await asyncio.gather(*tasks)
    
    with open(output_csv, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_MINIMAL)
        writer.writeheader()
        writer.writerows(final_rows)
        
    print(f"Saved processed output to {output_csv}.")
    
    # Also overwrite the original file for convenience
    with open(input_csv, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_MINIMAL)
        writer.writeheader()
        writer.writerows(final_rows)
    print(f"Updated original {input_csv} with the new columns.")

if __name__ == "__main__":
    asyncio.run(main())
