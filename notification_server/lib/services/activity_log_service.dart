import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import '../models/models.dart';

/// In-memory store with optional file persistence for activity logs.
/// In production, replace with a proper database.
class ActivityLogService {
  final List<ActivityLogEntry> _logs = [];
  final String? _persistencePath;

  ActivityLogService({String? persistencePath})
      : _persistencePath = persistencePath {
    if (_persistencePath != null) {
      _load();
    }
  }

  void _load() {
    try {
      final file = File(_persistencePath!);
      if (file.existsSync()) {
        final lines = file.readAsLinesSync();
        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            _logs.add(
              ActivityLogEntry.fromJson(
                jsonDecode(line) as Map<String, dynamic>,
              ),
            );
          }
        }
      }
    } catch (_) {
      // Ignore load errors
    }
  }

  void _persist() {
    if (_persistencePath == null) return;
    try {
      final file = File(_persistencePath);
      file.writeAsStringSync(
        _logs.map((e) => jsonEncode(e.toJson())).join('\n'),
      );
    } catch (_) {
      // Ignore persistence errors
    }
  }

  ActivityLogEntry log({
    required String userId,
    required String activityType,
    required String description,
    Map<String, dynamic> context = const {},
  }) {
    final entry = ActivityLogEntry(
      id: _generateId(),
      userId: userId,
      activityType: activityType,
      description: description,
      timestamp: DateTime.now(),
      context: context,
    );
    _logs.insert(0, entry);
    _persist();
    return entry;
  }

  List<ActivityLogEntry> getRecent({int limit = 100, int offset = 0}) {
    return _logs.skip(offset).take(limit).toList();
  }

  List<ActivityLogEntry> getByUser(String userId, {int limit = 50}) {
    return _logs
        .where((e) => e.userId == userId)
        .take(limit)
        .toList();
  }

  List<ActivityLogEntry> getByType(String activityType, {int limit = 50}) {
    return _logs
        .where((e) => e.activityType == activityType)
        .take(limit)
        .toList();
  }

  Map<String, int> getActivityTypeCounts() {
    final counts = <String, int>{};
    for (final log in _logs) {
      counts[log.activityType] = (counts[log.activityType] ?? 0) + 1;
    }
    return counts;
  }

  int get totalLogs => _logs.length;

  /// Count unique active users in the last N hours.
  int activeUsersInLastHours(int hours) {
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    return _logs
        .where((e) => e.timestamp.isAfter(cutoff))
        .map((e) => e.userId)
        .toSet()
        .length;
  }

  /// Aggregate user engagement (unique users / total logs ratio in last 24h).
  double get averageEngagementLast24h {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final recent = _logs.where((e) => e.timestamp.isAfter(cutoff)).toList();
    if (recent.isEmpty) return 0.0;
    final uniqueUsers = recent.map((e) => e.userId).toSet().length;
    return uniqueUsers / recent.length;
  }

  List<ActivityLogEntry> getAll() => List.unmodifiable(_logs);

  /// Seed with sample data for demo purposes.
  void seedDemoData() {
    if (_logs.isNotEmpty) return;
    final now = DateTime.now();
    final sampleUsers = ['user_1', 'user_2', 'user_3'];
    final sampleActivities = [
      ('session_completed', 'Completed a study session'),
      ('word_reviewed', 'Reviewed 5 vocabulary words'),
      ('plan_created', 'Created a 30-day study plan'),
      ('streak_milestone', 'Reached a 7-day streak'),
      ('accuracy_improved', 'Accuracy improved to 85%'),
      ('new_words_added', 'Added 10 new words'),
      ('plan_day_completed', 'Completed day 4 of study plan'),
      ('session_missed', 'Missed yesterday\'s study session'),
      ('words_due', '15 words are due for review'),
      ('badge_earned', 'Earned the "Week Warrior" badge'),
    ];
    for (final user in sampleUsers) {
      for (int i = 0; i < 15; i++) {
        final activity = sampleActivities[i % sampleActivities.length];
        _logs.add(ActivityLogEntry(
          id: _generateId(),
          userId: user,
          activityType: activity.$1,
          description: activity.$2,
          timestamp: now.subtract(Duration(hours: i * 3)),
          context: {
            'source': 'seed_data',
            if (activity.$1 == 'word_reviewed') 'count': 5,
            if (activity.$1 == 'accuracy_improved')
              'accuracy': (0.75 + (i * 0.01)).toStringAsFixed(2),
          },
        ));
      }
    }
    _persist();
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (DateTime.now().microsecondsSinceEpoch % 10000).toString();
    return sha256
        .convert(utf8.encode('$timestamp-$random-${_logs.length}'))
        .toString()
        .substring(0, 16);
  }
}