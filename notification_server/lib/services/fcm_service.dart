import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Service to send notifications via Firebase Cloud Messaging using HTTP API
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  String? _serverKey;

  /// Initialize FCM service with server key
  void initialize() {
    _serverKey = const String.fromEnvironment('FCM_SERVER_KEY');
    if (_serverKey == null || _serverKey!.isEmpty) {
      print('Warning: FCM_SERVER_KEY not set. FCM service will not work.');
    } else {
      print('FCM service initialized with server key');
    }
  }

  /// Send a notification to a specific device
  Future<void> sendToDevice({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (_serverKey == null || _serverKey!.isEmpty) {
      throw Exception('FCM server key not configured');
    }

    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
          },
          if (data != null) 'data': data,
        }),
      );

      if (response.statusCode == 200) {
        print('Successfully sent FCM message: ${response.body}');
      } else {
        print('Failed to send FCM message: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to send FCM message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending FCM message: $e');
      rethrow;
    }
  }

  /// Send a notification to a topic
  Future<void> sendToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (_serverKey == null || _serverKey!.isEmpty) {
      throw Exception('FCM server key not configured');
    }

    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'to': '/topics/$topic',
          'notification': {
            'title': title,
            'body': body,
          },
          if (data != null) 'data': data,
        }),
      );

      if (response.statusCode == 200) {
        print('Successfully sent FCM message to topic: ${response.body}');
      } else {
        print('Failed to send FCM message to topic: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to send FCM message to topic: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending FCM message to topic: $e');
      rethrow;
    }
  }

  /// Send a notification based on AppNotification model
  Future<void> sendAppNotification(AppNotification notification, String token) async {
    await sendToDevice(
      token: token,
      title: notification.title,
      body: notification.body,
      data: {
        'notification_id': notification.id,
        'scheme_type': notification.schemeType.name,
        'priority': notification.priority.name,
        'created_at': notification.createdAt.toIso8601String(),
        if (notification.targetUserId != null) 'target_user_id': notification.targetUserId,
        if (notification.targetUserSegment != null) 'target_segment': notification.targetUserSegment,
        ...notification.metadata,
      },
    );
  }
}