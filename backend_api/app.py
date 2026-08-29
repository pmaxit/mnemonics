from flask import Flask, jsonify, request, send_file, send_from_directory, make_response
from flask_cors import CORS
import psycopg2
from psycopg2 import extras
import os
import json
import re
from datetime import date, datetime
from pathlib import Path

from study_plan_agents import generate_daily_plan, mark_daily_plan_complete
from study_plan_agents.orchestrator import ensure_daily_completion_table
from admin_api.admin_routes import admin_bp
from admin_api.db_setup import create_admin_tables

app = Flask(__name__)
CORS(app)

# Register admin blueprint
app.register_blueprint(admin_bp)

# Persistent volume mount (Railway): /app/word_images
IMAGE_DIR = Path(os.environ.get('WORD_IMAGES_DIR', './word_images')).resolve()
PUBLIC_BASE_URL = os.environ.get(
    'PUBLIC_BASE_URL',
    'https://mnemonics-api-production.up.railway.app',
).rstrip('/')
IMAGE_UPLOAD_TOKEN = os.environ.get('IMAGE_UPLOAD_TOKEN', '')

SLUG_RE = re.compile(r'[^a-z0-9]+')


def word_slug(word: str) -> str:
    slug = SLUG_RE.sub('_', (word or '').strip().lower()).strip('_')
    return slug or 'unknown'


def ensure_image_dir() -> None:
    IMAGE_DIR.mkdir(parents=True, exist_ok=True)


def public_word_image_url(slug: str) -> str:
    return f'{PUBLIC_BASE_URL}/word_images/{slug}.jpg'


# Mnemonic videos live on the same Railway volume: <word_images>/videos
VIDEO_DIR = Path(os.environ.get('WORD_VIDEOS_DIR', str(IMAGE_DIR / 'videos'))).resolve()
PLACEHOLDER_VIDEO_SLUG = os.environ.get('VIDEO_PLACEHOLDER', 'obfuscate')


def ensure_video_dir() -> None:
    VIDEO_DIR.mkdir(parents=True, exist_ok=True)


def public_video_url(slug: str) -> str:
    return f'{PUBLIC_BASE_URL}/videos/{slug}.mp4'


def resolve_video_url(row: dict) -> str | None:
    """Prefer a hosted clip for the word; otherwise serve the placeholder."""
    ensure_video_dir()
    word = (row.get('word') or '').strip()
    if word:
        own = VIDEO_DIR / f'{word_slug(word)}.mp4'
        if own.is_file() and own.stat().st_size > 0:
            return public_video_url(word_slug(word))

    stored = (row.get('video_url') or '').strip()
    if stored and '/videos/' in stored:
        return stored
    if (VIDEO_DIR / f'{PLACEHOLDER_VIDEO_SLUG}.mp4').is_file():
        return public_video_url(PLACEHOLDER_VIDEO_SLUG)
    return stored or None


def resolve_image_url(row: dict) -> str | None:
    """Prefer volume-backed comic image; fall back to stored URL."""
    word = (row.get('word') or '').strip()
    slug = word_slug(word)
    local_path = IMAGE_DIR / f'{slug}.jpg'
    if local_path.is_file() and local_path.stat().st_size > 0:
        return public_word_image_url(slug)

    stored = (row.get('image_url') or '').strip()
    if not stored:
        return None
    # Rewrite legacy relative paths
    if stored.startswith('/word_images/'):
        return f'{PUBLIC_BASE_URL}{stored}'
    return stored


def _iso(value):
    if value is None:
        return None
    if isinstance(value, datetime):
        return value.isoformat()
    if isinstance(value, date):
        return value.isoformat()
    return str(value)


def _word_list(value):
    if value is None:
        return []
    if isinstance(value, list):
        return [str(item).strip() for item in value if str(item).strip()]
    if isinstance(value, str):
        try:
            parsed = json.loads(value)
        except (TypeError, json.JSONDecodeError):
            return [part.strip() for part in value.split(',') if part.strip()]
        if isinstance(parsed, list):
            return [str(item).strip() for item in parsed if str(item).strip()]
    return []


def ensure_study_plan_tables(cursor) -> None:
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
    ensure_daily_completion_table(cursor)
    create_admin_tables(cursor)


def serialize_study_plan_day(row) -> dict:
    return {
        'day_number': int(row['day_number']),
        'words': _word_list(row.get('words')),
        'status': row.get('status') or 'not_attempted',
        'started_at': _iso(row.get('started_at')),
        'done_at': _iso(row.get('done_at')),
    }


