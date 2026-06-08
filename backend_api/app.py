from flask import Flask, jsonify, request
from flask_cors import CORS
import psycopg2
from psycopg2 import extras
import os
import json

app = Flask(__name__)
CORS(app)

def get_db_connection():
    conn = psycopg2.connect(
        host=os.environ.get('DB_HOST', 'localhost'),
        port=int(os.environ.get('DB_PORT', '5432')),
        database=os.environ.get('DB_NAME', 'railway'),
        user=os.environ.get('DB_USER', 'postgres'),
        password=os.environ.get('DB_PASSWORD', '')
    )
    return conn

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "ok"})

@app.route('/vocabulary', methods=['GET'])
def get_vocabulary():
    user_id = request.args.get('user_id')
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=extras.RealDictCursor)

        if user_id:
            cursor.execute(
                "SELECT vocabulary_level, enabled_word_sets FROM user_profiles WHERE user_id = %s",
                (user_id,)
            )
            user_profile = cursor.fetchone()

            enabled_sets = user_profile['enabled_word_sets'] if user_profile and user_profile['enabled_word_sets'] else None

            where_clauses = []
            query_params = []

            if enabled_sets:
                sets_list = [s.strip() for s in enabled_sets.split(',') if s.strip()]
                if sets_list:
                    placeholders = ','.join(['%s'] * len(sets_list))
                    where_clauses.append(f"category IN ({placeholders})")
                    query_params.extend(sets_list)

            if where_clauses:
                query = f"SELECT * FROM vocabulary WHERE {' AND '.join(where_clauses)}"
                cursor.execute(query, query_params)
            else:
                cursor.execute("SELECT * FROM vocabulary")
        else:
            cursor.execute("SELECT * FROM vocabulary")

        rows = cursor.fetchall()
        cursor.close()

        result = []
        for row in rows:
            r = dict(row)
            if r.get('synonyms') and isinstance(r['synonyms'], str):
                r['synonyms'] = r['synonyms'].split(',')
            if r.get('antonyms') and isinstance(r['antonyms'], str):
                r['antonyms'] = r['antonyms'].split(',')
            if r.get('phrases') and isinstance(r['phrases'], str):
                try:
                    r['phrases'] = json.loads(r['phrases'])
                except:
                    r['phrases'] = []
            if r.get('example_sentences') and isinstance(r['example_sentences'], str):
                try:
                    r['exampleSentences'] = json.loads(r['example_sentences'])
                except:
                    r['exampleSentences'] = []
            r['imageUrl'] = r.get('image_url')
            r['videoUrl'] = r.get('video_url')
            r['setIds'] = [r.get('category')] if r.get('category') else []
            r['aiMnemonic'] = r.get('ai_mnemonic')
            r['aiInsights'] = r.get('ai_insights')
            result.append(r)

        return jsonify(result)
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500
    finally:
        if conn:
            conn.close()

@app.route('/notes/<user_id>/<word>', methods=['GET'])
def get_notes(user_id, word):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=extras.RealDictCursor)
        cursor.execute("SELECT notes FROM user_notes WHERE user_id = %s AND word = %s", (user_id, word))
        row = cursor.fetchone()
        cursor.close()
        conn.close()
        if row:
            return jsonify({"notes": row['notes']})
        return jsonify({"notes": ""})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/notes/<user_id>/<word>', methods=['POST'])
def save_notes(user_id, word):
    data = request.json
    notes = data.get('notes', '')
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO user_notes (user_id, word, notes)
            VALUES (%s, %s, %s)
            ON CONFLICT (user_id, word) DO UPDATE SET notes = %s
        ''', (user_id, word, notes, notes))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"status": "ok"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/learned_status/<user_id>/<word>', methods=['GET'])
def get_learned_status(user_id, word):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=extras.RealDictCursor)
        cursor.execute("SELECT is_learned FROM user_learned_words WHERE user_id = %s AND word = %s", (user_id, word))
        row = cursor.fetchone()
        cursor.close()
        conn.close()
        if row:
            return jsonify({"is_learned": bool(row['is_learned'])})
        return jsonify({"is_learned": False})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/learned_status/<user_id>/<word>', methods=['POST'])
def save_learned_status(user_id, word):
    data = request.json
    is_learned = data.get('is_learned', False)
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO user_learned_words (user_id, word, is_learned)
            VALUES (%s, %s, %s)
            ON CONFLICT (user_id, word) DO UPDATE SET is_learned = %s
        ''', (user_id, word, is_learned, is_learned))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"status": "ok"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/learned_status/<user_id>', methods=['GET'])
def get_all_learned_status(user_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=extras.RealDictCursor)
        cursor.execute("SELECT word FROM user_learned_words WHERE user_id = %s AND is_learned = TRUE", (user_id,))
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        learned_words = [row['word'] for row in rows]
        return jsonify({"learned_words": learned_words})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/user_progress/<user_id>', methods=['GET'])
def get_user_progress(user_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=extras.RealDictCursor)
        cursor.execute("SELECT word, progress_data FROM user_word_progress WHERE user_id = %s", (user_id,))
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        progress = {}
        for row in rows:
            pd = row['progress_data']
            if isinstance(pd, str):
                pd = json.loads(pd)
            progress[row['word']] = pd

        return jsonify({"progress": progress})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/user_progress/<user_id>/<word>', methods=['POST'])
