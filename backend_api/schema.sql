-- PostgreSQL Schema for Mnemonics App

-- Vocabulary table
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
);

-- Word sets table
CREATE TABLE IF NOT EXISTS word_sets (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
    user_id VARCHAR(128) PRIMARY KEY,
    vocabulary_level VARCHAR(50) DEFAULT '1',
    learning_goal VARCHAR(100),
    has_completed_onboarding BOOLEAN DEFAULT FALSE,
    enabled_word_sets TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User notes table
CREATE TABLE IF NOT EXISTS user_notes (
    user_id VARCHAR(128) NOT NULL,
    word VARCHAR(255) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, word)
);

-- User learned words table
CREATE TABLE IF NOT EXISTS user_learned_words (
    user_id VARCHAR(128) NOT NULL,
    word VARCHAR(255) NOT NULL,
    is_learned BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, word)
);

-- User word progress table (for spaced repetition)
CREATE TABLE IF NOT EXISTS user_word_progress (
    user_id VARCHAR(128) NOT NULL,
    word VARCHAR(255) NOT NULL,
    progress_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, word)
);

-- Study plans table
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
);

-- Study plan days table
CREATE TABLE IF NOT EXISTS study_plan_days (
    id SERIAL PRIMARY KEY,
    plan_id INTEGER REFERENCES study_plans(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL,
    words JSONB,
    status VARCHAR(50) DEFAULT 'not_attempted',
    started_at TIMESTAMP,
    done_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_vocabulary_category ON vocabulary(category);
CREATE INDEX IF NOT EXISTS idx_vocabulary_set_ids ON vocabulary USING gin(set_ids);
CREATE INDEX IF NOT EXISTS idx_vocabulary_difficulty ON vocabulary(difficulty);
CREATE INDEX IF NOT EXISTS idx_user_progress_user_id ON user_word_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_learned_words_user ON user_learned_words(user_id);
CREATE INDEX IF NOT EXISTS idx_study_plans_user ON study_plans(user_id);
CREATE INDEX IF NOT EXISTS idx_study_plan_days_plan ON study_plan_days(plan_id);