def serialize_study_plan(plan_row, day_rows) -> dict:
    title = (plan_row.get('title') or '').strip()
    total_words = int(plan_row.get('total_words') or 0)
    num_days = int(plan_row.get('num_days') or 0)
    if not title:
        title = f'{total_words}-Word {num_days}-Day Plan'
    return {
        'id': str(plan_row['id']),
        'user_id': plan_row['user_id'],
        'title': title,
        'total_words': total_words,
        'num_days': num_days,
        'words_per_day': int(plan_row.get('words_per_day') or 0),
        'start_date': _iso(plan_row.get('start_date')) or date.today().isoformat(),
        'status': plan_row.get('status') or 'active',
        'days': [serialize_study_plan_day(day) for day in day_rows],
    }


def fetch_plan_days(cursor, plan_id):
    cursor.execute(
        """
        SELECT day_number, words, status, started_at, done_at
        FROM study_plan_days
        WHERE plan_id = %s
        ORDER BY day_number ASC
        """,
        (plan_id,),
    )
    return cursor.fetchall()


def load_serialized_plan(cursor, plan_id):
    cursor.execute("SELECT * FROM study_plans WHERE id = %s", (plan_id,))
    plan_row = cursor.fetchone()
    if not plan_row:
        return None
    return serialize_study_plan(plan_row, fetch_plan_days(cursor, plan_id))


def require_upload_auth() -> tuple[bool, tuple | None]:
    if not IMAGE_UPLOAD_TOKEN:
        return False, (jsonify({"error": "IMAGE_UPLOAD_TOKEN not configured"}), 503)
    auth = request.headers.get('Authorization', '')
    token = request.headers.get('X-Upload-Token', '')
    if auth.startswith('Bearer '):
        token = auth[7:].strip() or token
    if token != IMAGE_UPLOAD_TOKEN:
        return False, (jsonify({"error": "unauthorized"}), 401)
    return True, None

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
            r['imageUrl'] = resolve_image_url(r)
            r['videoUrl'] = resolve_video_url(r)
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
    """Curate onboarding content based on user goal and assessment score.

    The assessment quiz has 5 questions. Level mapping:
      0-1 correct -> level 1 (beginner)
      2-3 correct -> level 2 (intermediate)
      4-5 correct -> level 3 (advanced)
    The selected goal category is persisted as the user's enabled word set so
    the vocabulary feed and "My Words" recommendations stay focused.
    """
    data = request.json
    user_id = data.get('user_id', '')
    goal = data.get('goal', '')
    score = data.get('score', 0)

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        vocabulary_level = "1"
        if score >= 4:
            vocabulary_level = "3"
        elif score >= 2:
            vocabulary_level = "2"

        # Persist the chosen goal as the enabled word set when it matches a
        # known vocabulary category.
        enabled_sets = ''
        if goal:
            cursor.execute(
                "SELECT COUNT(*) FROM vocabulary WHERE category = %s", (goal,)
            )
            row = cursor.fetchone()
            if row and row[0] > 0:
                enabled_sets = goal

        cursor.execute('''
            INSERT INTO user_profiles (user_id, vocabulary_level, learning_goal, has_completed_onboarding, enabled_word_sets)
            VALUES (%s, %s, %s, TRUE, %s)
            ON CONFLICT (user_id) DO UPDATE SET
                vocabulary_level = %s,
                learning_goal = %s,
                has_completed_onboarding = TRUE,
                enabled_word_sets = %s
        ''', (user_id, vocabulary_level, goal, enabled_sets,
              vocabulary_level, goal, enabled_sets))

        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({
            "status": "ok",
            "vocabulary_level": vocabulary_level,
            "enabled_word_sets": enabled_sets,
        })
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

