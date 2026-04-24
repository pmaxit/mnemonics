#!/usr/bin/env python3
"""
Create thematic word sets for the Vocabulary table.

This script:
1. Fetches all words from the Vocabulary table
2. Classifies each word into thematic sets based on meaning keywords
3. Updates the setIds column with comma-separated set memberships
4. Tags SAT-appropriate words
5. Updates categories for SAT words to Level 1-6
"""

import mysql.connector
import os
import sys
import re

DB_HOST = "35.224.79.154"
DB_USER = "root"
DB_PASS = "Password123!"
DB_NAME = "mnemonics_db"


def get_db_connection():
    unix_socket = os.environ.get("INSTANCE_UNIX_SOCKET")
    if unix_socket:
        return mysql.connector.connect(
            unix_socket=unix_socket,
            user=DB_USER,
            password=DB_PASS,
            database=DB_NAME,
            connection_timeout=10
        )
    else:
        host = os.environ.get("DB_HOST", DB_HOST)
        port = int(os.environ.get("DB_PORT", 3306))
        return mysql.connector.connect(
            host=host,
            port=port,
            user=DB_USER,
            password=DB_PASS,
            database=DB_NAME,
            connection_timeout=10
        )


# ---------------------------------------------------------------------------
# Thematic set definitions
# Each set has keywords that are matched against the word's meaning.
# A word is added to a set if ANY of the keywords appear in its meaning.
# ---------------------------------------------------------------------------

