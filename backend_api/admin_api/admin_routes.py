"""Admin API routes for dashboard statistics, activity logs, and notifications."""

from flask import Blueprint, jsonify, request
from datetime import datetime, timedelta
from ..app import get_db_connection
import psycopg2.extras
import json

admin_bp = Blueprint('admin', __name__, url_prefix='/api')


def _iso(value):
    """Convert datetime to ISO format string."""
    if value is None:
        return None
    if isinstance(value, datetime):
        return value.isoformat()
    return str(value)


@admin_bp.route('/stats', methods=['GET'])
def get_dashboard_stats():
    """Get dashboard statistics."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        
        # Total notifications
        cursor.execute("SELECT COUNT(*) as count FROM notifications")
        total_notifications = cursor.fetchone()['count']
        
        # Sent today
        cursor.execute("""
            SELECT COUNT(*) as count FROM notifications 
            WHERE sent_at >= CURRENT_DATE
        """)
        sent_today = cursor.fetchone()['count']
        
        # Pending notifications
        cursor.execute("""
            SELECT COUNT(*) as count FROM notifications 
            WHERE status = 'pending'
        """)
        pending_notifications = cursor.fetchone()['count']
        
        # Failed notifications
        cursor.execute("""
            SELECT COUNT(*) as count FROM notifications 
            WHERE status = 'failed'
        """)
        failed_notifications = cursor.fetchone()['count']
        
        # Active users (24h)
        cursor.execute("""
            SELECT COUNT(DISTINCT user_id) as count FROM user_word_progress 
            WHERE updated_at >= NOW() - INTERVAL '24 hours'
        """)
        active_users_today = cursor.fetchone()['count']
        
        # Pending suggestions
        cursor.execute("""
            SELECT COUNT(*) as count FROM agent_suggestions 
            WHERE applied = FALSE
        """)
        pending_suggestions = cursor.fetchone()['count']
        
        # Average user engagement
        cursor.execute("""
            SELECT AVG(session_count) as avg_sessions FROM (
                SELECT user_id, COUNT(*) as session_count 
                FROM user_word_progress 
                GROUP BY user_id
            ) as user_sessions
        """)
        avg_engagement_result = cursor.fetchone()
        average_user_engagement = float(avg_engagement_result['avg_sessions']) if avg_engagement_result['avg_sessions'] else 0.0
        
        cursor.close()
        conn.close()
        
        return jsonify({
            'totalNotifications': total_notifications,
            'sentToday': sent_today,
            'pendingNotifications': pending_notifications,
            'failedNotifications': failed_notifications,
            'activeUsersToday': active_users_today,
            'pendingSuggestions': pending_suggestions,
            'averageUserEngagement': average_user_engagement
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@admin_bp.route('/activity-logs', methods=['GET'])
def get_activity_logs():
    """Get user activity logs."""
    try:
        limit = int(request.args.get('limit', 50))
        offset = int(request.args.get('offset', 0))
        
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        
        cursor.execute("""
            SELECT * FROM (
                SELECT 
                    'word_progress' as source,
                    user_id,
                    'Word Progress Update' as activity_type,
                    CONCAT('Updated progress for word: ', word) as description,
                    updated_at as timestamp,
                    json_build_object('word', word, 'progress', progress_data) as context
                FROM user_word_progress
                UNION ALL
                SELECT 
                    'study_plan' as source,
                    user_id,
                    'Study Plan Action' as activity_type,
                    CASE 
                        WHEN status = 'done' THEN CONCAT('Completed study plan day ', day_number)
                        WHEN status = 'in_progress' THEN CONCAT('Started study plan day ', day_number)
                        ELSE CONCAT('Updated study plan day ', day_number)
                    END as description,
                    COALESCE(done_at, started_at, created_at) as timestamp,
                    json_build_object('day_number', day_number, 'status', status) as context
                FROM study_plan_days spd
                JOIN study_plans sp ON sp.id = spd.plan_id
                WHERE done_at IS NOT NULL OR started_at IS NOT NULL
                UNION ALL
                SELECT 
                    'learned_word' as source,
                    user_id,
                    'Word Learned' as activity_type,
                    CONCAT('Marked word as learned: ', word) as description,
                    updated_at as timestamp,
                    json_build_object('word', word, 'is_learned', is_learned) as context
                FROM user_learned_words
                WHERE is_learned = TRUE
                UNION ALL
                SELECT 
                    'note' as source,
                    user_id,
                    'Note Added' as activity_type,
                    CONCAT('Added note for word: ', word) as description,
                    updated_at as timestamp,
                    json_build_object('word', word) as context
                FROM user_notes
                WHERE notes IS NOT NULL AND notes != ''
            ) as activities
            ORDER BY timestamp DESC
            LIMIT %s OFFSET %s
        """, (limit, offset))
        
        logs = cursor.fetchall()
        cursor.close()
        conn.close()
        
        return jsonify({
            'logs': [{
                'id': f"{log['source']}_{log['user_id']}_{_iso(log['timestamp'])}",
                'userId': log['user_id'],
                'activityType': log['activity_type'],
                'description': log['description'],
                'timestamp': _iso(log['timestamp']),
                'context': log['context'] if log['context'] else {}
            } for log in logs]
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@admin_bp.route('/activity-logs/types', methods=['GET'])
def get_activity_log_types():
    """Get activity log type counts."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        
        cursor.execute("""
            SELECT activity_type, COUNT(*) as count FROM (
                SELECT 'Word Progress Update' as activity_type FROM user_word_progress
                UNION ALL
                SELECT 
                    CASE 
                        WHEN status = 'done' THEN 'Study Plan Completed'
                        WHEN status = 'in_progress' THEN 'Study Plan Started'
                        ELSE 'Study Plan Updated'
                    END as activity_type
                FROM study_plan_days spd
                JOIN study_plans sp ON sp.id = spd.plan_id
                WHERE done_at IS NOT NULL OR started_at IS NOT NULL
                UNION ALL
                SELECT 'Word Learned' as activity_type FROM user_learned_words WHERE is_learned = TRUE
                UNION ALL
                SELECT 'Note Added' as activity_type FROM user_notes WHERE notes IS NOT NULL AND notes != ''
            ) as activities
            GROUP BY activity_type
        """)
        
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        
        return jsonify({result['activity_type']: result['count'] for result in results})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@admin_bp.route('/notifications', methods=['GET'])
