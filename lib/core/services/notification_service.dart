import 'dart:convert';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mnemonics/core/config/notification_api_config.dart';
import 'package:mnemonics/core/platform/desktop_compat.dart';
import 'package:mnemonics/core/services/local_notifications.dart';
import 'package:mnemonics/core/services/notification_manager.dart';
import 'package:mnemonics/core/services/notification_poller.dart';
import 'package:mnemonics/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  developer.log(
    'Background message received: ${message.notification?.title}',
  );
}

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
      await LocalNotifications.prime();
      await LocalNotifications.requestPermission();

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('Notification permission: ${settings.authorizationStatus}');
      }

      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await _obtainFcmToken();
      developer.log('FCM Registration Token: $token');
      debugPrint('FCM Registration Token: $token');

      if (token != null && token.isNotEmpty) {
        await _subscribeAndRegister(token);
      } else {
        debugPrint(
          'No FCM token yet. Lock-screen push will not work until APNs registers.',
        );
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM token refresh: $newToken');
        await _subscribeAndRegister(newToken);
      });

      if (!desktopAuthBypass) {
        FirebaseAuth.instance.authStateChanges().listen((user) async {
          final current = await _obtainFcmToken();
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

  Future<void> _subscribeAndRegister(String token) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(_allUsersTopic);
      debugPrint('Subscribed to $_allUsersTopic');
    } catch (e) {
      debugPrint('Topic subscribe failed: $e');
    }
    await _registerDevice(token);
  }

  Future<String?> _obtainFcmToken() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final apns = await _waitForApnsToken();
      if (apns == null) return null;
    }
    for (var i = 0; i < 5; i++) {
      try {
        final token = await FirebaseMessaging.instance
            .getToken()
            .timeout(const Duration(seconds: 15));
        if (token != null && token.isNotEmpty) return token;
      } catch (e) {
        debugPrint('getToken attempt ${i + 1} failed: $e');
        await LocalNotifications.prime();
        await _waitForApnsToken();
      }
    }
    return null;
  }

  Future<String?> _waitForApnsToken() async {
    for (var i = 0; i < 40; i++) {
      final apns = await FirebaseMessaging.instance.getAPNSToken();
      if (apns != null) {
        debugPrint('APNs token ready');
        return apns;
      }
      if (i == 0 || i % 4 == 0) {
        await LocalNotifications.prime();
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    debugPrint('APNs token not ready; lock-screen FCM cannot be delivered');
    return null;
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
      LocalNotifications.show(title: title, body: body, id: id);
    }
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
