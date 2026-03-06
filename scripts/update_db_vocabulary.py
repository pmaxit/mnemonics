import os
import sys
import json
import asyncio
import argparse
import mysql.connector
from mysql.connector import Error
import google.generativeai as genai
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

API_KEY = os.getenv("GEMINI_API_KEY")
if not API_KEY:
    print("Error: GEMINI_API_KEY is not set in .env")
    sys.exit(1)

genai.configure(api_key=API_KEY)
model_json = genai.GenerativeModel('gemini-2.5-flash-lite', generation_config={"response_mime_type": "application/json"})

CONCURRENCY_LIMIT = 5

async def generate_word_info(word: str) -> dict:
    """Prompt Gemini to generate details about the given word in JSON format."""
    prompt = f"""
You are an expert linguist and English vocabulary teacher.
Please provide comprehensive details for the English vocabulary word: "{word}"

Return EXACTLY a valid JSON object with NO OTHER markdown or formatting. Include the following keys:
- "synonyms": A string of synonyms (comma-separated).
- "antonyms": A string of antonyms (comma-separated).
- "difficulty": A string representing the difficulty (e.g., "Beginner", "Intermediate", "Advanced").
- "category": An AI-generated category string for this word (e.g., "Emotions", "Science", "Business", "Everyday Life").
- "mnemonic": A short, engaging mnemonic (1-2 sentences) to help remember the word. Make it visual, funny, or bizarre.
- "meaning": A concise description or meaning of the word.
- "definition": The formal dictionary definition of the word.
- "phrases": A JSON array of strings containing at least 5 distinct common idioms, collocations, or related phrases using this word.
- "example_sentences": A JSON array of arrays (a list of lists). Each inner array should contain at least 1 example sentence (string) for the corresponding idiom/phrase in the "phrases" array.

Do not wrap it in ```json, just output the raw JSON string. Ensure keys match the above exactly.
"""
    for attempt in range(3):
        try:
            response = await asyncio.to_thread(model_json.generate_content, prompt)
            text = response.text.strip() if response.text else "{}"
            result = json.loads(text)
            return result
        except Exception as e:
            if "429" in str(e):
                print(f"Rate limit hit for ({word}). Sleeping 5s... (Attempt {attempt+1}/3)")
                await asyncio.sleep(5)
            else:
                print(f"Error generating info for '{word}': {e}")
                return {}
    return {}

async def process_word(row: dict, cursor, connection, semaphore, progress, db_lock):
    """Process a single word, fetching data from Gemini and updating the DB."""
    async with semaphore:
        word_id = row['id']
        word = row['word']
        
        info = await generate_word_info(word)
        if not info:
            print(f"Failed to generate info for {word} - skipping.")
            progress["count"] += 1
            return
            
        synonyms = info.get('synonyms', row.get('synonyms') or '')
        antonyms = info.get('antonyms', row.get('antonyms') or '')
        difficulty = info.get('difficulty', row.get('difficulty') or '')
        category = info.get('category', row.get('category') or '')
        mnemonic = info.get('mnemonic', row.get('mnemonic') or '')
        meaning = info.get('meaning', row.get('meaning') or '')
        definition = info.get('definition', '')
        phrases = info.get('phrases', [])
        example_sentences = info.get('example_sentences', [])
        
        # We will keep `ImageUrl` and `aiInsights` intact by not updating them.
        update_query = """
        UPDATE Vocabulary
        SET synonyms = %s,
            antonyms = %s,
            difficulty = %s,
            category = %s,
            mnemonic = %s,
            meaning = %s,
            definition = %s,
            phrases = %s,
            example_sentences = %s
        WHERE id = %s
        """
        
        values = (
            str(synonyms)[:15000],
            str(antonyms)[:15000],
            str(difficulty)[:50],
            str(category)[:250],
            str(mnemonic)[:15000],
            str(meaning)[:15000],
            str(definition)[:15000],
            json.dumps(phrases)[:15000] if isinstance(phrases, list) else str(phrases)[:15000],
            json.dumps(example_sentences)[:15000] if isinstance(example_sentences, list) else str(example_sentences)[:15000],
            word_id
        )
        
        async with db_lock:
            try:
                cursor.execute(update_query, values)
                connection.commit()
            except Exception as e:
                print(f"Database error updating '{word}': {e}")
            
        progress["count"] += 1
        if progress["count"] % 10 == 0 or progress["count"] == progress["total"]:
            print(f"Processed {progress['count']} / {progress['total']} words...")


