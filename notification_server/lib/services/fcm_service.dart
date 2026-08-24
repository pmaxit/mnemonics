import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'device_registry.dart';

/// Result of attempting FCM delivery for one admin notification.
class FcmSendResult {
  FcmSendResult({
    required this.configured,
    this.successCount = 0,
    this.attempted = 0,
    List<String>? errors,
  }) : errors = errors ?? [];

  final bool configured;
  final int successCount;
  final int attempted;
  final List<String> errors;

  Map<String, dynamic> toJson() => {
        'configured': configured,
        'successCount': successCount,
        'attempted': attempted,
        'errors': errors,
      };
}

/// Sends notifications through FCM HTTP v1 (legacy server keys no longer work).
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  static const _topic = 'all_users';
  static const _scope = 'https://www.googleapis.com/auth/firebase.messaging';

  http.Client? _client;
  String? _projectId;
  String? _initError;

  bool get isConfigured => _client != null && _projectId != null;

  String? get initError => _initError;

  Future<void> initialize() async {
    try {
      final account = _loadServiceAccount();
      if (account == null) {
        _initError =
            'Set FIREBASE_SERVICE_ACCOUNT (JSON) or FIREBASE_SERVICE_ACCOUNT_BASE64 on the server.';
        print('Warning: $_initError FCM send is disabled.');
        return;
      }
      final credentials = ServiceAccountCredentials.fromJson(account);
      _projectId = account['project_id'] as String? ??
          Platform.environment['FCM_PROJECT_ID'] ??
          'mnemonics-76ca2';
      _client = await clientViaServiceAccount(credentials, [_scope]);
      _initError = null;
      print('FCM HTTP v1 initialized for project $_projectId');
    } catch (e) {
      _initError = '$e';
      _client = null;
      print('Failed to initialize FCM: $e');
    }
  }

  Map<String, dynamic>? _loadServiceAccount() {
    final raw = Platform.environment['FIREBASE_SERVICE_ACCOUNT'];
    if (raw != null && raw.trim().isNotEmpty) {
      return jsonDecode(raw) as Map<String, dynamic>;
    }
    final b64 = Platform.environment['FIREBASE_SERVICE_ACCOUNT_BASE64'];
    if (b64 != null && b64.trim().isNotEmpty) {
      return jsonDecode(utf8.decode(base64Decode(b64.trim())))
          as Map<String, dynamic>;
    }
    final path = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
    if (path != null && path.isNotEmpty) {
      return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    }
    return null;
  }

  Future<FcmSendResult> deliver(
    AppNotification notification, {
    DeviceRegistry? devices,
    String? explicitToken,
  }) async {
    if (!isConfigured) {
      return FcmSendResult(
        configured: false,
        errors: [_initError ?? 'FCM is not configured'],
      );
    }

    final tokens = <String>{};
    if (explicitToken != null && explicitToken.isNotEmpty) {
      tokens.add(explicitToken);
    }
    final targetUser = notification.targetUserId;
    if (targetUser != null && targetUser.isNotEmpty) {
      for (final device in devices?.forUser(targetUser) ?? const []) {
        tokens.add(device.token);
      }
    }

    var attempted = 0;
    var successCount = 0;
    final errors = <String>[];

    final isBroadcast =
        targetUser == null || targetUser.isEmpty;
    if (isBroadcast) {
      attempted++;
      try {
        await _send(topic: _topic, notification: notification);
        successCount++;
      } catch (e) {
        errors.add('topic/$_topic: $e');
      }
      for (final device in devices?.all() ?? const []) {
        tokens.add(device.token);
      }
      if (tokens.isEmpty) {
        errors.add(
          'No devices have registered an FCM token. Open the iPhone app, allow notifications, then send again.',
        );
      }
    }

    for (final token in tokens) {
      attempted++;
      try {
        await _send(token: token, notification: notification);
        successCount++;
      } catch (e) {
        errors.add('token: $e');
      }
    }

    if (attempted == 0) {
      errors.add(
        'No FCM targets. Personalized send needs a registered device for that user.',
      );
    }

    return FcmSendResult(
      configured: true,
      successCount: successCount,
      attempted: attempted,
      errors: errors,
    );
  }

  Future<void> sendToDevice({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _sendRaw(
      target: {'token': token},
      title: title,
      body: body,
      data: data,
    );
  }

  Future<void> sendToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _sendRaw(
      target: {'topic': topic},
      title: title,
      body: body,
      data: data,
    );
  }

  Future<void> sendAppNotification(
    AppNotification notification,
    String token,
  ) async {
    await _send(token: token, notification: notification);
  }

  Future<void> _send({
    String? token,
    String? topic,
    required AppNotification notification,
  }) {
    return _sendRaw(
      target: {
        if (token != null) 'token': token,
        if (topic != null) 'topic': topic,
      },
      title: notification.title,
      body: notification.body,
      data: {
        'notification_id': notification.id,
        'title': notification.title,
        'body': notification.body,
        'scheme_type': notification.schemeType.name,
        'priority': notification.priority.name,
        if (notification.targetUserId != null)
          'target_user_id': notification.targetUserId!,
      },
    );
  }

  Future<void> _sendRaw({
    required Map<String, String> target,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final client = _client;
    final projectId = _projectId;
    if (client == null || projectId == null) {
      throw Exception('FCM server is not configured');
    }

    final stringData = <String, String>{};
    if (data != null) {
      data.forEach((key, value) {
        if (value != null) stringData[key] = '$value';
      });
    }

    final response = await client.post(
      Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': {
          ...target,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': stringData,
          'android': {
            'priority': 'HIGH',
            'notification': {
              'title': title,
              'body': body,
              'sound': 'default',
            },
          },
          'apns': {
            'headers': {
              'apns-priority': '10',
              'apns-push-type': 'alert',
            },
            'payload': {
              'aps': {
                'alert': {
                  'title': title,
                  'body': body,
                },
                'sound': 'default',
                'badge': 1,
              },
            },
          },
        },
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('FCM send ok: ${response.body}');
      return;
    }
    throw Exception('FCM ${response.statusCode}: ${response.body}');
  }
}
