"""
study_plan_agent.py
-------------------
Agentic workflow that uses Gemini to intelligently assign vocabulary words
across study plan days and persist the resulting plan to MySQL.
"""

import json
import os
import uuid
from datetime import date, timedelta
import google.generativeai as genai
import mysql.connector


# ---------------------------------------------------------------------------
# DB helpers (same connection logic as app.py)
# ---------------------------------------------------------------------------

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


# ---------------------------------------------------------------------------
# Agent entry point
# ---------------------------------------------------------------------------

def create_study_plan(
    user_id: str,
    total_words: int,
    num_days: int,
    words_per_day: int,
    title: str = None,
    start_date: date = None,
) -> dict:
    """
    Orchestrates the agentic workflow:
      1. Fetch word pool (exclude already-learned words).
      2. Call Gemini to distribute words intelligently across days.
      3. Persist StudyPlans + StudyPlanDays rows.
      4. Return a summary dict.

    Returns:
        {
          "plan_id": str,
          "title": str,
          "num_days": int,
          "words_per_day": int,
          "start_date": str (ISO),
          "days": [{"day_number": int, "words": [str, ...]}, ...]
        }
    """
    if start_date is None:
        start_date = date.today()

    if title is None:
        title = f"{total_words}-Word {num_days}-Day Study Plan"

    # ------------------------------------------------------------------
    # Step 1: Fetch word pool, excluding already-learned words
    # ------------------------------------------------------------------
    conn = _get_db()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT word, meaning, difficulty, category FROM Vocabulary")
    all_words = cursor.fetchall()

    cursor.execute(
        "SELECT word FROM UserLearnedWords WHERE user_id = %s AND is_learned = TRUE",
        (user_id,),
    )
    learned = {row["word"] for row in cursor.fetchall()}
    cursor.close()
    conn.close()

    available = [w for w in all_words if w["word"] not in learned]

    if len(available) < total_words:
        # Not enough fresh words — fall back to including learned words
        available = all_words

    # Trim to a manageable pool for the prompt (max 3× what we need to give
    # Gemini useful choice without blowing token limits)
    pool_size = min(len(available), total_words * 3)
    import random
    random.shuffle(available)
    word_pool = available[:pool_size]

    # ------------------------------------------------------------------
    # Step 2: Gemini agentic call
    # ------------------------------------------------------------------
    days_assignment = _call_gemini_agent(
        word_pool=word_pool,
        total_words=total_words,
        num_days=num_days,
        words_per_day=words_per_day,
    )

    # ------------------------------------------------------------------
    # Step 3: Persist to DB
    # ------------------------------------------------------------------
    plan_id = str(uuid.uuid4())
    conn = _get_db()
    cursor = conn.cursor()

    cursor.execute(
        """
        INSERT INTO StudyPlans
            (id, user_id, title, total_words, num_days, words_per_day, start_date, status)
        VALUES (%s, %s, %s, %s, %s, %s, %s, 'active')
        """,
        (plan_id, user_id, title, total_words, num_days, words_per_day, start_date.isoformat()),
    )

    for day_entry in days_assignment:
        cursor.execute(
            """
            INSERT INTO StudyPlanDays
                (plan_id, user_id, day_number, words, status)
            VALUES (%s, %s, %s, %s, 'not_attempted')
            """,
            (
                plan_id,
                user_id,
                day_entry["day_number"],
                json.dumps(day_entry["words"]),
            ),
        )

    conn.commit()
    cursor.close()
    conn.close()

    return {
        "id": plan_id,
        "user_id": user_id,
        "title": title,
        "total_words": total_words,
        "num_days": num_days,
        "words_per_day": words_per_day,
        "start_date": start_date.isoformat(),
        "days": days_assignment,
    }


# ---------------------------------------------------------------------------
# Gemini helper
# ---------------------------------------------------------------------------

def _call_gemini_agent(
    word_pool: list,
    total_words: int,
    num_days: int,
    words_per_day: int,
) -> list:
    """
    Calls Gemini to intelligently distribute `total_words` words across
    `num_days` days, with roughly `words_per_day` words each day.

    Returns a list of dicts: [{"day_number": 1, "words": ["word1", ...]}, ...]
    Falls back to sequential assignment if Gemini fails.
    """
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        # No API key — use deterministic fallback
        return _fallback_assignment(word_pool, total_words, num_days, words_per_day)

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel("gemini-2.5-flash-lite")

    # Slim down the pool representation to save tokens
    slim_pool = [
        {"word": w["word"], "difficulty": w.get("difficulty", "medium"), "category": w.get("category", "")}
        for w in word_pool
    ]

    prompt = f"""
You are a vocabulary study coach. Your task is to create a {num_days}-day study plan.

CONSTRAINTS:
- Select exactly {total_words} words total from the pool below.
- Distribute them across exactly {num_days} days.
- Each day should have approximately {words_per_day} words (last day may differ slightly).
- Mix difficulty levels: generally start with easier words in early days, harder words later.
- Mix categories within each day to keep learning interesting.

WORD POOL (JSON array):
{json.dumps(slim_pool)}

Return ONLY a valid JSON array — no markdown, no explanation. Format:
[
  {{"day_number": 1, "words": ["word1", "word2", ...]}},
  {{"day_number": 2, "words": ["wordA", "wordB", ...]}},
  ...
]
"""

    try:
        response = model.generate_content(
            prompt,
            generation_config=genai.types.GenerationConfig(
                response_mime_type="application/json"
            ),
        )
        raw = response.text.strip()
        days = json.loads(raw)
        # Validate structure
        if isinstance(days, list) and all("day_number" in d and "words" in d for d in days):
            return days
    except Exception as e:
        print(f"[StudyPlanAgent] Gemini error: {e}. Using fallback assignment.")

    return _fallback_assignment(word_pool, total_words, num_days, words_per_day)


def _fallback_assignment(word_pool, total_words, num_days, words_per_day):
    """Sequential fallback: just chunk the word pool evenly."""
    selected = [w["word"] for w in word_pool[:total_words]]
    days = []
    idx = 0
    for day_num in range(1, num_days + 1):
        chunk = selected[idx: idx + words_per_day]
        idx += words_per_day
        if chunk:
            days.append({"day_number": day_num, "words": chunk})
    return days
