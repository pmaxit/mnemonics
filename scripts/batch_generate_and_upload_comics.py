import os
import sys
import time
import argparse
import mysql.connector
import subprocess
import threading
import concurrent.futures
from dotenv import load_dotenv

try:
    from google import genai
    from google.genai import types
    from google.genai.errors import APIError
except ImportError:
    print("Please install google-genai package: pip install google-genai")
    sys.exit(1)

# Configuration
BUCKET_NAME = "adveralabs-mnemonics-comics"
DB_HOST = "127.0.0.1"
DB_USER = "root"
DB_PASS = "Password123!"
DB_NAME = "mnemonics_db"

# Thread-safe count
processed_count = 0
error_count = 0
lock = threading.Lock()

def get_db_connection():
    return mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME
    )

def generate_image(client, word):
    prompt = (
        f"Create a 4-panel comic strip (four rectangular panels in a grid) that tells a short, realistic "
        f"story to explain the vocabulary word '{word}'. The comic should visually depict a scene and realistic "
        f"usage of the word '{word}' to help someone remember its meaning. Use a clear, engaging comic book style. "
        f"Do not include any text or speech bubbles in the images."
    )
    
    result = client.models.generate_content(
        model='gemini-2.5-flash-image',
        contents=prompt,
        config=types.GenerateContentConfig(
            response_modalities=["IMAGE"],
        )
    )
    
    if not result.candidates or not result.candidates[0].content.parts:
        return None

    part = result.candidates[0].content.parts[0]
    if hasattr(part, 'inline_data') and part.inline_data:
         return part.inline_data.data
    return None

def process_single_word(row, api_key):
    global processed_count, error_count

    word = row['word']
    word_id = row['id']
    
    client = genai.Client(api_key=api_key)
    conn = get_db_connection()
    
    import uuid
    blob_name = f"{word.lower().replace(' ', '_')}.jpg"
    tmp_file = f"/tmp/{blob_name}_{uuid.uuid4().hex}"
    
    try:
        # 1. Generate image
        image_bytes = generate_image(client, word)
        if not image_bytes:
            with lock:
                error_count += 1
            return f"Failed to generate image for '{word}'"
            
        # 2. Upload to GCS
        with open(tmp_file, "wb") as f:
            f.write(image_bytes)
            
        cmd = ["gcloud", "storage", "cp", tmp_file, f"gs://{BUCKET_NAME}/{blob_name}"]
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        public_url = f"https://storage.googleapis.com/{BUCKET_NAME}/{blob_name}"
        
        # 3. Update database
        update_cursor = conn.cursor()
        update_cursor.execute("UPDATE Vocabulary SET imageUrl = %s WHERE id = %s", (public_url, word_id))
        conn.commit()
        update_cursor.close()
        
        with lock:
            processed_count += 1
            
        return f"Successfully processed '{word}' -> {public_url}"
        
    except APIError as e:
        with lock:
            error_count += 1
        if e.code == 429:
            time.sleep(30)  # Backoff on this thread
            return f"Rate limit hit (429) for '{word}'. Backing off."
        else:
            return f"API Error for '{word}': {e}"
    except Exception as e:
        with lock:
            error_count += 1
        return f"Unexpected error for '{word}': {e}"
    finally:
        if os.path.exists(tmp_file):
            try:
                os.remove(tmp_file)
            except:
                pass
        conn.close()

def process_batch(limit=None, max_workers=5):
    load_dotenv()
    
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY not found in .env")
        sys.exit(1)
        
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT id, word, imageUrl 
        FROM Vocabulary 
        WHERE imageUrl IS NULL OR imageUrl NOT LIKE %s
    """, (f"https://storage.googleapis.com/{BUCKET_NAME}/%",))
    
    words_to_process = cursor.fetchall()
    if limit:
        words_to_process = words_to_process[:limit]
        
    cursor.close()
    conn.close()
    
    print(f"Found {len(words_to_process)} words to process. Using {max_workers} threads in parallel.")
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(process_single_word, row, api_key): row for row in words_to_process}
        
        completed = 0
        for future in concurrent.futures.as_completed(futures):
            completed += 1
            row = futures[future]
            try:
                result_msg = future.result()
                print(f"[{completed}/{len(words_to_process)}] {result_msg}")
            except Exception as exc:
                print(f"[{completed}/{len(words_to_process)}] '{row['word']}' generated an exception: {exc}")
                
    print("\\n--- Batch Processing Complete ---")
    print(f"Successfully processed: {processed_count}")
    print(f"Errors encountered: {error_count}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, help="Limit the number of words to process")
    parser.add_argument("--threads", type=int, default=5, help="Number of parallel threads")
    args = parser.parse_args()
    
    process_batch(limit=args.limit, max_workers=args.threads)
