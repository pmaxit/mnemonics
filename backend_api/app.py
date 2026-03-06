from flask import Flask, jsonify, request
import mysql.connector
import os
import sys

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

@app.route('/notes/<word>', methods=['GET'])
def get_notes(word):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT notes FROM UserNotes WHERE word = %s", (word,))
        row = cursor.fetchone()
        cursor.close()
        conn.close()
        if row:
            return jsonify({"notes": row['notes']})
        return jsonify({"notes": ""}) # Return empty string if not found
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/notes/<word>', methods=['POST'])
def save_notes(word):
    data = request.json
    notes = data.get('notes', '')
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('''
        INSERT INTO UserNotes (word, notes) VALUES (%s, %s)
        ON DUPLICATE KEY UPDATE notes = %s
        ''', (word, notes, notes))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"status": "ok"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Run locally on a specified port
    port = int(os.environ.get("PORT", 8080))
    app.run(host='0.0.0.0', port=port)
