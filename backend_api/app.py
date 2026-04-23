from flask import Flask, jsonify, request
import mysql.connector
import os
import sys
import json as _json
from datetime import datetime

app = Flask(__name__)

DB_HOST = "35.224.79.154"
DB_USER = "root"
DB_PASS = "Password123!"
DB_NAME = "mnemonics_db"

def get_db_connection():
    unix_socket = os.environ.get("INSTANCE_UNIX_SOCKET")
    if unix_socket:
        # Connect using the Cloud SQL Unix socket
        return mysql.connector.connect(
            unix_socket=unix_socket,
            user=DB_USER,
            password=DB_PASS,
            database=DB_NAME,
            connection_timeout=5
        )
    else:
        # Fallback to TCP (e.g., local development)
        return mysql.connector.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASS,
            database=DB_NAME,
            connection_timeout=5
        )

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "ok"})

@app.route('/vocabulary', methods=['GET'])
def get_vocabulary():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM Vocabulary")
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(rows)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/notes/<user_id>/<word>', methods=['GET'])
def get_notes(user_id, word):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT notes FROM UserNotes WHERE user_id = %s AND word = %s", (user_id, word))
        row = cursor.fetchone()
        cursor.close()
        conn.close()
        if row:
            return jsonify({"notes": row['notes']})
        return jsonify({"notes": ""}) # Return empty string if not found
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
        INSERT INTO UserNotes (user_id, word, notes) VALUES (%s, %s, %s)
        ON DUPLICATE KEY UPDATE notes = %s
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
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT is_learned FROM UserLearnedWords WHERE user_id = %s AND word = %s", (user_id, word))
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
        INSERT INTO UserLearnedWords (user_id, word, is_learned) VALUES (%s, %s, %s)
        ON DUPLICATE KEY UPDATE is_learned = %s
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
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT word FROM UserLearnedWords WHERE user_id = %s AND is_learned = TRUE", (user_id,))
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
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT word, progress_data FROM UserWordProgress WHERE user_id = %s", (user_id,))
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        
        progress = {}
        for row in rows:
            progress[row['word']] = row['progress_data']
            
        return jsonify({"progress": progress})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/user_progress/<user_id>/<word>', methods=['POST'])