@app.route('/study-plan/create', methods=['POST'])
def create_study_plan():
    """Create a study plan with an intelligent difficulty-curve algorithm.

    The algorithm groups words by difficulty, applies a progressive
    difficulty curve across days, inserts review days every 4th day,
    and assigns XP values to each day for gamification.
    """
    data = request.get_json(silent=True) or {}
    user_id = str(data.get('user_id') or '').strip()
    if not user_id:
        return jsonify({"error": "user_id is required"}), 400

    try:
        total_words = int(data.get('total_words') or 0)
        num_days = int(data.get('num_days') or 0)
        words_per_day = int(data.get('words_per_day') or 0)
    except (TypeError, ValueError):
        return jsonify({"error": "total_words, num_days, and words_per_day must be integers"}), 400

    if total_words <= 0 or num_days <= 0:
        return jsonify({"error": "total_words and num_days must be positive"}), 400
    if words_per_day <= 0:
        words_per_day = max(1, (total_words + num_days - 1) // num_days)

    difficulty_pref = str(data.get('difficulty_pref') or 'balanced').strip()
    daily_commitment = str(data.get('daily_commitment') or 'standard').strip()
    title = str(data.get('title') or '').strip() or f'{total_words}-Word {num_days}-Day Plan'
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=extras.RealDictCursor)
        ensure_study_plan_tables(cursor)

        # ── Exclude already-assigned and learned words ───────────────────
        cursor.execute(
            """
            SELECT DISTINCT jsonb_array_elements_text(spd.words) AS word
            FROM study_plan_days spd
            JOIN study_plans sp ON sp.id = spd.plan_id
            WHERE sp.user_id = %s AND sp.status = 'active' AND spd.words IS NOT NULL
            """,
            (user_id,),
        )
        assigned = {row['word'] for row in cursor.fetchall() if row.get('word')}

        cursor.execute(
            """
            SELECT word FROM user_learned_words
            WHERE user_id = %s AND is_learned = TRUE
            """,
            (user_id,),
        )
        learned = {row['word'] for row in cursor.fetchall() if row.get('word')}

        # ── Fetch all words WITH difficulty + category ───────────────────
        cursor.execute(
            "SELECT word, difficulty, category FROM vocabulary ORDER BY word ASC"
        )
        all_rows = cursor.fetchall()
        all_words = [
            {
                'word': row['word'],
                'difficulty': (row.get('difficulty') or 'intermediate').lower(),
                'category': row.get('category') or 'common',
            }
            for row in all_rows if row.get('word')
        ]

        unused = [w for w in all_words if w['word'] not in assigned and w['word'] not in learned]
        if len(unused) < total_words:
            extra = [w for w in all_words if w['word'] not in learned and w['word'] not in assigned]
            unused.extend(extra)
            seen = set()
            deduped = []
            for w in unused:
                if w['word'] not in seen:
                    seen.add(w['word'])
                    deduped.append(w)
            unused = deduped

        if not unused:
            return jsonify({"error": "no vocabulary words available to build a plan"}), 400

        selected = unused[:total_words]
        actual_total = len(selected)
        actual_days = min(num_days, actual_total)
        actual_per_day = max(1, (actual_total + actual_days - 1) // actual_days)

        # ── Group by difficulty ──────────────────────────────────────────
        import random as _rng
        rng = _rng.Random()
        by_diff = {'basic': [], 'intermediate': [], 'advanced': []}
        for w in selected:
            d = w['difficulty'] if w['difficulty'] in by_diff else 'intermediate'
            by_diff[d].append(w)
        for d in by_diff:
            rng.shuffle(by_diff[d])

        # ── Difficulty curve ──────────────────────────────────────────────
        def curve_ratio(frac, pref):
            if pref == 'easy_start':
                b = 0.50 - 0.30 * frac
                a = 0.10 + 0.30 * frac
            elif pref == 'challenging':
                b = 0.35 - 0.25 * frac
                a = 0.25 + 0.35 * frac
            else:
                b = 0.35 - 0.10 * frac
                a = 0.25 + 0.15 * frac
            b = max(0.0, b)
            a = max(0.0, a)
            i = max(0.0, 1.0 - b - a)
            return b, i, a

        # ── Build day assignments ───────────────────────────────────────
        used_words = set()
        day_assignments = []

        for day_num in range(1, actual_days + 1):
            frac = (day_num - 1) / max(1, actual_days - 1)
            is_review = (day_num % 4 == 0 and day_num < actual_days)

            if is_review:
                pool = list(used_words)
                rng.shuffle(pool)
                chunk = pool[:actual_per_day]
                if len(chunk) < actual_per_day:
                    needed = actual_per_day - len(chunk)
                    for w in by_diff.get('intermediate', []):
                        if needed <= 0:
                            break
                        if w['word'] not in used_words:
                            chunk.append(w['word'])
                            used_words.add(w['word'])
                            needed -= 1
                xp = 15 + len(chunk) * 3
                day_assignments.append((day_num, chunk, True, xp))
            else:
                b_r, i_r, a_r = curve_ratio(frac, difficulty_pref)
                target = actual_per_day
                b_cnt = round(target * b_r)
                a_cnt = round(target * a_r)
                i_cnt = target - b_cnt - a_cnt

                chunk = []
                for _ in range(b_cnt):
                    while by_diff['basic']:
                        w = by_diff['basic'].pop(0)
                        if w['word'] not in used_words:
                            chunk.append(w['word'])
                            used_words.add(w['word'])
                            break
                for _ in range(i_cnt):
                    while by_diff['intermediate']:
                        w = by_diff['intermediate'].pop(0)
                        if w['word'] not in used_words:
                            chunk.append(w['word'])
                            used_words.add(w['word'])
                            break
                for _ in range(a_cnt):
                    while by_diff['advanced']:
                        w = by_diff['advanced'].pop(0)
                        if w['word'] not in used_words:
                            chunk.append(w['word'])
                            used_words.add(w['word'])
                            break

                # Fill gaps from remaining
                if len(chunk) < target:
                    remaining = [w for w in selected if w['word'] not in used_words]
                    rng.shuffle(remaining)
                    for w in remaining:
                        if len(chunk) >= target:
                            break
                        chunk.append(w['word'])
                        used_words.add(w['word'])

                if len(chunk) < target and day_num == actual_days:
                    filler = [w for w in [x['word'] for x in selected] if w not in chunk]
                    chunk.extend(filler[:target - len(chunk)])

                xp = 10 + len(chunk) * 2
                day_assignments.append((day_num, chunk, False, xp))

        # ── Insert plan + days ───────────────────────────────────────────
        cursor.execute(
            """
            INSERT INTO study_plans
                (user_id, title, total_words, num_days, words_per_day, status, start_date)
            VALUES (%s, %s, %s, %s, %s, 'active', CURRENT_DATE)
            RETURNING *
            """,
            (user_id, title, actual_total, actual_days, actual_per_day),
        )
        plan_row = cursor.fetchone()
        plan_id = plan_row['id']

        for day_num, chunk, _is_rev, xp in day_assignments:
            cursor.execute(
                """
                INSERT INTO study_plan_days (plan_id, day_number, words, status)
                VALUES (%s, %s, %s, 'not_attempted')
                """,
                (plan_id, day_num, extras.Json(chunk)),
            )

        conn.commit()
        serialized = load_serialized_plan(cursor, plan_id)
        cursor.close()

        # ── Gamification metadata ────────────────────────────────────────
        total_xp = sum(xp for _, _, _, xp in day_assignments)
        serialized['total_xp'] = total_xp
        serialized['difficulty_pref'] = difficulty_pref
        serialized['daily_commitment'] = daily_commitment
        day_xp = {dn: xp for dn, _, _, xp in day_assignments}
        for day in serialized.get('days', []):
            day['xp_value'] = day_xp.get(day['day_number'], 10)

        return jsonify(serialized), 201
    except Exception as e:
        import traceback
        traceback.print_exc()
        if conn:
            conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        if conn:
            conn.close()


@app.route('/study-plan/<user_id>/today', methods=['GET'])
def get_todays_study_plan(user_id):
    """Personalized daily multiplan: due reviews, new words, weak rescue, incentives."""
    user_id = str(user_id or '').strip()
    if not user_id:
        return jsonify({"error": "user_id is required"}), 400
    try:
        minutes = int(request.args.get('minutes') or 20)
    except (TypeError, ValueError):
        minutes = 20

    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=extras.RealDictCursor)
        ensure_study_plan_tables(cursor)
        plan = generate_daily_plan(cursor, user_id, minutes)
        conn.commit()
        cursor.close()
        return jsonify(plan)
    except Exception as e:
        import traceback
        traceback.print_exc()
        if conn:
            conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        if conn:
            conn.close()


