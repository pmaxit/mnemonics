import mysql.connector
import os
import sys

# Database configuration - matching app.py
DB_HOST = "35.224.79.154"
DB_USER = "root"
DB_PASS = "Password123!"
DB_NAME = "mnemonics_db"

def get_db_connection():
    try:
        unix_socket = os.environ.get("INSTANCE_UNIX_SOCKET")
        if unix_socket:
            return mysql.connector.connect(
                unix_socket=unix_socket,
                user=DB_USER,
                password=DB_PASS,
                database=DB_NAME,
                connection_timeout=5
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
                connection_timeout=5
            )
    except mysql.connector.Error as err:
        print(f"Error connecting to MySQL: {err}")
        print("If running from Cloud Shell, make sure to add your Cloud Shell IP to the Cloud SQL Authorized Networks, or use the Cloud SQL Auth Proxy.")
        sys.exit(1)

# Recommended mapping logic
# Modify this mapping based on the actual distinct difficulties in your database.
DIFFICULTY_TO_LEVEL_MAPPING = {
    "Beginner": "Level 1",
    "Elementary": "Level 2",
    "Pre-Intermediate": "Level 2",
    "Intermediate": "Level 3",
    "Upper-Intermediate": "Level 4",
    "Advanced": "Level 5",
    "Proficient": "Level 6",
    "Expert": "Level 6",
    # Add any other specific difficulties your DB has here
}

def map_difficulty_to_level(difficulty):
    if not difficulty:
        return "Level 1" # Default fallback
    
    # Try exact match
    if difficulty in DIFFICULTY_TO_LEVEL_MAPPING:
        return DIFFICULTY_TO_LEVEL_MAPPING[difficulty]
    
    # Fallback to keyword matching if it's a slightly different string
    diff_lower = difficulty.lower()
    if "begin" in diff_lower or "basic" in diff_lower or "easy" in diff_lower:
        return "Level 1"
    elif "element" in diff_lower or "pre" in diff_lower:
        return "Level 2"
    elif "upper" in diff_lower:
        return "Level 4"
    elif "intermed" in diff_lower or "medium" in diff_lower or "mid" in diff_lower:
        return "Level 3"
    elif "adv" in diff_lower or "hard" in diff_lower:
        return "Level 5"
    elif "prof" in diff_lower or "expert" in diff_lower or "master" in diff_lower:
        return "Level 6"
    else:
        # Default if we can't figure it out
        print(f"Warning: Unknown difficulty '{difficulty}', defaulting to Level 1")
        return "Level 1"

def main():
    print("Connecting to database...")
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    print("Fetching distinct difficulty values...")
    cursor.execute("SELECT DISTINCT difficulty FROM Vocabulary")
    distinct_difficulties = [row['difficulty'] for row in cursor.fetchall()]
    
    print(f"Found {len(distinct_difficulties)} distinct difficulty levels: {distinct_difficulties}")
    
    # Show the user the proposed mapping before executing
    print("\nProposed Mapping:")
    updates_needed = False
    for diff in distinct_difficulties:
        level = map_difficulty_to_level(diff)
        print(f"  '{diff}' -> '{level}'")
        updates_needed = True
        
    if not updates_needed:
        print("No vocabulary words found to update.")
        return

    confirm = input("\nDo you want to apply these category updates to the database? (yes/no): ")
    if confirm.lower() not in ['y', 'yes']:
        print("Update cancelled.")
        cursor.close()
        conn.close()
        return

    print("\nUpdating categories...")
    # Update logic
    # Fetch all records to do individual updates, or we could do a batch update
    cursor.execute("SELECT id, difficulty, category FROM Vocabulary")
    words = cursor.fetchall()
    
    update_query = "UPDATE Vocabulary SET category = %s WHERE id = %s"
    update_data = []
    
    for word in words:
        new_category = map_difficulty_to_level(word['difficulty'])
        # Only update if the category is actually changing
        if word['category'] != new_category:
            update_data.append((new_category, word['id']))
            
    if update_data:
        try:
            cursor.executemany(update_query, update_data)
            conn.commit()
            print(f"Successfully updated {cursor.rowcount} words to Levels 1-6.")
        except mysql.connector.Error as err:
            print(f"Error updating database: {err}")
            conn.rollback()
    else:
        print("All words are already assigned to the correct Level categories. No updates made.")

    cursor.close()
    conn.close()
    print("Done!")

if __name__ == "__main__":
    main()
