import mysql.connector
import os

DB_HOST = "35.224.79.154"
DB_USER = "root"
DB_PASS = "Password123!"
DB_NAME = "mnemonics_db"

def get_db_connection():
    return mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
        connection_timeout=5
    )

def create_user_profiles_table():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        create_table_query = """
        CREATE TABLE IF NOT EXISTS UserProfiles (
            user_id VARCHAR(128) PRIMARY KEY,
            vocabulary_level INT DEFAULT 1,
            learning_goal VARCHAR(100),
            has_completed_onboarding BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        );
        """
        
        cursor.execute(create_table_query)
        conn.commit()
        print("UserProfiles table created successfully (or already exists).")
        
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Error creating table: {e}")

if __name__ == "__main__":
    create_user_profiles_table()