def save_user_progress(user_id, word):
    data = request.json
    try:
        import json
        progress_data_str = json.dumps(data)
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('''
        INSERT INTO UserWordProgress (user_id, word, progress_data) VALUES (%s, %s, %s)
        ON DUPLICATE KEY UPDATE progress_data = %s
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
        cursor.execute("DELETE FROM UserNotes WHERE user_id = %s", (user_id,))
        cursor.execute("DELETE FROM UserLearnedWords WHERE user_id = %s", (user_id,))
        cursor.execute("DELETE FROM UserWordProgress WHERE user_id = %s", (user_id,))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"status": "ok"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ---------------------------------------------------------------------------
# Study Plan Routes
# ---------------------------------------------------------------------------

@app.route('/study-plan/create', methods=['POST'])
def create_study_plan():
    """
    Creates a new AI-generated study plan.
    Body: { user_id, total_words, num_days, words_per_day, title? }
    """
    from study_plan_agent import create_study_plan as agent_create
    data = request.json or {}
    user_id = data.get('user_id')
    total_words = data.get('total_words')
    num_days = data.get('num_days')
    words_per_day = data.get('words_per_day')
    title = data.get('title')

    if not all([user_id, total_words, num_days, words_per_day]):
        return jsonify({'error': 'Missing required fields: user_id, total_words, num_days, words_per_day'}), 400

    try:
        result = agent_create(
            user_id=user_id,
            total_words=int(total_words),
            num_days=int(num_days),
            words_per_day=int(words_per_day),
            title=title,
        )
        return jsonify(result), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/study-plan/<user_id>', methods=['GET'])
def get_study_plans(user_id):
    """Returns the active study plan(s) for a user with day statuses."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            "SELECT * FROM StudyPlans WHERE user_id = %s AND status = 'active' ORDER BY created_at DESC",
            (user_id,)
        )
        plans = cursor.fetchall()

        result = []
        for plan in plans:
            cursor.execute(
                "SELECT day_number, words, status, started_at, done_at FROM StudyPlanDays WHERE plan_id = %s ORDER BY day_number",
                (plan['id'],)
            )
            days = cursor.fetchall()
            for day in days:
                if isinstance(day['words'], str):
                    day['words'] = _json.loads(day['words'])
                # Convert timestamps to ISO strings
                if day['started_at']:
                    day['started_at'] = day['started_at'].isoformat()
                if day['done_at']:
                    day['done_at'] = day['done_at'].isoformat()

            plan['start_date'] = plan['start_date'].isoformat() if plan.get('start_date') else None
            plan['created_at'] = plan['created_at'].isoformat() if plan.get('created_at') else None
            plan['updated_at'] = plan['updated_at'].isoformat() if plan.get('updated_at') else None
            plan['days'] = days
            result.append(plan)

        cursor.close()
        conn.close()
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/study-plan/<user_id>/day/<int:day_num>', methods=['GET'])
def get_study_plan_day(user_id, day_num):
    """Returns word list + status for a specific day in the user's active plan."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Get active plan
        cursor.execute(
            "SELECT id FROM StudyPlans WHERE user_id = %s AND status = 'active' ORDER BY created_at DESC LIMIT 1",
            (user_id,)
        )
        plan = cursor.fetchone()
        if not plan:
            cursor.close()
            conn.close()
            return jsonify({'error': 'No active study plan found'}), 404

        cursor.execute(
            "SELECT day_number, words, status, started_at, done_at FROM StudyPlanDays WHERE plan_id = %s AND day_number = %s",
            (plan['id'], day_num)
        )
        day = cursor.fetchone()
        cursor.close()
        conn.close()

        if not day:
            return jsonify({'error': f'Day {day_num} not found'}), 404

        if isinstance(day['words'], str):
            day['words'] = _json.loads(day['words'])
        if day['started_at']:
            day['started_at'] = day['started_at'].isoformat()
        if day['done_at']:
            day['done_at'] = day['done_at'].isoformat()

        return jsonify(day)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/study-plan/<user_id>/day/<int:day_num>/status', methods=['POST'])
def update_study_plan_day_status(user_id, day_num):
    """
    Updates the status of a study day.
    Body: { status: 'in_progress' | 'done' }
    Also auto-advances plan to 'completed' if all days are done.
    """
    data = request.json or {}
    new_status = data.get('status')
    if new_status not in ('in_progress', 'done'):
        return jsonify({'error': "status must be 'in_progress' or 'done'"}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            "SELECT id FROM StudyPlans WHERE user_id = %s AND status = 'active' ORDER BY created_at DESC LIMIT 1",
            (user_id,)
        )
        plan = cursor.fetchone()
        if not plan:
            cursor.close()
            conn.close()
            return jsonify({'error': 'No active study plan found'}), 404

        plan_id = plan['id']
        now = datetime.utcnow().isoformat()

        if new_status == 'in_progress':
            cursor.execute(
                """UPDATE StudyPlanDays
                   SET status = 'in_progress', started_at = COALESCE(started_at, %s)
                   WHERE plan_id = %s AND day_number = %s AND status = 'not_attempted'""",
                (now, plan_id, day_num)
            )
        else:  # done
            cursor.execute(
                """UPDATE StudyPlanDays
                   SET status = 'done', done_at = %s
                   WHERE plan_id = %s AND day_number = %s""",
                (now, plan_id, day_num)
            )
            # Check if all days are done → mark plan completed
            cursor.execute(
                "SELECT COUNT(*) as total FROM StudyPlanDays WHERE plan_id = %s",
                (plan_id,)
            )
            total = cursor.fetchone()['total']
            cursor.execute(
                "SELECT COUNT(*) as done FROM StudyPlanDays WHERE plan_id = %s AND status = 'done'",
                (plan_id,)
            )
            done = cursor.fetchone()['done']
            if done >= total:
                cursor.execute(
                    "UPDATE StudyPlans SET status = 'completed' WHERE id = %s",
                    (plan_id,)
                )

        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({'status': 'ok'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    # Run locally on a specified port
    port = int(os.environ.get("PORT", 8080))
    app.run(host='0.0.0.0', port=port)
