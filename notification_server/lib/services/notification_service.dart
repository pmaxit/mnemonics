import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

/// In-memory store with file persistence for notifications.
/// In production, replace with Firebase Cloud Messaging or similar.
class NotificationService {
  final List<AppNotification> _notifications = [];
  final List<AgentSuggestion> _suggestions = [];
  final String? _persistencePath;
  final _uuid = const Uuid();

  NotificationService({String? persistencePath})
      : _persistencePath = persistencePath {
    if (_persistencePath != null) {
      _load();
    }
  }

  void _load() {
    try {
      final file = File('$_persistencePath/notifications.jsonl');
      if (file.existsSync()) {
        for (final line in file.readAsLinesSync()) {
          if (line.trim().isNotEmpty) {
            _notifications.add(
              AppNotification.fromJson(
                jsonDecode(line) as Map<String, dynamic>,
              ),
            );
          }
        }
      }
      final sugFile = File('$_persistencePath/suggestions.jsonl');
      if (sugFile.existsSync()) {
        for (final line in sugFile.readAsLinesSync()) {
          if (line.trim().isNotEmpty) {
            _suggestions.add(
              AgentSuggestion.fromJson(
                jsonDecode(line) as Map<String, dynamic>,
              ),
            );
          }
        }
      }
    } catch (_) {}
  }

  void _persistNotifications() {
    if (_persistencePath == null) return;
    final dirPath = _persistencePath;
    try {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('$dirPath/notifications.jsonl').writeAsStringSync(
        _notifications.map((e) => jsonEncode(e.toJson())).join('\n'),
      );
    } catch (_) {}
  }

  void _persistSuggestions() {
    if (_persistencePath == null) return;
    final dirPath = _persistencePath;
    try {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('$dirPath/suggestions.jsonl').writeAsStringSync(
        _suggestions.map((e) => jsonEncode(e.toJson())).join('\n'),
      );
    } catch (_) {}
  }

  AppNotification createNotification({
    required String title,
    required String body,
    required NotificationSchemeType schemeType,
    NotificationPriority priority = NotificationPriority.medium,
    DateTime? scheduledFor,
    DateTime? expiresAt,
    String? targetUserId,
    String? targetUserSegment,
    String? agentReasoning,
    Map<String, dynamic> metadata = const {},
  }) {
    final notification = AppNotification(
      id: _uuid.v4(),
      title: title,
      body: body,
      schemeType: schemeType,
      priority: priority,
      status: NotificationDeliveryStatus.pending,
      scheduledFor: scheduledFor,
      expiresAt: expiresAt,
      targetUserId: targetUserId,
      targetUserSegment: targetUserSegment,
      agentReasoning: agentReasoning,
      metadata: metadata,
    );
    _notifications.insert(0, notification);
    _persistNotifications();
    return notification;
  }

