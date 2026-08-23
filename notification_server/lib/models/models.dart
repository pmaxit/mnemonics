/// Core notification scheme types for the agentic notification system.
enum NotificationSchemeType {
  /// Personalized notification tailored to a specific user's activity.
  personalized,

  /// General broadcast notification for all users.
  general,

  /// Custom message composed by the admin.
  custom,
}

/// Priority levels for notifications.
enum NotificationPriority {
  low,
  medium,
  high,
  urgent,
}

/// Delivery status of a notification.
enum NotificationDeliveryStatus {
  pending,
  sent,
  delivered,
  failed,
  read,
}

/// Represents a notification to be sent to users.
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
    DateTime? createdAt,
    this.scheduledFor,
    this.sentAt,
    this.expiresAt,
    this.targetUserId,
    this.targetUserSegment,
    this.agentReasoning,
    this.metadata = const {},
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'schemeType': schemeType.name,
        'priority': priority.name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'scheduledFor': scheduledFor?.toIso8601String(),
        'sentAt': sentAt?.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'targetUserId': targetUserId,
        'targetUserSegment': targetUserSegment,
        'agentReasoning': agentReasoning,
        'metadata': metadata,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        schemeType: NotificationSchemeType.values.firstWhere(
          (e) => e.name == (json['schemeType'] as String? ?? 'general'),
        ),
        priority: NotificationPriority.values.firstWhere(
          (e) => e.name == (json['priority'] as String? ?? 'medium'),
        ),
        status: NotificationDeliveryStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String? ?? 'pending'),
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        scheduledFor: json['scheduledFor'] != null
            ? DateTime.parse(json['scheduledFor'] as String)
            : null,
        sentAt: json['sentAt'] != null
            ? DateTime.parse(json['sentAt'] as String)
            : null,
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
        targetUserId: json['targetUserId'] as String?,
        targetUserSegment: json['targetUserSegment'] as String?,
        agentReasoning: json['agentReasoning'] as String?,
        metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      );

  AppNotification copyWith({
    NotificationDeliveryStatus? status,
    DateTime? sentAt,
  }) =>
      AppNotification(
        id: id,
        title: title,
        body: body,
        schemeType: schemeType,
        priority: priority,
        status: status ?? this.status,
        createdAt: createdAt,
        scheduledFor: scheduledFor,
        sentAt: sentAt ?? this.sentAt,
        expiresAt: expiresAt,
        targetUserId: targetUserId,
        targetUserSegment: targetUserSegment,
        agentReasoning: agentReasoning,
        metadata: metadata,
      );
}

/// Represents a logged user activity that the agent analyzes.
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
    DateTime? timestamp,
    this.context = const {},
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'activityType': activityType,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'context': context,
      };

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) =>
      ActivityLogEntry(
        id: json['id'] as String,
        userId: json['userId'] as String,
        activityType: json['activityType'] as String,
        description: json['description'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        context: (json['context'] as Map<String, dynamic>?) ?? {},
      );
}

/// Agent-generated notification suggestion.
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
    DateTime? createdAt,
    this.applied = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'suggestedScheme': suggestedScheme.name,
        'priority': priority.name,
        'reasoning': reasoning,
        'confidence': confidence,
        'targetUserId': targetUserId,
        'targetUserSegment': targetUserSegment,
        'createdAt': createdAt.toIso8601String(),
        'applied': applied,
      };

  factory AgentSuggestion.fromJson(Map<String, dynamic> json) =>
      AgentSuggestion(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        suggestedScheme: NotificationSchemeType.values.firstWhere(
          (e) => e.name == (json['suggestedScheme'] as String? ?? 'general'),
        ),
        priority: NotificationPriority.values.firstWhere(
          (e) => e.name == (json['priority'] as String? ?? 'medium'),
        ),
        reasoning: json['reasoning'] as String,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
        targetUserId: json['targetUserId'] as String?,
        targetUserSegment: json['targetUserSegment'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        applied: json['applied'] as bool? ?? false,
      );
}

/// Dashboard stats summary.
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

  Map<String, dynamic> toJson() => {
        'totalNotifications': totalNotifications,
        'sentToday': sentToday,
        'pendingNotifications': pendingNotifications,
        'failedNotifications': failedNotifications,
        'activeUsersToday': activeUsersToday,
        'pendingSuggestions': pendingSuggestions,
        'averageUserEngagement': averageUserEngagement,
      };
}