def save_user_progress(user_id, word):
    data = request.json
    try:
        progress_data_str = json.dumps(data)
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO user_word_progress (user_id, word, progress_data)
            VALUES (%s, %s, %s)
            ON CONFLICT (user_id, word) DO UPDATE SET progress_data = %s
        ''', (user_id, word, progress_data_str, progress_data_str))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"status": "ok"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/reset/<user_id>', methods=['DELETE'])
def reset_user_data(user_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM user_notes WHERE user_id = %s", (user_id,))
        cursor.execute("DELETE FROM user_learned_words WHERE user_id = %s", (user_id,))
        cursor.execute("DELETE FROM user_word_progress WHERE user_id = %s", (user_id,))
        cursor.execute("DELETE FROM user_profiles WHERE user_id = %s", (user_id,))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"status": "ok"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/user_profile/<user_id>', methods=['GET'])
def get_user_profile(user_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=extras.RealDictCursor)
        cursor.execute("SELECT * FROM user_profiles WHERE user_id = %s", (user_id,))
        row = cursor.fetchone()
        cursor.close()
        conn.close()
        if row:
            return jsonify(dict(row))
        return jsonify({
            "user_id": user_id,
            "vocabulary_level": "1",
            "learning_goal": "",
            "has_completed_onboarding": False,
            "enabled_word_sets": ""
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/user_profile/<user_id>', methods=['POST'])
def save_user_profile(user_id):
    data = request.json
    vocabulary_level = data.get('vocabulary_level', '1')
    learning_goal = data.get('learning_goal', '')
    has_completed_onboarding = data.get('has_completed_onboarding', False)
    enabled_word_sets = data.get('enabled_word_sets', '')

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO user_profiles (user_id, vocabulary_level, learning_goal, has_completed_onboarding, enabled_word_sets)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (user_id) DO UPDATE SET
                vocabulary_level = %s,
                learning_goal = %s,
                has_completed_onboarding = %s,
                enabled_word_sets = %s
        ''', (user_id, vocabulary_level, learning_goal, has_completed_onboarding, enabled_word_sets,
              vocabulary_level, learning_goal, has_completed_onboarding, enabled_word_sets))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"status": "ok"})
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

@app.route('/word_sets', methods=['GET'])
def get_word_sets():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=extras.RealDictCursor)
        category_ids = ['character', 'speech', 'intellect', 'conflict', 'morality', 'change']
        cursor.execute(
            "SELECT * FROM word_sets WHERE id = ANY(%s) ORDER BY name",
            (category_ids,)
        )
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify([dict(row) for row in rows])
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/categories', methods=['GET'])
def get_categories():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=extras.RealDictCursor)
        cursor.execute("SELECT DISTINCT category FROM vocabulary ORDER BY category")
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify([row['category'] for row in rows])
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/onboarding/curate', methods=['POST'])
def curate_onboarding():
    """Curate onboarding content based on user goal and score."""
    data = request.json
    user_id = data.get('user_id', '')
    goal = data.get('goal', '')
    score = data.get('score', 0)

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        vocabulary_level = "1"
        if score >= 8:
            vocabulary_level = "3"
        elif score >= 5:
            vocabulary_level = "2"

        cursor.execute('''
            INSERT INTO user_profiles (user_id, vocabulary_level, learning_goal, has_completed_onboarding, enabled_word_sets)
            VALUES (%s, %s, %s, TRUE, '')
            ON CONFLICT (user_id) DO UPDATE SET
                vocabulary_level = %s,
                learning_goal = %s,
                has_completed_onboarding = TRUE
        ''', (user_id, vocabulary_level, goal, vocabulary_level, goal))

        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"status": "ok", "vocabulary_level": vocabulary_level})
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

@app.route('/init', methods=['POST'])
def init_database():
    """Initialize database tables and import vocabulary data."""
    import json
    try:
        conn = get_db_connection()
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
        cursor.close()
        conn.close()

        return jsonify({"status": "tables created"})
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

@app.route('/import', methods=['POST'])
def import_vocabulary():
    """Import vocabulary from JSON body."""
    import json

    try:
        data = request.get_json()
        if not data or 'words' not in data:
            return jsonify({"error": "Missing 'words' in request body"}), 400

        words = data['words']
        conn = get_db_connection()
        cursor = conn.cursor()

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
            set_ids = ''
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
        cursor.close()
        conn.close()

        return jsonify({"status": "imported", "count": count})
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

@app.route('/import/word_sets', methods=['POST'])
def import_word_sets():
    """Import word sets."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO word_sets (id, name, description)
            VALUES ('character', 'Character', 'Words about personality & traits'),
                   ('speech', 'Speech', 'Words about communication & language'),
                   ('intellect', 'Intellect', 'Words about thinking & knowledge'),
                   ('conflict', 'Conflict', 'Words about opposition & struggle'),
                   ('morality', 'Morality', 'Words about ethics & right vs wrong'),
                   ('change', 'Change', 'Words about transformation & transition')
            ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description
        """)

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"status": "imported", "count": 6})
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 8080))
    app.run(host='0.0.0.0', port=port)