  /// Mark notification as sent and optionally set the sent time.
  AppNotification sendNotification(String notificationId) {
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx == -1) throw Exception('Notification not found');
    _notifications[idx] = _notifications[idx].copyWith(
      status: NotificationDeliveryStatus.sent,
      sentAt: DateTime.now(),
    );
    _persistNotifications();
    return _notifications[idx];
  }

  AgentSuggestion addSuggestion({
    required String title,
    required String body,
    required NotificationSchemeType suggestedScheme,
    NotificationPriority priority = NotificationPriority.medium,
    required String reasoning,
    double confidence = 0.5,
    String? targetUserId,
    String? targetUserSegment,
  }) {
    final suggestion = AgentSuggestion(
      id: _uuid.v4(),
      title: title,
      body: body,
      suggestedScheme: suggestedScheme,
      priority: priority,
      reasoning: reasoning,
      confidence: confidence,
      targetUserId: targetUserId,
      targetUserSegment: targetUserSegment,
    );
    _suggestions.insert(0, suggestion);
    _persistSuggestions();
    return suggestion;
  }

  /// Apply a suggestion by creating a notification from it.
  AppNotification applySuggestion(String suggestionId) {
    final idx = _suggestions.indexWhere((s) => s.id == suggestionId);
    if (idx == -1) throw Exception('Suggestion not found');
    final sug = _suggestions[idx];
    final notification = createNotification(
      title: sug.title,
      body: sug.body,
      schemeType: sug.suggestedScheme,
      priority: sug.priority,
      targetUserId: sug.targetUserId,
      targetUserSegment: sug.targetUserSegment,
      agentReasoning: sug.reasoning,
      metadata: {'fromSuggestionId': sug.id},
    );
    _suggestions[idx] = AgentSuggestion(
      id: sug.id,
      title: sug.title,
      body: sug.body,
      suggestedScheme: sug.suggestedScheme,
      priority: sug.priority,
      reasoning: sug.reasoning,
      confidence: sug.confidence,
      targetUserId: sug.targetUserId,
      targetUserSegment: sug.targetUserSegment,
      createdAt: sug.createdAt,
      applied: true,
    );
    _persistSuggestions();
    return notification;
  }

  void discardSuggestion(String suggestionId) {
    _suggestions.removeWhere((s) => s.id == suggestionId);
    _persistSuggestions();
  }

  List<AppNotification> getNotifications({
    int limit = 50,
    int offset = 0,
    NotificationSchemeType? schemeFilter,
    NotificationDeliveryStatus? statusFilter,
  }) {
    var result = _notifications;
    if (schemeFilter != null) {
      result = result.where((n) => n.schemeType == schemeFilter).toList();
    }
    if (statusFilter != null) {
      result = result.where((n) => n.status == statusFilter).toList();
    }
    return result.skip(offset).take(limit).toList();
  }

  List<AgentSuggestion> getPendingSuggestions() {
    return _suggestions.where((s) => !s.applied).toList();
  }

  List<AgentSuggestion> getAllSuggestions({int limit = 50}) {
    return _suggestions.take(limit).toList();
  }

  DashboardStats getStats(int activeUsersToday) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final sentToday = _notifications
        .where((n) =>
            n.sentAt != null && n.sentAt!.isAfter(todayStart))
        .length;
    return DashboardStats(
      totalNotifications: _notifications.length,
      sentToday: sentToday,
      pendingNotifications:
          _notifications.where((n) => n.status == NotificationDeliveryStatus.pending).length,
      failedNotifications:
          _notifications.where((n) => n.status == NotificationDeliveryStatus.failed).length,
      activeUsersToday: activeUsersToday,
      pendingSuggestions: _suggestions.where((s) => !s.applied).length,
    );
  }

  /// Seed with demo data.
  void seedDemoData(Map<String, String> userMap) {
    if (_notifications.isNotEmpty) return;
    final now = DateTime.now();
    final demoNotifications = [
      (
        '🔥 Great streak! Keep going!',
        'You\'ve maintained a 7-day streak! Let\'s make it 10.',
        NotificationSchemeType.personalized,
        NotificationPriority.high,
        'user_1',
      ),
      (
        '📚 Words due for review',
        'You have 15 words waiting for review. A quick 5-minute session will clear them!',
        NotificationSchemeType.personalized,
        NotificationPriority.medium,
        'user_2',
      ),
      (
        '🎯 Study plan progress',
        'You\'re 40% through your 30-day plan. Consistency is key!',
        NotificationSchemeType.personalized,
        NotificationPriority.medium,
        'user_3',
      ),
      (
        '✨ New feature: Spaced Repetition 2.0',
        'We\'ve improved our spaced repetition algorithm for better retention. Check it out!',
        NotificationSchemeType.general,
        NotificationPriority.low,
        null,
      ),
      (
        '🏆 Weekly vocabulary challenge',
        'Learn 50 new words this week and earn a special badge!',
        NotificationSchemeType.general,
        NotificationPriority.medium,
        null,
      ),
      (
        '⏰ Time to study!',
        'You haven\'t studied today. A 10-minute session keeps your streak alive!',
        NotificationSchemeType.personalized,
        NotificationPriority.medium,
        'user_1',
      ),
    ];
    for (final n in demoNotifications) {
      _notifications.add(AppNotification(
        id: _uuid.v4(),
        title: n.$1,
        body: n.$2,
        schemeType: n.$3,
        priority: n.$4,
        status: n.$5 != null
            ? NotificationDeliveryStatus.sent
            : NotificationDeliveryStatus.pending,
        targetUserId: n.$5,
        createdAt: now.subtract(const Duration(hours: 2)),
        sentAt: n.$5 != null
            ? now.subtract(const Duration(hours: 2))
            : null,
      ));
    }

    // Seed some agent suggestions
    final demoSuggestions = [
      (
        '🎯 Personalized: User 3 needs encouragement',
        'User 3 completed 5 days of their study plan but missed yesterday. Send an encouraging notification to help them get back on track.',
        NotificationSchemeType.personalized,
        'user_3',
        0.92,
      ),
      (
        '📊 Study plan reminder for all users',
        'Multiple users have words due for review. A general reminder about spaced repetition could boost engagement.',
        NotificationSchemeType.general,
        null,
        0.78,
      ),
      (
        '🔥 Streak saver alert',
        'User 1 has a 7-day streak at risk (missed yesterday\'s session). Send a personalized streak-saving notification.',
        NotificationSchemeType.personalized,
        'user_1',
        0.95,
      ),
    ];
    for (final s in demoSuggestions) {
      _suggestions.add(AgentSuggestion(
        id: _uuid.v4(),
        title: s.$1,
        body: s.$2,
        suggestedScheme: s.$3,
        priority: NotificationPriority.medium,
        reasoning: 'Based on activity log analysis: ${s.$2}',
        confidence: s.$5,
        targetUserId: s.$4,
      ));
    }

    _persistNotifications();
    _persistSuggestions();
  }
}