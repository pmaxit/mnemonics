import csv
import mysql.connector
import sys

csv.field_size_limit(sys.maxsize)

def create_table(cursor):
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS Vocabulary (
        id INT AUTO_INCREMENT PRIMARY KEY,
        word VARCHAR(255) NOT NULL,
        meaning TEXT NOT NULL,
        mnemonic TEXT,
        imageUrl VARCHAR(500),
        videoUrl VARCHAR(500),
        example TEXT,
        synonyms TEXT,
        antonyms TEXT,
        difficulty VARCHAR(50),
        category VARCHAR(255),
        setIds TEXT,
        aiMnemonic TEXT,
        aiInsights TEXT
    ) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    ''')

def upload_to_mysql():
    conn = mysql.connector.connect(
        host="127.0.0.1",
        user="root",
        password="Password123!",
        database="mnemonics_db"
    )
    cursor = conn.cursor()
    create_table(cursor)
    
    # Optional: Clear existing data for fresh upload
    cursor.execute("TRUNCATE TABLE Vocabulary")

    print("Reading CSV data...")
    with open('assets/Vocabulary_with_Insights.csv', 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        header = next(reader) # skip header
        
        insert_query = '''
        INSERT INTO Vocabulary (word, meaning, mnemonic, imageUrl, videoUrl, example, synonyms, antonyms, difficulty, category, setIds, aiMnemonic, aiInsights)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        '''
        
        count = 0
        for row in reader:
            padded_row = row[:13] + [''] * max(0, 13 - len(row))
            # Truncate ai fields to fit in MySQL TEXT limits (65535 bytes, ~16000 utf-8 chars)
            padded_row[11] = padded_row[11][:15000]
            padded_row[12] = padded_row[12][:15000]
            cursor.execute(insert_query, padded_row)
            count += 1
            if count % 100 == 0:
                print(f"Uploaded {count} rows...")
            
    conn.commit()
    cursor.close()
    conn.close()
    print(f"Successfully uploaded {count} rows to MySQL.")

if __name__ == "__main__":
    upload_to_mysql()