@app.route('/study-plan/<user_id>/today/complete', methods=['POST'])
def complete_todays_study_plan(user_id):
    user_id = str(user_id or '').strip()
    if not user_id:
        return jsonify({"error": "user_id is required"}), 400
    data = request.get_json(silent=True) or {}
    try:
        words_completed = int(data.get('words_completed') or 0)
        points = int(data.get('points') or 0)
    except (TypeError, ValueError):
        return jsonify({"error": "words_completed and points must be integers"}), 400

    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=extras.RealDictCursor)
        ensure_study_plan_tables(cursor)
        result = mark_daily_plan_complete(cursor, user_id, words_completed, points)
        conn.commit()
        cursor.close()
        return jsonify(result)
    except Exception as e:
        import traceback
        traceback.print_exc()
        if conn:
            conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        if conn:
            conn.close()


@app.route('/study-plan/<user_id>', methods=['GET'])
def get_study_plans(user_id):
    """Return active study plans (with days) for a user."""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=extras.RealDictCursor)
        ensure_study_plan_tables(cursor)
        cursor.execute(
            """
            SELECT * FROM study_plans
            WHERE user_id = %s AND status = 'active'
            ORDER BY created_at DESC, id DESC
            """,
            (user_id,),
        )
        plans = cursor.fetchall()
        result = [
            serialize_study_plan(plan, fetch_plan_days(cursor, plan['id']))
            for plan in plans
        ]
        cursor.close()
        return jsonify(result)
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500
    finally:
        if conn:
            conn.close()


