-- Study Session Feature Schema

CREATE TABLE IF NOT EXISTS StudyPlans (
    id            VARCHAR(36)  PRIMARY KEY,
    user_id       VARCHAR(128) NOT NULL,
    title         VARCHAR(255),
    total_words   INT NOT NULL,
    num_days      INT NOT NULL,
    words_per_day INT NOT NULL,
    start_date    DATE NOT NULL,
    status        ENUM('active','completed','abandoned') DEFAULT 'active',
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_study_plans_user (user_id)
);

CREATE TABLE IF NOT EXISTS StudyPlanDays (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    plan_id    VARCHAR(36)  NOT NULL,
    user_id    VARCHAR(128) NOT NULL,
    day_number INT NOT NULL,
    words      JSON NOT NULL,
    status     ENUM('not_attempted','in_progress','done') DEFAULT 'not_attempted',
    started_at TIMESTAMP NULL,
    done_at    TIMESTAMP NULL,
    FOREIGN KEY (plan_id) REFERENCES StudyPlans(id) ON DELETE CASCADE,
    UNIQUE KEY uq_plan_day (plan_id, day_number),
    INDEX idx_study_plan_days_user (user_id, plan_id)
);
