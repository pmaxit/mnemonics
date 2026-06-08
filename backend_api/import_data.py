#!/usr/bin/env python3
"""
Import vocabulary data from JSON files into PostgreSQL.
Run this script after the database schema is created.
"""

import json
import os
import sys

db_config = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'port': int(os.environ.get('DB_PORT', '5432')),
    'database': os.environ.get('DB_NAME', 'railway'),
    'user': os.environ.get('DB_USER', 'postgres'),
    'password': os.environ.get('DB_PASSWORD', '')
}

def get_connection():
    import psycopg2
    return psycopg2.connect(**db_config)

def create_tables(conn):
    """Create database tables if they don't exist."""
    cursor = conn.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS vocabulary (
            id SERIAL PRIMARY KEY,
            word VARCHAR(255) NOT NULL UNIQUE,
            meaning TEXT NOT NULL,
            mnemonic TEXT,
            example TEXT,
            synonyms TEXT,
            antonyms TEXT,
            difficulty VARCHAR(50) DEFAULT 'intermediate',
            category VARCHAR(100) DEFAULT 'common',
            image_url TEXT,
            video_url TEXT,
            set_ids TEXT,
            ai_mnemonic TEXT,
            ai_insights TEXT,
            definition TEXT,
            phrases TEXT,
            example_sentences TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS word_sets (
            id VARCHAR(100) PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            description TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS user_profiles (
            user_id VARCHAR(128) PRIMARY KEY,
            vocabulary_level VARCHAR(50) DEFAULT '1',
            learning_goal VARCHAR(100),
            has_completed_onboarding BOOLEAN DEFAULT FALSE,
            enabled_word_sets TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS user_notes (
            user_id VARCHAR(128) NOT NULL,
            word VARCHAR(255) NOT NULL,
            notes TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (user_id, word)
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS user_learned_words (
            user_id VARCHAR(128) NOT NULL,
            word VARCHAR(255) NOT NULL,
            is_learned BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (user_id, word)
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS user_word_progress (
            user_id VARCHAR(128) NOT NULL,
            word VARCHAR(255) NOT NULL,
            progress_data JSONB,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (user_id, word)
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS study_plans (
            id SERIAL PRIMARY KEY,
            user_id VARCHAR(128) NOT NULL,
            title VARCHAR(255),
            total_words INTEGER,
            num_days INTEGER,
            words_per_day INTEGER,
            status VARCHAR(50) DEFAULT 'active',
            start_date DATE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS study_plan_days (
            id SERIAL PRIMARY KEY,
            plan_id INTEGER REFERENCES study_plans(id) ON DELETE CASCADE,
            day_number INTEGER NOT NULL,
            words JSONB,
            status VARCHAR(50) DEFAULT 'not_attempted',
            started_at TIMESTAMP,
            done_at TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    conn.commit()
    print("Tables created successfully")

def import_vocabulary_json(conn, filepath):
    """Import vocabulary from a JSON file."""
    print(f"Importing vocabulary from {filepath}...")
    cursor = conn.cursor()

    with open(filepath, 'r') as f:
        words = json.load(f)

    count = 0
    for word_data in words:
        word = word_data.get('word', '').strip()
        if not word:
            continue

        meaning = word_data.get('meaning', '').strip()
        mnemonic = word_data.get('mnemonic', '')
        example = word_data.get('example', '')
        synonyms = ','.join(word_data.get('synonyms', [])) if isinstance(word_data.get('synonyms'), list) else ''
        antonyms = ','.join(word_data.get('antonyms', [])) if isinstance(word_data.get('antonyms'), list) else ''
        difficulty = word_data.get('difficulty', 'intermediate')
        category = word_data.get('category', 'common')
        image_url = word_data.get('image', '')
        video_url = word_data.get('video', '')
        set_ids = ','.join(word_data.get('setIds', [])) if isinstance(word_data.get('setIds'), list) else ''
        ai_mnemonic = word_data.get('aiMnemonic', '')
        ai_insights = word_data.get('aiInsights', '')
        definition = word_data.get('definition', '')

        phrases = word_data.get('phrases', [])
        if isinstance(phrases, list):
            phrases = json.dumps(phrases)
        else:
            phrases = ''

        example_sentences = word_data.get('exampleSentences', [])
        if isinstance(example_sentences, list):
            example_sentences = json.dumps(example_sentences)
        else:
            example_sentences = ''

        cursor.execute("""
            INSERT INTO vocabulary (word, meaning, mnemonic, example, synonyms, antonyms,
                                   difficulty, category, image_url, video_url, set_ids,
                                   ai_mnemonic, ai_insights, definition, phrases, example_sentences)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (word) DO UPDATE SET
                meaning = EXCLUDED.meaning,
                mnemonic = EXCLUDED.mnemonic,
                example = EXCLUDED.example,
                synonyms = EXCLUDED.synonyms,
                antonyms = EXCLUDED.antonyms,
                difficulty = EXCLUDED.difficulty,
                category = EXCLUDED.category,
                image_url = EXCLUDED.image_url,
                video_url = EXCLUDED.video_url,
                set_ids = EXCLUDED.set_ids,
                ai_mnemonic = EXCLUDED.ai_mnemonic,
                ai_insights = EXCLUDED.ai_insights,
                definition = EXCLUDED.definition,
                phrases = EXCLUDED.phrases,
                example_sentences = EXCLUDED.example_sentences
        """, (word, meaning, mnemonic, example, synonyms, antonyms, difficulty, category,
              image_url, video_url, set_ids, ai_mnemonic, ai_insights, definition,
              phrases, example_sentences))
        count += 1

    conn.commit()
    print(f"Imported {count} words from {filepath}")
    return count

def import_word_sets(conn):
    """Import word sets from word_sets.json."""
    print("Importing word sets...")
    cursor = conn.cursor()

    sets = [
        ('sat', 'SAT', 'Words for SAT exam'),
        ('gre', 'GRE', 'Words for GRE exam'),
        ('emotions', 'Emotions', 'Words about feelings & emotional states'),
        ('character', 'Character', 'Words about personality & traits'),
        ('speech', 'Speech', 'Words about communication & language'),
        ('intellect', 'Intellect', 'Words about thinking & knowledge'),
        ('conflict', 'Conflict', 'Words about opposition & struggle'),
        ('power', 'Power', 'Words about authority & control'),
        ('morality', 'Morality', 'Words about ethics & right vs wrong'),
        ('criticism', 'Criticism', 'Words about judgment & evaluation'),
        ('abundance', 'Abundance', 'Words about quantity & scarcity'),
        ('change', 'Change', 'Words about transformation & transition'),
        ('mylist', 'MyList', 'Your custom list'),
        ('phrases', 'Phrases', 'Useful collocations & phrasal verbs')
    ]

    for set_id, name, description in sets:
        cursor.execute("""
            INSERT INTO word_sets (id, name, description)
            VALUES (%s, %s, %s)
            ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description
        """, (set_id, name, description))

    conn.commit()
    print(f"Imported {len(sets)} word sets")

def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--help':
        print("Usage: python import_data.py [vocabulary_json_path]")
        print("Environment variables: DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD")
        return

    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    vocab_json = os.path.join(project_root, 'assets', 'vocabulary.json')
    raw_gre_json = os.path.join(project_root, 'assets', 'raw_gre_words.json')

    if len(sys.argv) > 1:
        vocab_json = sys.argv[1]

    try:
        print("Connecting to database...")
        conn = get_connection()

        print("Creating tables...")
        create_tables(conn)

        if os.path.exists(vocab_json):
            import_vocabulary_json(conn, vocab_json)
        else:
            print(f"Warning: {vocab_json} not found, skipping")

        if os.path.exists(raw_gre_json):
            import_vocabulary_json(conn, raw_gre_json)
        else:
            print(f"Warning: {raw_gre_json} not found, skipping")

        import_word_sets(conn)

        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM vocabulary")
        count = cursor.fetchone()[0]
        print(f"\nTotal vocabulary words in database: {count}")

        cursor.execute("SELECT COUNT(*) FROM word_sets")
        count = cursor.fetchone()[0]
        print(f"Total word sets: {count}")

        cursor.close()
        conn.close()
        print("\nImport completed successfully!")

    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()