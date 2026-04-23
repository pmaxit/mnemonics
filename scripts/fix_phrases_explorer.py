import mysql.connector
import os
import json
from dotenv import load_dotenv

load_dotenv()

DB_HOST = "35.224.79.154"
DB_USER = "root"
DB_PASS = "Password123!"
DB_NAME = "mnemonics_db"

def get_db_connection():
    return mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME
    )

try:
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    # Select all phrases entries
    cursor.execute("SELECT word, example, setIds FROM Vocabulary WHERE setIds LIKE '%phrases%'")
    rows = cursor.fetchall()
    
    print(f"Updating {len(rows)} phrases...")
    
    update_query = "UPDATE Vocabulary SET phrases = %s, example_sentences = %s WHERE word = %s"
    
    count = 0
    for row in rows:
        word = row['word']
        example = row['example']
        
        phrases_json = json.dumps([word])
        examples_json = json.dumps([[example]])
        
        cursor.execute(update_query, (phrases_json, examples_json, word))
        count += 1
        
    conn.commit()
    print(f"Successfully updated {count} phrases.")
    
    cursor.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