THEMATIC_SETS = {
    "emotions": {
        "name": "Emotions & Feelings",
        "keywords": [
            "feeling", "emotion", "happy", "sad", "anger", "angry", "joy",
            "pleasure", "sorrow", "grief", "melancholy", "euphori", "delight",
            "despair", "anxiet", "fear", "dread", "contempt", "disgust",
            "resentment", "hostil", "bitter", "gloomy", "sullen", "somber",
            "cheerful", "elat", "ecsta", "misery", "anguish", "wistful",
            "nostalgic", "yearn", "longing", "passion", "ferv", "ardor",
            "zeal", "apathy", "indifferen", "dislike", "love", "hate",
            "envy", "jealous", "regret", "remorse", "shame", "pride",
            "humiliat", "displeasure", "misfortune", "lament", "mourn",
            "wrath", "fury", "rage", "serenity", "tranquil", "calm",
            "agitat", "distress", "torment", "bliss", "rapture",
        ],
    },
    "character": {
        "name": "Character & Personality",
        "keywords": [
            "personality", "character", "trait", "temperament", "disposition",
            "selfless", "generous", "generos", "kind", "benevolent",
            "compassion", "empathy", "sympathy", "altruist", "noble",
            "magnanimous", "humble", "modest", "arrogant", "proud",
            "vain", "egotist", "narciss", "stubborn", "obstinate",
            "sociable", "gregarious", "introvert", "extrovert", "shy",
            "timid", "bold", "brave", "courageous", "coward",
            "loyal", "faithf", "trustworth", "dependable", "reliable",
            "fickle", "capricious", "whimsical", "impulsive", "reckless",
            "patient", "tolerant", "intolerant", "pedantic", "meticulous",
            "lazy", "diligent", "industrious", "ambitious", "drive",
            "cunning", "shrewd", "naive", "innocent", "gullible",
            "stern", "austere", "frivolous", "serious", "solemn",
            "devious", "deceitful", "honest", "sincere", "virtuous",
            "stoic", "resilient", "tenacious", "persever",
            "fond of company", "sociable",
        ],
    },
    "speech": {
        "name": "Speech & Communication",
        "keywords": [
            "speak", "speech", "talk", "say", "voice", "verbal",
            "eloquen", "articulate", "loquacious", "taciturn", "reticent",
            "verbose", "wordy", "terse", "concise", "succinct",
            "rhetoric", "oratory", "discourse", "dialogue", "monologue",
            "pronounce", "utter", "declare", "proclaim", "assert",
            "whisper", "shout", "yell", "murmur", "mumble",
            "praise", "compliment", "flatter", "censure", "criticiz",
            "reprimand", "rebuke", "admonish", "chastise", "scold",
            "persuade", "convince", "dissuade", "exhort", "urge",
            "express", "communicate", "convey", "language", "word",
            "jargon", "slang", "idiom", "euphemism", "metaphor",
            "pompous", "grandiloquent", "bombastic", "long-winded",
            "opinions", "authoritative", "tirade", "harangue", "diatribe",
            "high-sounding", "rambling",
        ],
    },
    "power": {
        "name": "Power & Authority",
        "keywords": [
            "power", "authority", "control", "dominat", "command",
            "rule", "govern", "reign", "sovereign", "monarch",
            "tyrant", "despot", "autocrat", "dictator", "authoritarian",
            "oppress", "subjugat", "suppress", "subservien", "servile",
            "obedien", "deferen", "submit", "yield", "surrender",
            "rebel", "revolt", "resist", "defy", "disobey",
            "influenc", "sway", "manipulat", "coerce", "compel",
            "leader", "chief", "hierarch", "supremac", "hegemony",
            "military", "junta", "coup", "regime", "empire",
            "privilege", "entitl", "prerogative",
            "force", "deposing",
        ],
    },
    "criticism": {
        "name": "Criticism & Judgment",
        "keywords": [
            "criticiz", "critic", "judg", "evaluat", "assess",
            "condemn", "denounce", "censure", "castigat", "blame",
            "reproach", "rebuke", "reprimand", "admonish", "chastis",
            "scold", "berat", "objurgat", "lambast", "excoriate",
            "ridicule", "mock", "scorn", "deris", "sarcas",
            "cynical", "skeptic", "contempt", "disdain", "disparag",
            "slander", "defam", "libel", "malign", "vilify",
            "approve", "endorse", "commend", "laud", "extol",
            "accolade", "tribute", "honor", "acclaim",
            "fault", "flaw", "shortcoming", "reproof", "warning",
        ],
    },
    "change": {
        "name": "Change & Transformation",
        "keywords": [
            "change", "transform", "convert", "alter", "modify",
            "evolv", "develop", "grow", "progress", "advance",
            "decay", "declin", "deteriorat", "degrad", "erode",
            "renew", "restor", "reviv", "rejuvenat", "regenerat",
            "adapt", "adjust", "acclimate", "transition", "shift",
            "revolut", "reform", "innovat", "pioneer", "breakthrough",
            "temporary", "transient", "fleeting", "ephemeral", "passing",
            "permanent", "enduring", "lasting", "eternal", "perpetual",
            "fluctuat", "oscillat", "waver", "variate", "volatile",
            "metamorphos", "transmute", "mutate", "morph",
            "fledgling", "nascent", "embryonic", "incipient", "budding",
            "reappearance", "ancestor",
        ],
    },
    "intellect": {
        "name": "Intellect & Knowledge",
        "keywords": [
            "intellect", "intelligence", "smart", "clever", "brilliant",
            "wise", "wisdom", "sagacious", "prudent", "judicious",
            "knowledge", "learn", "educat", "scholar", "academic",
            "understand", "comprehen", "grasp", "perceiv", "discern",
            "think", "thought", "reason", "rational", "logic",
            "ignorant", "stupid", "foolish", "obtuse", "dull",
            "insight", "intuition", "foresight", "prescien", "clairvoyant",
            "cunning", "astute", "keen", "sharp", "penetrat",
            "confuse", "perplex", "baffle", "bewilder", "mystify",
            "curious", "inquisitive", "investigat", "explor", "inquir",
            "erudite", "literate", "well-read", "knowledgeable",
            "mental", "cognitive", "cerebral",
            "clear", "lucid",
        ],
    },
    "conflict": {
        "name": "Conflict & Opposition",
        "keywords": [
            "conflict", "fight", "battle", "war", "combat",
            "hostile", "aggressiv", "belligeren", "bellicos", "pugnacious",
            "quarrel", "dispute", "argument", "clash", "confront",
            "rival", "compet", "contest", "opponent", "adversar",
            "peace", "harmony", "reconcil", "truce", "armistice",
            "resist", "defy", "oppose", "rebel", "dissent",
            "attack", "assault", "invade", "siege", "ambush",
            "defend", "protect", "shield", "guard", "fortif",
            "provocat", "instigat", "incit", "agitat", "inflam",
            "troublesom", "unruly", "fractious", "contentious",
            "animosity", "enmity", "feud", "vendetta", "grudge",
            "eager to fight",
        ],
    },
    "morality": {
        "name": "Morality & Ethics",
        "keywords": [
            "moral", "ethic", "virtue", "virtuous", "righteous",
            "immoral", "unethical", "wicked", "evil", "sinful",
            "honest", "truthful", "integri", "honorable", "upright",
            "dishonest", "deceitful", "fraudulent", "corrupt", "deceptive",
            "just", "justice", "fair", "equitable", "impartial",
            "unjust", "unfair", "biased", "prejudic", "discriminat",
            "sacred", "holy", "profane", "blasphm", "sacrileg",
            "guilty", "innocent", "culpable", "blameless",
            "conscience", "scrupul", "principled",
            "sanctimonious", "hypocrit", "self-righteous",
            "wrongdoing", "complicit", "trustworth", "blameless",
            "desecrat", "violat", "profanity",
        ],
    },
    "abundance": {
        "name": "Abundance & Scarcity",
        "keywords": [
            "abundan", "plentiful", "copious", "profus", "lavish",
            "excess", "surplus", "overflow", "superfluous", "redundant",
            "scarc", "rare", "sparse", "meager", "scanty",
            "dearth", "lack", "shortage", "deficit", "paucity",
            "wealth", "rich", "opulent", "luxur", "affluent",
            "poverty", "poor", "destitut", "impoverish", "indigent",
            "frugal", "thrift", "economical", "parsimoni", "miserly",
            "extravagan", "prodigal", "wasteful", "squander", "splurge",
            "more words than", "excessively long",
        ],
    },
}

