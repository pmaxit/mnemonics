import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'activity_log_service.dart';
import 'notification_service.dart';

/// AI Agent that reads activity logs and suggests notifications to
/// keep users efficient in their study plans.
///
/// The agent analyzes patterns in user activity (missed sessions,
/// completed milestones, streaks at risk, etc.) and generates
/// actionable notification suggestions.
class NotificationAgentService {
  final String _apiKey;
  final String _model;
  final http.Client _client;

  NotificationAgentService({
    required String apiKey,
    String model = 'google/gemma-4-12b-instruct',
    http.Client? client,
  })  : _apiKey = apiKey,
        _model = model,
        _client = client ?? http.Client();

  /// Analyze activity logs and return suggested notifications.
  Future<List<AgentSuggestion>> analyzeActivityLogs(
    ActivityLogService logService,
    NotificationService notificationService,
  ) async {
    final logs = logService.getRecent(limit: 50);
    final existingSuggestions =
        notificationService.getPendingSuggestions();

    if (logs.isEmpty) {
      return [
        AgentSuggestion(
          id: 'fallback-empty-logs',
          title: '📊 No recent activity detected',
          body: 'Users have no recent activity. Consider sending a general onboarding or re-engagement notification.',
          suggestedScheme: NotificationSchemeType.general,
          priority: NotificationPriority.low,
          reasoning: 'Activity log is empty. Users may need re-engagement.',
          confidence: 0.5,
        ),
      ];
    }

    if (_apiKey.isEmpty) {
      return _ruleBasedSuggestions(logs, existingSuggestions);
    }

    try {
      return await _aiBasedSuggestions(logs, existingSuggestions);
    } catch (e) {
      log('AI agent error, falling back to rule-based: $e');
      return _ruleBasedSuggestions(logs, existingSuggestions);
    }
  }

  /// Use the AI model for intelligent suggestions.
  Future<List<AgentSuggestion>> _aiBasedSuggestions(
    List<ActivityLogEntry> logs,
    List<AgentSuggestion> existingSuggestions,
  ) async {
    final logsSummary = logs.map((l) {
      return '- ${l.timestamp.toIso8601String()} | user=${l.userId} | type=${l.activityType} | desc=${l.description}';
    }).join('\n');

    final prompt = '''
You are an intelligent notification agent for a vocabulary learning app called "Mnemonics".
Your goal is to help users stay efficient in their study plans by analyzing their activity logs
and suggesting timely, personalized notifications.

Below is the recent activity log. Analyze it and suggest 1-3 notifications that would help users
stay on track with their studies.

For each suggestion, provide:
1. title - A short, catchy title (max 60 chars)
2. body - The notification message (max 200 chars)
3. schemeType - One of: "personalized" (for a specific user), "general" (for all users), "custom"
4. priority - One of: "low", "medium", "high", "urgent"
5. targetUserId - The user ID if personalized, or null for general
6. targetUserSegment - Segment description (e.g. "at_risk", "streak", "new_users")
7. reasoning - Explain why this notification would help the user
8. confidence - A number 0.0-1.0 indicating how confident you are this is useful

Activity Logs:
$logsSummary

Return ONLY a valid JSON array with NO markdown formatting:
[
  {
    "title": "...",
    "body": "...",
    "schemeType": "personalized|general|custom",
    "priority": "low|medium|high|urgent",
    "targetUserId": "user_id or null",
    "targetUserSegment": "segment or null",
    "reasoning": "...",
    "confidence": 0.0-1.0
  }
]
''';

    final response = await _callOpenRouter(prompt);
    return _parseAiSuggestions(response);
  }

  Future<String> _callOpenRouter(String prompt) async {
    const baseUrl = 'https://openrouter.ai/api/v1';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
      'HTTP-Referer': 'https://mnemonics-admin.app',
      'X-Title': 'Mnemonics Admin Dashboard',
    };

