enum NotificationSchemeType { personalized, general, custom }

enum NotificationPriority { low, medium, high, urgent }

enum NotificationDeliveryStatus { pending, sent, delivered, failed, read }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationSchemeType schemeType;
  final NotificationPriority priority;
  final NotificationDeliveryStatus status;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final DateTime? sentAt;
  final DateTime? expiresAt;
  final String? targetUserId;
  final String? targetUserSegment;
  final String? agentReasoning;
  final Map<String, dynamic> metadata;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.schemeType,
    this.priority = NotificationPriority.medium,
    this.status = NotificationDeliveryStatus.pending,
    required this.createdAt,
    this.scheduledFor,
    this.sentAt,
    this.expiresAt,
    this.targetUserId,
    this.targetUserSegment,
    this.agentReasoning,
    this.metadata = const {},
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        schemeType: NotificationSchemeType.values.firstWhere(
          (e) => e.name == (j['schemeType'] as String? ?? 'general'),
          orElse: () => NotificationSchemeType.general,
        ),
        priority: NotificationPriority.values.firstWhere(
          (e) => e.name == (j['priority'] as String? ?? 'medium'),
          orElse: () => NotificationPriority.medium,
        ),
        status: NotificationDeliveryStatus.values.firstWhere(
          (e) => e.name == (j['status'] as String? ?? 'pending'),
          orElse: () => NotificationDeliveryStatus.pending,
        ),
        createdAt: DateTime.parse(j['createdAt'] as String),
        scheduledFor: j['scheduledFor'] != null ? DateTime.tryParse(j['scheduledFor'] as String) : null,
        sentAt: j['sentAt'] != null ? DateTime.tryParse(j['sentAt'] as String) : null,
        expiresAt: j['expiresAt'] != null ? DateTime.tryParse(j['expiresAt'] as String) : null,
        targetUserId: j['targetUserId'] as String?,
        targetUserSegment: j['targetUserSegment'] as String?,
        agentReasoning: j['agentReasoning'] as String?,
        metadata: (j['metadata'] as Map<String, dynamic>?) ?? {},
      );
}

class ActivityLogEntry {
  final String id;
  final String userId;
  final String activityType;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> context;
  ActivityLogEntry({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.description,
    required this.timestamp,
    this.context = const {},
  });
  factory ActivityLogEntry.fromJson(Map<String, dynamic> j) => ActivityLogEntry(
        id: j['id'] as String,
        userId: j['userId'] as String,
        activityType: j['activityType'] as String,
        description: j['description'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
        context: (j['context'] as Map<String, dynamic>?) ?? {},
      );
}

class AgentSuggestion {
  final String id;
  final String title;
  final String body;
  final NotificationSchemeType suggestedScheme;
  final NotificationPriority priority;
  final String reasoning;
  final double confidence;
  final String? targetUserId;
  final String? targetUserSegment;
  final DateTime createdAt;
  final bool applied;
  AgentSuggestion({
    required this.id,
    required this.title,
    required this.body,
    required this.suggestedScheme,
    this.priority = NotificationPriority.medium,
    required this.reasoning,
    this.confidence = 0.5,
    this.targetUserId,
    this.targetUserSegment,
    required this.createdAt,
    this.applied = false,
  });
  factory AgentSuggestion.fromJson(Map<String, dynamic> j) => AgentSuggestion(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        suggestedScheme: NotificationSchemeType.values.firstWhere(
          (e) => e.name == (j['suggestedScheme'] as String? ?? 'general'),
          orElse: () => NotificationSchemeType.general,
        ),
        priority: NotificationPriority.values.firstWhere(
          (e) => e.name == (j['priority'] as String? ?? 'medium'),
          orElse: () => NotificationPriority.medium,
        ),
        reasoning: j['reasoning'] as String? ?? '',
        confidence: (j['confidence'] as num?)?.toDouble() ?? 0.5,
        targetUserId: j['targetUserId'] as String?,
        targetUserSegment: j['targetUserSegment'] as String?,
        createdAt: DateTime.parse(j['createdAt'] as String),
        applied: j['applied'] as bool? ?? false,
      );
}

class DashboardStats {
  final int totalNotifications;
  final int sentToday;
  final int pendingNotifications;
  final int failedNotifications;
  final int activeUsersToday;
  final int pendingSuggestions;
  final double averageUserEngagement;
  DashboardStats({
    this.totalNotifications = 0,
    this.sentToday = 0,
    this.pendingNotifications = 0,
    this.failedNotifications = 0,
    this.activeUsersToday = 0,
    this.pendingSuggestions = 0,
    this.averageUserEngagement = 0.0,
  });
  factory DashboardStats.fromJson(Map<String, dynamic> j) => DashboardStats(
        totalNotifications: j['totalNotifications'] as int? ?? 0,
        sentToday: j['sentToday'] as int? ?? 0,
        pendingNotifications: j['pendingNotifications'] as int? ?? 0,
        failedNotifications: j['failedNotifications'] as int? ?? 0,
        activeUsersToday: j['activeUsersToday'] as int? ?? 0,
        pendingSuggestions: j['pendingSuggestions'] as int? ?? 0,
        averageUserEngagement: (j['averageUserEngagement'] as num?)?.toDouble() ?? 0.0,
      );
}
