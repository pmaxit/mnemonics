import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/models.dart';
import '../services/services.dart';

/// API router for the notification backend.
class ApiRouter {
  final ActivityLogService _logService;
  final NotificationService _notificationService;
  final NotificationAgentService _agentService;
  final FCMService _fcmService;
  final DeviceRegistry _deviceRegistry;

  ApiRouter({
    required ActivityLogService logService,
    required NotificationService notificationService,
    required NotificationAgentService agentService,
    required FCMService fcmService,
    required DeviceRegistry deviceRegistry,
  })  : _logService = logService,
        _notificationService = notificationService,
        _agentService = agentService,
        _fcmService = fcmService,
        _deviceRegistry = deviceRegistry;

  Router get router {
    final r = Router();

    // -----------------------------------------------------------------------
    // Dashboard stats
    // -----------------------------------------------------------------------
    r.get('/api/stats', (Request request) {
      final activeUsers = _logService.activeUsersInLastHours(24);
      final stats = _notificationService.getStats(activeUsers);
      return _jsonResponse(stats.toJson());
    });

    // -----------------------------------------------------------------------
    // Activity logs
    // -----------------------------------------------------------------------
    r.get('/api/activity-logs', (Request request) {
      final limit = _intParam(request, 'limit', 100);
      final offset = _intParam(request, 'offset', 0);
      final logs = _logService.getRecent(limit: limit, offset: offset);
      return _jsonResponse({
        'logs': logs.map((l) => l.toJson()).toList(),
        'total': _logService.totalLogs,
        'limit': limit,
        'offset': offset,
      });
    });

    r.get('/api/activity-logs/types', (Request request) {
      return _jsonResponse(_logService.getActivityTypeCounts());
    });

    r.get('/api/activity-logs/user/<userId>', (Request request, String userId) {
      final limit = _intParam(request, 'limit', 50);
      final logs = _logService.getByUser(userId, limit: limit);
      return _jsonResponse({
        'logs': logs.map((l) => l.toJson()).toList(),
        'userId': userId,
      });
    });

    r.post('/api/activity-logs', (Request request) async {
      final body = await _parseBody(request);
      if (body == null) return _badRequest('Invalid JSON body');
      try {
        final entry = _logService.log(
          userId: body['userId'] as String? ?? 'anonymous',
          activityType: body['activityType'] as String? ?? 'unknown',
          description: body['description'] as String? ?? '',
          context: (body['context'] as Map<String, dynamic>?) ?? {},
        );
        return _jsonResponse(entry.toJson(), status: 201);
      } catch (e) {
        return _badRequest('Failed to create log entry: $e');
      }
    });

    // -----------------------------------------------------------------------
    // Notifications
    // -----------------------------------------------------------------------
    r.get('/api/notifications', (Request request) {
      final limit = _intParam(request, 'limit', 50);
      final offset = _intParam(request, 'offset', 0);
      final schemeStr = request.url.queryParameters['schemeType'];
      final statusStr = request.url.queryParameters['status'];
      NotificationSchemeType? schemeFilter;
      NotificationDeliveryStatus? statusFilter;
      if (schemeStr != null) {
        schemeFilter = NotificationSchemeType.values.firstWhere(
          (e) => e.name == schemeStr,
          orElse: () => NotificationSchemeType.general,
        );
      }
      if (statusStr != null) {
        statusFilter = NotificationDeliveryStatus.values.firstWhere(
          (e) => e.name == statusStr,
          orElse: () => NotificationDeliveryStatus.pending,
        );
      }
      final notifications = _notificationService.getNotifications(
        limit: limit,
        offset: offset,
        schemeFilter: schemeFilter,
        statusFilter: statusFilter,
      );
      return _jsonResponse({
        'notifications': notifications.map((n) => n.toJson()).toList(),
        'total': _notificationService.getStats(0).totalNotifications,
      });
    });

    r.post('/api/notifications', (Request request) async {
      final body = await _parseBody(request);
      if (body == null) return _badRequest('Invalid JSON body');
      try {
        final notification = _notificationService.createNotification(
          title: body['title'] as String? ?? 'Notification',
          body: body['body'] as String? ?? '',
          schemeType: _parseScheme(body['schemeType'] as String?),
          priority: _parsePriority(body['priority'] as String?),
          scheduledFor: body['scheduledFor'] != null
              ? DateTime.tryParse(body['scheduledFor'] as String)
              : null,
          expiresAt: body['expiresAt'] != null
              ? DateTime.tryParse(body['expiresAt'] as String)
              : null,
          targetUserId: body['targetUserId'] as String?,
          targetUserSegment: body['targetUserSegment'] as String?,
          agentReasoning: body['agentReasoning'] as String?,
          metadata: (body['metadata'] as Map<String, dynamic>?) ?? {},
        );
        return _jsonResponse(notification.toJson(), status: 201);
      } catch (e) {
        return _badRequest('Failed to create notification: $e');
      }
    });

    r.post('/api/notifications/<id>/send', (Request request, String id) async {
      try {
        final existing = _notificationService.getById(id);
        if (existing == null) {
          return _notFound('Notification not found');
        }
        final fcm = await _fcmService.deliver(
          existing,
          devices: _deviceRegistry,
        );
        final notification = _notificationService.sendNotification(id);
        return _jsonResponse({
          ...notification.toJson(),
          'fcm': fcm.toJson(),
        });
      } catch (e) {
        return _notFound('Notification not found: $e');
      }
    });

    r.post('/api/devices/register', (Request request) async {
      final body = await _parseBody(request);
      final token = body?['token'] as String?;
      if (token == null || token.isEmpty) {
        return _badRequest('Device token is required');
      }
      _deviceRegistry.register(
        token: token,
        userId: body?['userId'] as String?,
        platform: body?['platform'] as String?,
      );
      developer.log(
        'Registered device platform=${body?['platform']} user=${body?['userId']} total=${_deviceRegistry.count}',
      );
      return _jsonResponse({
        'ok': true,
        'devices': _deviceRegistry.count,
      });
    });

    // Send notification via FCM to an explicit device token
    r.post('/api/notifications/<id>/send-fcm', (Request request, String id) async {
      final body = await _parseBody(request);
      final token = body?['token'] as String?;
      
      if (token == null || token.isEmpty) {
        return _badRequest('Device token is required');
      }

      try {
        final notification = _notificationService.getById(id);
        if (notification == null) {
          return _notFound('Notification not found');
        }

        final fcm = await _fcmService.deliver(
          notification,
          devices: _deviceRegistry,
          explicitToken: token,
        );
        final updatedNotification = _notificationService.sendNotification(id);
        return _jsonResponse({
          ...updatedNotification.toJson(),
          'fcm': fcm.toJson(),
        });
      } catch (e) {
        return _serverError('Failed to send notification via FCM: $e');
      }
    });

    // -----------------------------------------------------------------------
    // Agent suggestions
    // -----------------------------------------------------------------------
    r.get('/api/suggestions', (Request request) {
      final onlyPending = request.url.queryParameters['pending'] == 'true';
      final suggestions = onlyPending
          ? _notificationService.getPendingSuggestions()
          : _notificationService.getAllSuggestions();
      return _jsonResponse({
        'suggestions': suggestions.map((s) => s.toJson()).toList(),
      });
    });

    /// Trigger the agent to analyze logs and generate suggestions.
    r.post('/api/agent/analyze', (Request request) async {
      try {
        developer.log('Agent analysis triggered');
        final suggestions = await _agentService.analyzeActivityLogs(
          _logService,
          _notificationService,
        );
        for (final suggestion in suggestions) {
          _notificationService.addSuggestion(
            title: suggestion.title,
            body: suggestion.body,
            suggestedScheme: suggestion.suggestedScheme,
            priority: suggestion.priority,
            reasoning: suggestion.reasoning,
            confidence: suggestion.confidence,
            targetUserId: suggestion.targetUserId,
            targetUserSegment: suggestion.targetUserSegment,
          );
        }
        developer.log('Agent created ${suggestions.length} suggestions');
        return _jsonResponse({
          'suggestions': suggestions.map((s) => s.toJson()).toList(),
          'count': suggestions.length,
        });
      } catch (e) {
        developer.log('Agent analysis error: $e');
        return _serverError('Agent analysis failed: $e');
      }
    });

    r.post('/api/suggestions/<id>/apply', (Request request, String id) {
      try {
        final notification = _notificationService.applySuggestion(id);
        return _jsonResponse({
          'notification': notification.toJson(),
          'message': 'Suggestion applied successfully',
        });
      } catch (e) {
        return _notFound('Suggestion not found: $e');
      }
    });

    r.post('/api/suggestions/<id>/discard', (Request request, String id) {
      try {
        _notificationService.discardSuggestion(id);
        return _jsonResponse({'message': 'Suggestion discarded'});
      } catch (e) {
        return _notFound('Suggestion not found: $e');
      }
    });

    // -----------------------------------------------------------------------
    // Health check
    // -----------------------------------------------------------------------
    r.get('/api/health', (Request request) {
      return _jsonResponse({
        'status': 'healthy',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'stats': _notificationService.getStats(0).toJson(),
        'activityLogs': _logService.totalLogs,
        'fcmConfigured': _fcmService.isConfigured,
        'fcmError': _fcmService.initError,
        'registeredDevices': _deviceRegistry.count,
      });
    });

    // -----------------------------------------------------------------------
    // Seed demo data
    // -----------------------------------------------------------------------
    r.post('/api/seed', (Request request) {
      _logService.seedDemoData();
      _notificationService.seedDemoData({});
      return _jsonResponse({'message': 'Demo data seeded successfully'});
    });

    return r;
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Response _jsonResponse(Map<String, dynamic> data, {int status = 200}) {
    return Response(
      status,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  Response _badRequest(String message) {
    return Response(400, body: jsonEncode({'error': message}));
  }

  Response _notFound(String message) {
    return Response(404, body: jsonEncode({'error': message}));
  }

  Response _serverError(String message) {
    return Response(500, body: jsonEncode({'error': message}));
  }

  Future<Map<String, dynamic>?> _parseBody(Request request) async {
    try {
      final body = await request.readAsString();
      if (body.isEmpty) return null;
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  int _intParam(Request request, String name, int defaultValue) {
    final value = request.url.queryParameters[name];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  NotificationSchemeType _parseScheme(String? value) {
    if (value == null) return NotificationSchemeType.general;
    return NotificationSchemeType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationSchemeType.general,
    );
  }

  NotificationPriority _parsePriority(String? value) {
    if (value == null) return NotificationPriority.medium;
    return NotificationPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationPriority.medium,
    );
  }
}