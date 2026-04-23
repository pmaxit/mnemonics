import csv
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

CSV_PATH = "lib/Data/phrases.csv"

def upload_phrases():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        with open(CSV_PATH, mode='r', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                word = row['Word/Phrase']
                category = row['Type']
                difficulty = row['Level']
                meaning = row['Meaning']
                example_sentence = row['Example Sentence from Video']
                mnemonic = row['Mnemonic']
                
                # Prepare example_sentences as JSON array
                example_sentences_json = json.dumps([example_sentence])
                
                # Use 'phrases' as setId
                set_ids = 'phrases'
                
                query = """
                INSERT INTO Vocabulary (word, category, difficulty, meaning, mnemonic, example, example_sentences, setIds)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                ON DUPLICATE KEY UPDATE
                category = VALUES(category),
                difficulty = VALUES(difficulty),
                meaning = VALUES(meaning),
                mnemonic = VALUES(mnemonic),
                example = VALUES(example),
                example_sentences = VALUES(example_sentences),
                setIds = IF(setIds LIKE '%phrases%', setIds, CONCAT(setIds, ',phrases'))
                """
                
                values = (word, category, difficulty, meaning, mnemonic, example_sentence, example_sentences_json, set_ids)
                
                cursor.execute(query, values)
        
        conn.commit()
        print("Successfully uploaded phrases to database.")
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    upload_phrases()
