import 'dart:convert';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mnemonics/core/config/notification_api_config.dart';
import 'package:mnemonics/core/platform/desktop_compat.dart';
import 'package:mnemonics/core/services/notification_manager.dart';
import 'package:mnemonics/core/services/notification_poller.dart';

/// Handles foreground and background notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const _allUsersTopic = 'all_users';

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      developer.log('Requesting notification permission...');
      debugPrint('Requesting notification permission...');
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('Notification permission: ${settings.authorizationStatus}');
        await _waitForApnsToken();
      }

      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      String? token;
      try {
        token = await FirebaseMessaging.instance
            .getToken()
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        debugPrint('getToken failed: $e');
      }
      developer.log('FCM Registration Token: $token');
      debugPrint('FCM Registration Token: $token');

      if (token != null && token.isNotEmpty) {
        try {
          await FirebaseMessaging.instance.subscribeToTopic(_allUsersTopic);
          debugPrint('Subscribed to $_allUsersTopic');
        } catch (e) {
          debugPrint('Topic subscribe failed: $e');
        }
        await _registerDevice(token);
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM token refresh: $newToken');
        await FirebaseMessaging.instance.subscribeToTopic(_allUsersTopic);
        await _registerDevice(newToken);
      });

      if (!desktopAuthBypass) {
        FirebaseAuth.instance.authStateChanges().listen((user) async {
          final current = await FirebaseMessaging.instance.getToken();
          if (current != null) await _registerDevice(current, userId: user?.uid);
        });
      }

      if (const bool.fromEnvironment('SHOW_TEST_NOTIFICATION')) {
        NotificationManager.instance.showNotification(
          title: 'Phone test',
          message: 'In-app notifications are working on this device',
          sourceKey: 'phone-test',
        );
      }

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      developer.log('Firebase Messaging initialized successfully');
    } catch (e) {
      developer.log('Error initializing Firebase Messaging: $e');
      debugPrint('Error initializing Firebase Messaging: $e');
    }
  }

  Future<void> _waitForApnsToken() async {
    for (var i = 0; i < 10; i++) {
      final apns = await FirebaseMessaging.instance.getAPNSToken();
      if (apns != null) {
        debugPrint('APNs token ready');
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    debugPrint('APNs token not ready; topic subscribe may fail until it is');
  }

  Future<void> _registerDevice(String token, {String? userId}) async {
    try {
      final resolvedUserId = userId ??
          (desktopAuthBypass
              ? desktopLocalUserId
              : FirebaseAuth.instance.currentUser?.uid);
      final platform = defaultTargetPlatform == TargetPlatform.iOS
          ? 'ios'
          : defaultTargetPlatform == TargetPlatform.android
              ? 'android'
              : defaultTargetPlatform.name;
      final response = await http
          .post(
            Uri.parse(
              '${NotificationApiConfig.baseUrl}/api/devices/register',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'token': token,
              'platform': platform,
              if (resolvedUserId != null) 'userId': resolvedUserId,
            }),
          )
          .timeout(const Duration(seconds: 8));
      debugPrint('Device register ${response.statusCode}: ${response.body}');
    } catch (e) {
      debugPrint('Device register failed: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final id = message.data['notification_id'] as String?;
    if (id != null) {
      NotificationPoller.instance.markSeen(id);
    }
    final title = message.notification?.title ??
        message.data['title'] as String? ??
        'Notification';
    final body = message.notification?.body ??
        message.data['body'] as String? ??
        message.data['message'] as String? ??
        '';
    developer.log('Foreground message received: $title');
    if (title.isNotEmpty || body.isNotEmpty) {
      NotificationManager.instance.showNotification(
        title: title,
        message: body,
        sourceKey: id,
        showToast: false,
      );
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    developer.log(
      'Background message received: ${message.notification?.title}',
    );
  }

  void _handleMessage(RemoteMessage message) {
    developer.log('Notification tapped: ${message.notification?.title}');
    if (message.data.isNotEmpty) {
      developer.log('Notification data: ${message.data}');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    developer.log('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    developer.log('Unsubscribed from topic: $topic');
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final initializeNotificationProvider = Provider<bool>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  notificationService.initialize();
  return true;
});