@app.route('/study-plan/<user_id>/day/<int:day_number>', methods=['GET'])
def get_study_plan_day(user_id, day_number):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=extras.RealDictCursor)
        ensure_study_plan_tables(cursor)
        cursor.execute(
            """
            SELECT spd.day_number, spd.words, spd.status, spd.started_at, spd.done_at
            FROM study_plan_days spd
            JOIN study_plans sp ON sp.id = spd.plan_id
            WHERE sp.user_id = %s AND sp.status = 'active' AND spd.day_number = %s
            ORDER BY sp.created_at DESC, sp.id DESC
            LIMIT 1
            """,
            (user_id, day_number),
        )
        row = cursor.fetchone()
        cursor.close()
        if not row:
            return jsonify({"error": f"day {day_number} not found"}), 404
        return jsonify(serialize_study_plan_day(row))
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500
    finally:
        if conn:
            conn.close()


@app.route('/study-plan/<user_id>/day/<int:day_number>/status', methods=['POST'])
def update_study_plan_day_status(user_id, day_number):
    data = request.get_json(silent=True) or {}
    status = str(data.get('status') or '').strip()
    if status not in {'not_attempted', 'in_progress', 'done'}:
        return jsonify({"error": "status must be not_attempted, in_progress, or done"}), 400

    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=extras.RealDictCursor)
        ensure_study_plan_tables(cursor)
        cursor.execute(
            """
            SELECT spd.id
            FROM study_plan_days spd
            JOIN study_plans sp ON sp.id = spd.plan_id
            WHERE sp.user_id = %s AND sp.status = 'active' AND spd.day_number = %s
            ORDER BY sp.created_at DESC, sp.id DESC
            LIMIT 1
            """,
            (user_id, day_number),
        )
        row = cursor.fetchone()
        if not row:
            cursor.close()
            return jsonify({"error": f"day {day_number} not found"}), 404

        if status == 'done':
            cursor.execute(
                """
                UPDATE study_plan_days
                SET status = %s,
                    started_at = COALESCE(started_at, NOW()),
                    done_at = NOW()
                WHERE id = %s
                """,
                (status, row['id']),
            )
        elif status == 'in_progress':
            cursor.execute(
                """
                UPDATE study_plan_days
                SET status = %s,
                    started_at = COALESCE(started_at, NOW()),
                    done_at = NULL
                WHERE id = %s
                """,
                (status, row['id']),
            )
        else:
            cursor.execute(
                """
                UPDATE study_plan_days
                SET status = %s, started_at = NULL, done_at = NULL
                WHERE id = %s
                """,
                (status, row['id']),
            )
        conn.commit()
        cursor.close()
        return jsonify({"status": status, "day_number": day_number})
    except Exception as e:
        import traceback
        traceback.print_exc()
        if conn:
            conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        if conn:
            conn.close()


@app.route('/study-plan/<plan_id>', methods=['DELETE'])
def delete_study_plan(plan_id):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=extras.RealDictCursor)
        ensure_study_plan_tables(cursor)
        cursor.execute("DELETE FROM study_plans WHERE id = %s RETURNING id", (plan_id,))
        deleted = cursor.fetchone()
        conn.commit()
        cursor.close()
        if not deleted:
            return jsonify({"error": "plan not found"}), 404
        return jsonify({"status": "deleted", "id": str(deleted['id'])})
    except Exception as e:
        import traceback
        traceback.print_exc()
        if conn:
            conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        if conn:
            conn.close()

@app.route('/word_images/<path:filename>', methods=['GET'])
def get_word_image(filename):
    """Serve comic word images from the persistent volume."""
    ensure_image_dir()
    # Only allow simple jpg filenames
    safe = Path(filename).name
    if not re.fullmatch(r'[a-z0-9_]+\.jpe?g', safe, flags=re.I):
        return jsonify({"error": "invalid filename"}), 400
    path = IMAGE_DIR / safe
    if not path.is_file():
        return jsonify({"error": "not found"}), 404
    resp = make_response(send_from_directory(IMAGE_DIR, safe, mimetype='image/jpeg'))
    resp.headers['Cache-Control'] = 'public, max-age=31536000, immutable'
    return resp


