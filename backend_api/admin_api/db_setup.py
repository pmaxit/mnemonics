"""Database setup for admin dashboard tables."""

def create_admin_tables(cursor):
    """Create tables needed for the admin dashboard."""
    
    # Notifications table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS notifications (
            id SERIAL PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            body TEXT NOT NULL,
            scheme_type VARCHAR(50) DEFAULT 'general',
            priority VARCHAR(50) DEFAULT 'medium',
            status VARCHAR(50) DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            scheduled_for TIMESTAMP,
            sent_at TIMESTAMP,
            expires_at TIMESTAMP,
            target_user_id VARCHAR(128),
            target_user_segment VARCHAR(100),
            agent_reasoning TEXT,
            metadata JSONB
        )
    """)
    
    # Agent suggestions table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS agent_suggestions (
            id SERIAL PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            body TEXT NOT NULL,
            suggested_scheme VARCHAR(50) DEFAULT 'general',
            priority VARCHAR(50) DEFAULT 'medium',
            reasoning TEXT,
            confidence NUMERIC(3,2) DEFAULT 0.5,
            target_user_id VARCHAR(128),
            target_user_segment VARCHAR(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            applied BOOLEAN DEFAULT FALSE
        )
    """)
    
    # Create indexes for better performance
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_notifications_status 
        ON notifications(status)
    """)
    
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_notifications_target_user 
        ON notifications(target_user_id)
    """)
    
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_suggestions_applied 
        ON agent_suggestions(applied)
    """)
    
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_suggestions_target_user 
        ON agent_suggestions(target_user_id)
    """)