# ---------------------------------------------------------------------------
# SAT word selection criteria
# Words that are commonly tested on the SAT: intermediate difficulty,
# commonly used in academic contexts, and high-frequency vocabulary.
# We'll pick ~100 representative SAT words from the GRE pool.
# ---------------------------------------------------------------------------

SAT_KEYWORDS = [
    # High-frequency SAT words based on common SAT word lists
    "ambiguous", "analogy", "analy", "anomaly", "anticipat",
    "appease", "assert", "benevolent", "candid", "compel",
    "contempt", "contradict", "conven", "cynical", "debat",
    "defian", "deliberat", "diligen", "discern", "dismiss",
    "divers", "empathy", "endors", "evid", "exemplif",
    "exonerat", "feasibl", "formidabl", "frugal", "gratuit",
    "hypothe", "impartial", "implicat", "inadvert", "indiff",
    "inevitab", "innovat", "integ", "ironic", "juxtapos",
    "lucid", "notori", "nuanc", "objectiv", "obsolet",
    "paradox", "persever", "pragmat", "preceden", "prolif",
    "reclus", "redundan", "rejuvenat", "resilient", "rever",
    "scrutin", "superfic", "sustain", "tangib", "tenacious",
    "ubiquit", "undermn", "uniformi", "vener", "vigor",
    "volat", "zealous",
]

# Specific SAT word list — words known to appear on the SAT
SAT_WORD_LIST = [
    "lucid", "gregarious", "ubiquitous", "ephemeral", "altruistic",
    "pristine", "sagacious", "benevolent", "candid", "diligent",
    "eloquent", "frugal", "futile", "hackneyed", "impetuous",
    "lethargic", "mundane", "novel", "pragmatic", "resilient",
    "sporadic", "tenacious", "volatile", "zealous", "ambiguous",
    "concise", "cynical", "deter", "eclectic", "exemplify",
    "feasible", "hypothetical", "inevitable", "innovate", "ironic",
    "nostalgia", "obsolete", "paradox", "prevalent", "redundant",
    "scrutinize", "superficial", "tangible", "undermine", "versatile",
    "adversary", "advocate", "bolster", "berate", "circumvent",
    "complacent", "convergent", "despondent", "diminish", "divergent",
    "emulate", "erratic", "exasperate", "expedient", "fastidious",
    "formidable", "gratuitous", "idiosyncratic", "indifferent",
    "instigate", "juxtapose", "meticulous", "mitigate", "nonchalant",
    "notoriety", "nuance", "objective", "ostentatious", "penchant",
    "persevere", "plausible", "preclude", "prodigious", "proficient",
    "recluse", "repudiate", "reverence", "sanguine", "steadfast",
    "substantiate", "superfluous", "surpass", "surreptitious",
    "turbulent", "ubiquitous", "uniform", "venerate", "vigor",
    "appease", "animosity", "conundrum", "equitable", "prevail",
    "cohesive", "intrepid", "fledgling", "precipitate", "truncate",
    "summit", "meander", "precedent", "semblance", "frustrate",
    "discriminate", "contingent", "dispense", "retract", "evasive",
    "complicit", "stalwart",
]


def classify_word(word_row):
    """Classify a single word into thematic sets based on its meaning."""
    meaning = (word_row["meaning"] or "").lower()
    word = (word_row["word"] or "").lower()
    sets = set()

    # Always keep original setIds
    original = (word_row["setIds"] or "").strip()
    if original:
        for s in original.split(","):
            s = s.strip()
            if s:
                sets.add(s)

    # Check thematic sets
    for set_id, config in THEMATIC_SETS.items():
        for keyword in config["keywords"]:
            if keyword.lower() in meaning:
                sets.add(set_id)
                break

    # Check if this word should be in the SAT set
    if word in [w.lower() for w in SAT_WORD_LIST]:
        sets.add("sat")
    else:
        # Also check by keyword matching on the meaning
        for kw in SAT_KEYWORDS:
            if kw.lower() in meaning or kw.lower() in word:
                sets.add("sat")
                break

    return sets