    final body = jsonEncode({
      'model': _model,
      'messages': [
        {'role': 'system', 'content': 'You are a helpful notification agent that outputs JSON.'},
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.3,
      'response_format': {'type': 'json_object'},
    });

    final response = await _client.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('API error: ${response.statusCode}');
    }
  }

  List<AgentSuggestion> _parseAiSuggestions(String response) {
    try {
      var cleaned = response.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceFirst(RegExp(r'^```json?\s*'), '');
        cleaned = cleaned.replaceFirst(RegExp(r'\s*```$'), '');
      }
      final data = jsonDecode(cleaned);
      final list = data is List ? data : [data];
      return list.map((item) {
        return AgentSuggestion(
          id: 'ai-${DateTime.now().millisecondsSinceEpoch}-${_simpleHash(jsonEncode(item))}',
          title: item['title'] ?? 'Notification',
          body: item['body'] ?? '',
          suggestedScheme: _parseSchemeType(item['schemeType']),
          priority: _parsePriority(item['priority']),
          reasoning: item['reasoning'] ?? '',
          confidence: (item['confidence'] as num?)?.toDouble() ?? 0.5,
          targetUserId: item['targetUserId'] as String?,
          targetUserSegment: item['targetUserSegment'] as String?,
        );
      }).toList();
    } catch (e) {
      log('Failed to parse AI suggestions: $e');
      return _fallbackGenericSuggestions();
    }
  }

  /// Rule-based analysis when AI is not available.
  List<AgentSuggestion> _ruleBasedSuggestions(
    List<ActivityLogEntry> logs,
    List<AgentSuggestion> existingSuggestions,
  ) {
    final suggestions = <AgentSuggestion>[];
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // Extract user activity summary
    final userActivity = <String, List<ActivityLogEntry>>{};
    for (final log in logs) {
      userActivity.putIfAbsent(log.userId, () => []);
      userActivity[log.userId]!.add(log);
    }

    for (final entry in userActivity.entries) {
      final userId = entry.key;
      final userLogs = entry.value;
      final activityTypes = userLogs.map((l) => l.activityType).toSet();

      // 1. Users who completed a study session recently - encourage next steps
      if (activityTypes.contains('session_completed')) {
        final lastSession = userLogs
            .where((l) => l.activityType == 'session_completed')
            .first;
        final existingForUser = existingSuggestions
            .where((s) => s.targetUserId == userId);
        if (existingForUser.isEmpty &&
            !lastSession.timestamp.isBefore(todayStart)) {
          suggestions.add(AgentSuggestion(
            id: 'rule-session-$userId',
            title: '🌟 Great session! Ready for more?',
            body: 'You completed a study session today. Try reviewing 5 more words to boost retention!',
            suggestedScheme: NotificationSchemeType.personalized,
            priority: NotificationPriority.medium,
            reasoning:
                'User completed a session today. Capitalize on momentum for additional review.',
            confidence: 0.75,
            targetUserId: userId,
            targetUserSegment: 'active',
          ));
        }
      }

      // 2. Users who missed a session - re-engagement needed
      if (activityTypes.contains('session_missed') ||
          activityTypes.contains('streak_ended')) {
        suggestions.add(AgentSuggestion(
          id: 'rule-missed-$userId',
          title: '⏰ Don\'t lose your progress!',
          body: 'You missed yesterday\'s session. Start with just 5 minutes to get back on track.',
          suggestedScheme: NotificationSchemeType.personalized,
          priority: NotificationPriority.high,
          reasoning:
              'User missed a session and may be losing motivation. Low-barrier re-engagement.',
          confidence: 0.85,
          targetUserId: userId,
          targetUserSegment: 'at_risk',
        ));
      }

      // 3. Users with streak milestones - celebrate and encourage
      for (final log in userLogs) {
        if (log.activityType == 'streak_milestone') {
          final streakDays =
              log.context['streak']?.toString() ?? '7';
          final streakCount = int.tryParse(streakDays) ?? 7;
          suggestions.add(AgentSuggestion(
            id: 'rule-streak-${log.id}',
            title: '🔥 Amazing streak! Keep it burning!',
            body:
                'You reached $streakDays days! Can you make it to ${streakCount + 7} next?',
            suggestedScheme: NotificationSchemeType.personalized,
            priority: NotificationPriority.high,
            reasoning:
                'User achieved a streak milestone. Positive reinforcement increases retention.',
            confidence: 0.9,
            targetUserId: userId,
            targetUserSegment: 'streak',
          ));
          break;
        }
      }

      // 4. Words due for review
      if (activityTypes.contains('words_due')) {
        suggestions.add(AgentSuggestion(
          id: 'rule-due-$userId',
          title: '📚 Words waiting for review!',
          body: 'Spaced repetition words are due. A quick session will strengthen your memory.',
          suggestedScheme: NotificationSchemeType.personalized,
          priority: NotificationPriority.medium,
          reasoning:
              'User has words due for spaced repetition review. Timely reminder improves retention curve.',
          confidence: 0.8,
          targetUserId: userId,
          targetUserSegment: 'due_review',
        ));
      }
    }

    // 5. General notification - no recent activity
    final recentActivityCount =
        logs.where((l) => l.timestamp.isAfter(todayStart)).length;
    if (recentActivityCount < 3) {
      suggestions.add(AgentSuggestion(
        id: 'rule-general-engagement',
        title: '🌱 Nurture your vocabulary garden',
        body: 'A 10-minute study session today keeps forgetfulness away. Your words are waiting!',
        suggestedScheme: NotificationSchemeType.general,
        priority: NotificationPriority.low,
        reasoning:
            'Overall activity is low today. A general reminder may boost engagement across users.',
        confidence: 0.6,
        targetUserSegment: 'all_users',
      ));
    }

    // 6. Check for study plan completion
    final planCompletions =
        logs.where((l) => l.activityType == 'plan_day_completed').toList();
    if (planCompletions.length >= 3) {
      suggestions.add(AgentSuggestion(
        id: 'rule-plan-progress',
        title: '🎯 Consistent progress!',
        body: 'You\'ve completed ${planCompletions.length} study plan days. You\'re building a powerful habit!',
        suggestedScheme: NotificationSchemeType.general,
        priority: NotificationPriority.medium,
        reasoning:
            'Multiple users are progressing through their study plans. Reinforce this positive behavior.',
        confidence: 0.7,
        targetUserSegment: 'plan_active',
      ));
    }

    return suggestions;
  }

  List<AgentSuggestion> _fallbackGenericSuggestions() {
    return [
      AgentSuggestion(
        id: 'fallback-generic',
        title: '📚 Time for your daily vocabulary fix!',
        body: 'Learning a few words each day adds up. Open the app and learn something new!',
        suggestedScheme: NotificationSchemeType.general,
        priority: NotificationPriority.low,
        reasoning: 'Generic engagement reminder when AI analysis fails.',
        confidence: 0.4,
      ),
    ];
  }

  NotificationSchemeType _parseSchemeType(dynamic value) {
    if (value is String) {
      if (value == 'personalized') return NotificationSchemeType.personalized;
      if (value == 'general') return NotificationSchemeType.general;
      if (value == 'custom') return NotificationSchemeType.custom;
    }
    return NotificationSchemeType.general;
  }

  NotificationPriority _parsePriority(dynamic value) {
    if (value is String) {
      if (value == 'low') return NotificationPriority.low;
      if (value == 'medium') return NotificationPriority.medium;
      if (value == 'high') return NotificationPriority.high;
      if (value == 'urgent') return NotificationPriority.urgent;
    }
    return NotificationPriority.medium;
  }

  String _simpleHash(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash) + input.codeUnitAt(i);
      hash = hash & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0').substring(0, 8);
  }

  void dispose() {
    _client.close();
  }
}