def get_notifications():
    """Get notifications with filtering."""
    try:
        limit = int(request.args.get('limit', 50))
        scheme_type = request.args.get('schemeType')
        status = request.args.get('status')
        
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        
        query = "SELECT * FROM notifications"
        params = []
        
        conditions = []
        if scheme_type:
            conditions.append("scheme_type = %s")
            params.append(scheme_type)
        if status:
            conditions.append("status = %s")
            params.append(status)
            
        if conditions:
            query += " WHERE " + " AND ".join(conditions)
            
        query += " ORDER BY created_at DESC LIMIT %s"
        params.append(limit)
        
        cursor.execute(query, params)
        notifications = cursor.fetchall()
        cursor.close()
        conn.close()
        
        return jsonify({
            'notifications': [{
                'id': str(notification['id']),
                'title': notification['title'],
                'body': notification['body'],
                'schemeType': notification['scheme_type'],
                'priority': notification['priority'],
                'status': notification['status'],
                'createdAt': _iso(notification['created_at']),
                'scheduledFor': _iso(notification['scheduled_for']),
                'sentAt': _iso(notification['sent_at']),
                'expiresAt': _iso(notification['expires_at']),
                'targetUserId': notification['target_user_id'],
                'targetUserSegment': notification['target_user_segment'],
                'agentReasoning': notification['agent_reasoning'],
                'metadata': notification['metadata'] if notification['metadata'] else {}
            } for notification in notifications]
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@admin_bp.route('/notifications', methods=['POST'])
def create_notification():
    """Create a new notification."""
    try:
        data = request.get_json()
        title = data.get('title')
        body = data.get('body')
        scheme_type = data.get('schemeType', 'general')
        priority = data.get('priority', 'medium')
        target_user_id = data.get('targetUserId')
        target_user_segment = data.get('targetUserSegment')
        
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        
        cursor.execute("""
            INSERT INTO notifications 
            (title, body, scheme_type, priority, target_user_id, target_user_segment)
            VALUES (%s, %s, %s, %s, %s, %s)
            RETURNING *
        """, (title, body, scheme_type, priority, target_user_id, target_user_segment))
        
        notification = cursor.fetchone()
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({
            'id': str(notification['id']),
            'title': notification['title'],
            'body': notification['body'],
            'schemeType': notification['scheme_type'],
            'priority': notification['priority'],
            'status': notification['status'],
            'createdAt': _iso(notification['created_at']),
            'scheduledFor': _iso(notification['scheduled_for']),
            'sentAt': _iso(notification['sent_at']),
            'expiresAt': _iso(notification['expires_at']),
            'targetUserId': notification['target_user_id'],
            'targetUserSegment': notification['target_user_segment'],
            'agentReasoning': notification['agent_reasoning'],
            'metadata': notification['metadata'] if notification['metadata'] else {}
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@admin_bp.route('/notifications/<notification_id>/send', methods=['POST'])
def send_notification(notification_id):
    """Send a notification."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        
        cursor.execute("""
            UPDATE notifications 
            SET status = 'sent', sent_at = NOW()
            WHERE id = %s
            RETURNING *
        """, (notification_id,))
        
        notification = cursor.fetchone()
        if not notification:
            cursor.close()
            conn.close()
            return jsonify({"error": "Notification not found"}), 404
            
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({
            'id': str(notification['id']),
            'status': 'sent',
            'sentAt': _iso(notification['sent_at'])
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@admin_bp.route('/suggestions', methods=['GET'])
def get_suggestions():
    """Get agent suggestions."""
    try:
        pending_only = request.args.get('pending') == 'true'
        
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        
        query = "SELECT * FROM agent_suggestions"
        if pending_only:
            query += " WHERE applied = FALSE"
        query += " ORDER BY created_at DESC"
        
        cursor.execute(query)
        suggestions = cursor.fetchall()
        cursor.close()
        conn.close()
        
        return jsonify({
            'suggestions': [{
                'id': str(suggestion['id']),
                'title': suggestion['title'],
                'body': suggestion['body'],
                'suggestedScheme': suggestion['suggested_scheme'],
                'priority': suggestion['priority'],
                'reasoning': suggestion['reasoning'],
                'confidence': float(suggestion['confidence']),
                'targetUserId': suggestion['target_user_id'],
                'targetUserSegment': suggestion['target_user_segment'],
                'createdAt': _iso(suggestion['created_at']),
                'applied': bool(suggestion['applied'])
            } for suggestion in suggestions]
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@admin_bp.route('/suggestions/<suggestion_id>/apply', methods=['POST'])
def apply_suggestion(suggestion_id):
    """Apply an agent suggestion."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Mark suggestion as applied
        cursor.execute("""
            UPDATE agent_suggestions 
            SET applied = TRUE 
            WHERE id = %s
        """, (suggestion_id,))
        
        # Create notification from suggestion
        cursor.execute("""
            INSERT INTO notifications (title, body, scheme_type, priority, target_user_id, target_user_segment, agent_reasoning)
            SELECT title, body, suggested_scheme, priority, target_user_id, target_user_segment, reasoning
            FROM agent_suggestions
            WHERE id = %s
        """, (suggestion_id,))
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({"status": "applied"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@admin_bp.route('/suggestions/<suggestion_id>/discard', methods=['POST'])
def discard_suggestion(suggestion_id):
    """Discard an agent suggestion."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute("""
            UPDATE agent_suggestions 
            SET applied = TRUE 
            WHERE id = %s
        """, (suggestion_id,))
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({"status": "discarded"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@admin_bp.route('/agent/analyze', methods=['POST'])
def trigger_agent_analysis():
    """Trigger agent analysis to generate suggestions."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        
        # Find users who haven't been active in 3+ days
        cursor.execute("""
            SELECT DISTINCT user_id FROM user_profiles up
            WHERE NOT EXISTS (
                SELECT 1 FROM user_word_progress uwp 
                WHERE uwp.user_id = up.user_id 
                AND uwp.updated_at >= NOW() - INTERVAL '3 days'
            )
            AND EXISTS (
                SELECT 1 FROM user_word_progress uwp2 
                WHERE uwp2.user_id = up.user_id
            )
        """)
        
        inactive_users = cursor.fetchall()
        
        # Find users who haven't completed any study plan in the last week
        cursor.execute("""
            SELECT DISTINCT sp.user_id FROM study_plans sp
            WHERE sp.user_id NOT IN (
                SELECT DISTINCT spd2.plan_id FROM study_plan_days spd2
                JOIN study_plans sp2 ON sp2.id = spd2.plan_id
                WHERE spd2.status = 'done' 
                AND spd2.done_at >= NOW() - INTERVAL '7 days'
            )
            AND EXISTS (
                SELECT 1 FROM study_plan_days spd3 
                WHERE spd3.plan_id = sp.id
            )
        """)
        
        neglected_users = cursor.fetchall()
        
        # Generate harsh suggestions for inactive users
        suggestions = []
        for user in inactive_users:
            user_id = user['user_id']
            
            # Get user's last activity
            cursor.execute("""
                SELECT MAX(updated_at) as last_activity FROM user_word_progress
                WHERE user_id = %s
            """, (user_id,))
            
            last_activity_result = cursor.fetchone()
            last_activity = last_activity_result['last_activity'] if last_activity_result else None
            
            if last_activity:
                days_inactive = (datetime.now() - last_activity).days
                
                # Create harsh suggestion
                title = f"URGENT: {days_inactive} Days of Inactivity!"
                body = "You've been absent from your studies for too long. Your GRE vocabulary progress is slipping away!"
                reasoning = f"This user hasn't studied in {days_inactive} days. Immediate intervention is needed to prevent total abandonment."
                
                cursor.execute("""
                    INSERT INTO agent_suggestions 
                    (title, body, suggested_scheme, priority, reasoning, confidence, target_user_id)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    RETURNING id
                """, (title, body, 'personalized', 'urgent', reasoning, 0.95, user_id))
                
                suggestion_id = cursor.fetchone()['id']
                suggestions.append({
                    'id': str(suggestion_id),
                    'title': title,
                    'body': body,
                    'suggestedScheme': 'personalized',
                    'priority': 'urgent',
                    'reasoning': reasoning,
                    'confidence': 0.95,
                    'targetUserId': user_id,
                    'createdAt': datetime.now().isoformat(),
                    'applied': False
                })
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({'suggestions': suggestions})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@admin_bp.route('/users', methods=['GET'])
def get_users():
    """Get user information and session data."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        
        # Get all users with their activity data
        cursor.execute("""
            SELECT 
                up.user_id,
                up.vocabulary_level,
                up.learning_goal,
                up.has_completed_onboarding,
                up.enabled_word_sets,
                up.created_at as profile_created_at,
                up.updated_at as profile_updated_at,
                COUNT(uwp.word) as words_studied,
                MAX(uwp.updated_at) as last_activity,
                COUNT(CASE WHEN ulw.is_learned THEN 1 END) as words_learned,
                COUNT(sp.id) as active_study_plans
            FROM user_profiles up
            LEFT JOIN user_word_progress uwp ON up.user_id = uwp.user_id
            LEFT JOIN user_learned_words ulw ON up.user_id = ulw.user_id
            LEFT JOIN study_plans sp ON up.user_id = sp.user_id AND sp.status = 'active'
            GROUP BY up.user_id, up.vocabulary_level, up.learning_goal, 
                     up.has_completed_onboarding, up.enabled_word_sets, 
                     up.created_at, up.updated_at
            ORDER BY up.created_at DESC
        """)
        
        users = cursor.fetchall()
        cursor.close()
        conn.close()
        
        # Process user data
        user_list = []
        for user in users:
            last_activity = user['last_activity']
            days_since_active = (datetime.now() - last_activity).days if last_activity else None
            
            # Determine if user is inactive (3+ days)
            is_inactive = days_since_active is not None and days_since_active >= 3
            
            user_list.append({
                'userId': user['user_id'],
                'vocabularyLevel': user['vocabulary_level'],
                'learningGoal': user['learning_goal'],
                'hasCompletedOnboarding': bool(user['has_completed_onboarding']),
                'enabledWordSets': user['enabled_word_sets'],
                'profileCreatedAt': _iso(user['profile_created_at']),
                'profileUpdatedAt': _iso(user['profile_updated_at']),
                'wordsStudied': user['words_studied'] or 0,
                'wordsLearned': user['words_learned'] or 0,
                'activeStudyPlans': user['active_study_plans'] or 0,
                'lastActivity': _iso(last_activity),
                'daysSinceActive': days_since_active,
                'isInactive': is_inactive,
                'status': 'inactive' if is_inactive else 'active'
            })
        
        return jsonify({'users': user_list})
    except Exception as e:
        return jsonify({"error": str(e)}), 500