@app.route('/videos/<path:filename>', methods=['GET'])
def get_word_video(filename):
    """Stream mnemonic videos from the volume with Range support."""
    ensure_video_dir()
    safe = Path(filename).name
    if not re.fullmatch(r'[a-z0-9_]+\.mp4', safe, flags=re.I):
        return jsonify({"error": "invalid filename"}), 400
    path = VIDEO_DIR / safe
    if not path.is_file():
        return jsonify({"error": "not found"}), 404
    resp = send_file(path, mimetype='video/mp4', conditional=True)
    resp.headers['Cache-Control'] = 'public, max-age=31536000, immutable'
    return resp


@app.route('/admin/videos/<slug>', methods=['PUT'])
def upload_word_video(slug):
    """Upload an MP4 mnemonic video for a vocabulary word slug."""
    ok, err = require_upload_auth()
    if not ok:
        return err

    safe_slug = word_slug(slug)
    if not re.fullmatch(r'[a-z0-9_]+', safe_slug):
        return jsonify({"error": "invalid slug"}), 400

    data = request.get_data()
    if not data or len(data) < 1000:
        return jsonify({"error": "empty or too-small body"}), 400
    if data[4:8] != b'ftyp':
        return jsonify({"error": "body must be MP4 bytes"}), 400

    ensure_video_dir()
    dest = VIDEO_DIR / f'{safe_slug}.mp4'
    dest.write_bytes(data)
    return jsonify({"ok": True, "url": public_video_url(safe_slug), "bytes": len(data)})



def upload_word_image(slug):
    """Upload a JPEG comic image for a vocabulary word slug."""
    ok, err = require_upload_auth()
    if not ok:
        return err

    safe_slug = word_slug(slug)
    if safe_slug != slug.strip().lower().replace('-', '_'):
        # Accept raw slug-ish input after normalization
        safe_slug = word_slug(slug)

    if not re.fullmatch(r'[a-z0-9_]+', safe_slug):
        return jsonify({"error": "invalid slug"}), 400

    data = request.get_data()
    if not data or len(data) < 1000:
        return jsonify({"error": "empty or too-small body"}), 400
    # Basic JPEG magic check
    if not (data[:2] == b'\xff\xd8' or data[:8] == b'\x89PNG\r\n\x1a\n'):
        return jsonify({"error": "body must be JPEG/PNG bytes"}), 400

    ensure_image_dir()
    dest = IMAGE_DIR / f'{safe_slug}.jpg'
    # Convert PNG uploads to stored .jpg name (bytes kept as-is; browsers handle it).
    # Prefer rewriting JPEG only; if PNG, still store under .jpg extension for stable URLs.
    dest.write_bytes(data)

    # Optionally update DB image_url for matching word(s)
    updated = 0
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        url = public_word_image_url(safe_slug)
        cursor.execute(
            """
            UPDATE vocabulary
            SET image_url = %s
            WHERE regexp_replace(lower(word), '[^a-z0-9]+', '_', 'g') = %s
            """,
            (url, safe_slug),
        )
        updated = cursor.rowcount
        conn.commit()
        cursor.close()
        conn.close()
    except Exception as e:
        # File is saved even if DB update fails
        return jsonify({
            "status": "saved",
            "slug": safe_slug,
            "url": public_word_image_url(safe_slug),
            "db_updated": 0,
            "db_error": str(e),
        }), 201

    return jsonify({
        "status": "saved",
        "slug": safe_slug,
        "url": public_word_image_url(safe_slug),
        "db_updated": updated,
        "bytes": len(data),
    }), 201


@app.route('/admin/word_images', methods=['GET'])
def list_word_images():
    ok, err = require_upload_auth()
    if not ok:
        return err
    ensure_image_dir()
    files = sorted(p.name for p in IMAGE_DIR.glob('*.jpg'))
    return jsonify({"count": len(files), "files": files})


@app.errorhandler(404)
def handle_not_found(_e):
    return jsonify({"error": "not found"}), 404


if __name__ == '__main__':
    port = int(os.environ.get("PORT", 8080))
    ensure_image_dir()
    app.run(host='0.0.0.0', port=port)
