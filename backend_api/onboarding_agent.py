"""
onboarding_agent.py
-------------------
Agentic workflow to curate user-specific word lists after onboarding.
Ensures that users have a rich set of words tailored to their goal and difficulty level.
"""

import json
import os
import random
import google.generativeai as genai
import mysql.connector

# DB Config
DB_HOST = "35.224.79.154"
DB_USER = "root"
DB_PASS = "Password123!"
DB_NAME = "mnemonics_db"

def _get_db():
    unix_socket = os.environ.get("INSTANCE_UNIX_SOCKET")
    if unix_socket:
        return mysql.connector.connect(
            unix_socket=unix_socket,
            user=DB_USER,
            password=DB_PASS,
            database=DB_NAME,
            connection_timeout=10,
        )
    return mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
        connection_timeout=10,
    )

def curate_onboarding_results(user_id: str, goal: str, score: int) -> dict:
    """
    Curates a starting word list for the user based on their goal and score.
    1. Determines appropriate vocabulary level (1-6).
    2. Selects ~50 starting words that match the goal.
    3. Updates the UserProfile.
    4. Pre-seeds UserWordProgress to ensure these words appear in 'Revision'.
    """
    
    # Map score (0-5) to level (1-6)
    level = 1
    if score >= 5:
        level = 4
    elif score >= 4:
        level = 3
    elif score >= 2:
        level = 2
    else:
        level = 1

    conn = _get_db()
    cursor = conn.cursor(dictionary=True)

    # 1. Update User Profile (vocabulary_level is now a String)
    level_str = str(level)
    cursor.execute('''
        INSERT INTO UserProfiles (user_id, vocabulary_level, learning_goal, has_completed_onboarding, enabled_word_sets)
        VALUES (%s, %s, %s, TRUE, %s)
        ON DUPLICATE KEY UPDATE 
            vocabulary_level = %s,
            learning_goal = %s,
            has_completed_onboarding = TRUE,
            enabled_word_sets = %s
    ''', (user_id, level_str, goal, goal, level_str, goal, goal))

    # 2. Curate Words
    query = "SELECT id, word, category FROM Vocabulary WHERE FIND_IN_SET(%s, setIds) > 0"
    cursor.execute(query, (goal,))
    pool = cursor.fetchall()

    if not pool:
        cursor.execute("SELECT id, word, category FROM Vocabulary LIMIT 100")
        pool = cursor.fetchall()

    selected_words = _call_curation_agent(pool, goal, level)

    for word_data in selected_words:
        word = word_data['word']
        progress_data = {
            "repetitionNumber": 0,
            "interval": 0,
            "easeFactor": 2.5,
            "nextReviewDate": None,
            "lastReviewDate": None,
            "learningStage": "new"
        }
        progress_str = json.dumps(progress_data)
        cursor.execute('''
            INSERT INTO UserWordProgress (user_id, word, progress_data)
            VALUES (%s, %s, %s)
            ON DUPLICATE KEY UPDATE progress_data = %s
        ''', (user_id, word, progress_str, progress_str))

    conn.commit()
    cursor.close()
    conn.close()

    return {
        "status": "success",
        "user_id": user_id,
        "level": level_str,
        "goal": goal,
        "curated_count": len(selected_words)
    }

def _call_curation_agent(pool: list, goal: str, user_level: int) -> list:
    """Uses Gemini to pick the most relevant words."""
    api_key = os.environ.get("GEMINI_API_KEY")
    
    random.shuffle(pool)
    limited_pool = pool[:200]
    
    if not api_key:
        return limited_pool[:50]

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel("gemini-1.5-flash")

    prompt = f"""
You are a vocabulary curator for a learning app.
A user has joined with the goal: "{goal}" and an assessed level: {user_level} (scale 1-6).

Select the 50 most appropriate words from the list below to start their learning journey.
Prioritize:
1. Words that match the goal "{goal}".
2. Words with category levels near {user_level} (level {user_level} or {user_level + 1}).
3. High-impact words that are fundamental to "{goal}".

WORD POOL:
{json.dumps([{"word": w["word"], "category": w["category"]} for w in limited_pool])}

Return ONLY a JSON array of words. Example: [{"word": "apple"}, {"word": "banana"}]
"""

    try:
        response = model.generate_content(
            prompt,
            generation_config=genai.types.GenerationConfig(
                response_mime_type="application/json"
            ),
        )
        selected = json.loads(response.text.strip())
        if isinstance(selected, list):
            return selected
    except Exception as e:
        print(f"Curation Agent Error: {e}")

    return limited_pool[:50]

def generate_settings_summary(level: str, enabled_sets: str) -> str:
    """Uses Gemini to generate a personalized summary of the user's focus."""
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        return f"Focusing on Level {level} words from {enabled_sets or 'your library'}."

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel("gemini-1.5-flash")

    prompt = f"""
You are an encouraging vocabulary coach.
Generate a short, user-friendly summary (1-2 sentences) of a user's current study configuration.
Selected Levels: {level} (Scale 1-6, multiple levels possible)
Categories: {enabled_sets}

The summary should:
1. Be motivating and personal.
2. Explain the range of difficulty they are tackling (e.g., if multiple levels are selected, mention they are building a broad foundation or bridging gaps).
3. Mention how this selection will help them achieve their goals.

Keep it under 40 words. Do not use placeholders.
"""

    try:
        response = model.generate_content(prompt)
        return response.text.strip()
    except Exception as e:
        print(f"Summary Agent Error: {e}")
        return f"Your journey continues with Level {level} focus on {enabled_sets}."