def check_and_add_columns(cursor):
    """Ensure that the table has the required columns."""
    cursor.execute("SHOW COLUMNS FROM Vocabulary")
    columns = [col[0] for col in cursor.fetchall()]
    
    alter_statements = []
    if 'definition' not in columns:
        alter_statements.append("ADD COLUMN definition TEXT")
    if 'phrases' not in columns:
        alter_statements.append("ADD COLUMN phrases TEXT")
    if 'example_sentences' not in columns:
        alter_statements.append("ADD COLUMN example_sentences TEXT")
        
    if alter_statements:
        alter_query = f"ALTER TABLE Vocabulary {', '.join(alter_statements)}"
        print(f"Running: {alter_query}")
        cursor.execute(alter_query)
        print("Columns added successfully.")

async def main():
    parser = argparse.ArgumentParser(description="Update Vocabulary details in Cloud SQL Database.")
    parser.add_argument("--host", default="127.0.0.1", help="Database host (default: 127.0.0.1, useful with Cloud SQL proxy)")
    parser.add_argument("--port", type=int, default=3306, help="Database port")
    parser.add_argument("--user", default="root", help="Database user")
    parser.add_argument("--password", default="", help="Database password")
    parser.add_argument("--db", default="adveralabs_db", help="Database name")
    parser.add_argument("--limit", type=int, default=0, help="Limit number of words to process (0 = all)")
    
    args = parser.parse_args()

    # Password resolution (ask securely if not provided and not testing)
    password = args.password
    if not password:
        password = os.getenv("MYSQL_PASSWORD") or input(f"Enter password for {args.user}@{args.host}: ")

    try:
        connection = mysql.connector.connect(
            host=args.host,
            port=args.port,
            user=args.user,
            password=password,
            database=args.db
        )
        if connection.is_connected():
            print(f"Connected to MySQL Database '{args.db}'")
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        print("\nIf you are trying to connect to a Google Cloud SQL instance, make sure you are running the Cloud SQL Auth proxy:")
        print("  gcloud sql connect <instance-name> --user=root  # (For interactive session)")
        print("OR:")
        print("  cloud-sql-proxy adveralabs:<region>:<instance> --port=3306")
        sys.exit(1)
        
    cursor = connection.cursor(dictionary=True)
    
    # Pre-check schema and patch missing columns
    try:
        check_and_add_columns(cursor)
    except Exception as e:
        print(f"Error verifying columns: {e}. You may need to manually add missing columns.")
    
    # Fetch words
    print("Fetching words from database...")
    query = "SELECT id, word, synonyms, antonyms, difficulty, category, mnemonic, meaning FROM Vocabulary"
    if args.limit > 0:
        query += f" LIMIT {args.limit}"
        
    cursor.execute(query)
    rows = cursor.fetchall()
    
    total_words = len(rows)
    print(f"Found {total_words} words to process.")
    
    if total_words == 0:
        print("No words to process. Exiting.")
        return

    # Process concurrently
    semaphore = asyncio.Semaphore(CONCURRENCY_LIMIT)
    db_lock = asyncio.Lock()
    progress = {"count": 0, "total": total_words}
    
    tasks = []
    for row in rows:
        tasks.append(process_word(row, cursor, connection, semaphore, progress, db_lock))
        
    await asyncio.gather(*tasks)
    
    cursor.close()
    connection.close()
    print("Database connection closed. All done!")

if __name__ == "__main__":
    asyncio.run(main())