def difficulty_to_level(difficulty):
    """Map difficulty to Level 1-6."""
    if not difficulty:
        return "Level 1"
    d = difficulty.strip()
    
    # CEFR Mapping
    if d == "A1" or d == "A2":
        return "Level 1"
    elif d == "B1":
        return "Level 2"
    elif d == "B2" or d == "B2+":
        return "Level 3"
    elif d == "C1" or d == "C1+":
        return "Level 4"
    elif d == "C2":
        return "Level 5"
    
    # Textual Mapping
    d_lower = d.lower()
    if "begin" in d_lower or "basic" in d_lower or "easy" in d_lower:
        return "Level 1"
    elif "element" in d_lower or "pre" in d_lower:
        return "Level 2"
    elif "intermed" in d_lower or "medium" in d_lower or "mid" in d_lower:
        return "Level 3"
    elif "upper" in d_lower:
        return "Level 4"
    elif "adv" in d_lower or "hard" in d_lower:
        return "Level 5"
    elif "prof" in d_lower or "expert" in d_lower or "master" in d_lower:
        return "Level 6"
        
    return "Level 3" # Default to intermediate if unknown


def main():
    print("Connecting to database...")
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    print("Fetching all vocabulary words...")
    cursor.execute("SELECT id, word, meaning, difficulty, category, setIds FROM Vocabulary ORDER BY id")
    words = cursor.fetchall()
    print(f"Found {len(words)} words.\n")

    # Classify each word
    updates = []
    set_counts = {}
    for w in words:
        new_sets = classify_word(w)
        new_setIds = ",".join(sorted(new_sets))

        # Update category based on difficulty
        new_category = difficulty_to_level(w["difficulty"])

        for s in new_sets:
            set_counts[s] = set_counts.get(s, 0) + 1

        if new_setIds != (w["setIds"] or "") or new_category != (w["category"] or ""):
            updates.append((new_setIds, new_category, w["id"], w["word"]))

    # Show summary
    print("=== Thematic Set Distribution ===")
    for set_id in sorted(set_counts.keys()):
        name = THEMATIC_SETS.get(set_id, {}).get("name", set_id)
        print(f"  {set_id:15s} ({name}): {set_counts[set_id]} words")

    print(f"\n{len(updates)} words need updating (setIds or category changes).")

    if not updates:
        print("No updates needed. Done!")
        cursor.close()
        conn.close()
        return

    # Show some sample updates
    print("\nSample updates (first 15):")
    for new_set, new_cat, wid, word in updates[:15]:
        print(f"  [{wid}] {word}: setIds={new_set}, category={new_cat}")

    confirm = input("\nApply these updates? (yes/no): ")
    if confirm.lower() not in ("y", "yes"):
        print("Cancelled.")
        cursor.close()
        conn.close()
        return

    print("\nApplying updates...")
    update_query = "UPDATE Vocabulary SET setIds = %s, category = %s WHERE id = %s"
    update_data = [(s, c, wid) for s, c, wid, _ in updates]

    try:
        cursor.executemany(update_query, update_data)
        conn.commit()
        print(f"Successfully updated {cursor.rowcount} words!")
    except mysql.connector.Error as err:
        print(f"Error: {err}")
        conn.rollback()

    # Verify
    print("\nVerifying final distribution...")
    cursor.execute("SELECT setIds FROM Vocabulary")
    final_counts = {}
    for row in cursor.fetchall():
        for s in (row["setIds"] or "").split(","):
            s = s.strip()
            if s:
                final_counts[s] = final_counts.get(s, 0) + 1

    print("\n=== Final Set Distribution ===")
    for set_id in sorted(final_counts.keys()):
        name = THEMATIC_SETS.get(set_id, {}).get("name", set_id)
        print(f"  {set_id:15s} ({name}): {final_counts[set_id]} words")

    cursor.execute("SELECT category, COUNT(*) as cnt FROM Vocabulary GROUP BY category ORDER BY category")
    print("\n=== Final Category Distribution ===")
    for r in cursor.fetchall():
        print(f"  {r['category']}: {r['cnt']} words")

    cursor.close()
    conn.close()
    print("\nDone!")


if __name__ == "__main__":
    main()
