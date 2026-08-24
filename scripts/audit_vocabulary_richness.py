#!/usr/bin/env python3
"""
Audit content richness across the live `vocabulary` table.

Runs from a machine with Postgres access (this sandbox is on a locked-down
network and cannot reach the Railway DB directly, so this script is meant to
be run by hand): reports per-field completion %, flags likely-junk entries,
duplicate words, and the stale placeholder video URL that got imported into
every row.

Usage:
    DATABASE_URL=postgres://... python3 scripts/audit_vocabulary_richness.py
    # or rely on DB_HOST/DB_PORT/DB_NAME/DB_USER/DB_PASSWORD env vars
"""
from __future__ import annotations

import json
import os
from collections import Counter

import psycopg2
import psycopg2.extras


def get_connection():
    database_url = os.getenv("DATABASE_URL")
    if database_url:
        return psycopg2.connect(database_url)
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "5432")),
        database=os.getenv("DB_NAME", "railway"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD", ""),
    )


JUNK_PHRASES = (
    "is not a recognized word",
    "not a standard english word",
    "not an established etymological",
    "is not a real word",
)

TEXT_FIELDS = [
    "mnemonic",
    "example",
    "synonyms",
    "antonyms",
    "ai_mnemonic",
    "ai_insights",
    "definition",
    "phrases",
    "example_sentences",
    "image_url",
]


def main() -> None:
    conn = get_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cur.execute("SELECT * FROM vocabulary")
    rows = cur.fetchall()
    total = len(rows)
    print(f"Total words in vocabulary table: {total}\n")

    counts = Counter()
    videos = Counter()
    words_seen = Counter()
    junk_words = []
    no_phrases = []
    no_examples = []
    no_synonyms = []

    for r in rows:
        word = (r.get("word") or "").strip()
        words_seen[word.lower()] += 1
        for field in TEXT_FIELDS:
            v = r.get(field)
            if v not in (None, "", "[]", "null"):
                counts[field] += 1

        videos[(r.get("video_url") or "").strip()] += 1

        ai_insights = (r.get("ai_insights") or "").lower()
        if any(p in ai_insights for p in JUNK_PHRASES):
            junk_words.append(word)

        if not r.get("phrases") or r["phrases"] == "[]":
            no_phrases.append(word)
        if not r.get("example_sentences") or r["example_sentences"] == "[]":
            no_examples.append(word)
        if not r.get("synonyms"):
            no_synonyms.append(word)

    print("Field completion:")
    for field in TEXT_FIELDS:
        pct = counts[field] * 100 // total if total else 0
        print(f"  {field:<20} {counts[field]:>5}/{total} ({pct}%)")

    print("\nDuplicate words:")
    dupes = {w: c for w, c in words_seen.items() if c > 1}
    print(f"  {len(dupes)} duplicated word(s)" if dupes else "  none")
    for w, c in list(dupes.items())[:20]:
        print(f"   - {w} x{c}")

    print("\nDistinct video_url values (all rows sharing one URL = fake placeholder):")
    print(f"  {len(videos)} distinct value(s)")
    for url, c in videos.most_common(3):
        print(f"   - {c:>5}x  {url[:90]}")

    print(f"\nSuspected junk/hallucinated words (ai_insights admits word doesn't exist): {len(junk_words)}")
    for w in junk_words[:20]:
        print(f"   - {w}")

    print(f"\nWords missing 'phrases' (short collocations): {len(no_phrases)}/{total}")
    print(f"Words missing 'example_sentences': {len(no_examples)}/{total}")
    print(f"Words missing 'synonyms' (flat column): {len(no_synonyms)}/{total}")

    with open("output/audit_missing_words.json", "w") as f:
        json.dump(
            {
                "no_phrases": no_phrases,
                "no_examples": no_examples,
                "no_synonyms": no_synonyms,
                "junk_words": junk_words,
                "duplicates": dupes,
            },
            f,
            indent=2,
        )
    print("\nWrote full word lists to output/audit_missing_words.json")

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
