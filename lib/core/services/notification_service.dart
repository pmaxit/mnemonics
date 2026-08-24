import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Handles foreground and background notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Request permission for iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Configure notification settings for Android
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get the token
      final token = await FirebaseMessaging.instance.getToken();
      developer.log('FCM Registration Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle tap on notification when app is terminated
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }

      // Handle tap on notification when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
      
      developer.log('Firebase Messaging initialized successfully');
    } catch (e) {
      developer.log('Error initializing Firebase Messaging: $e');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    developer.log('Foreground message received: ${message.notification?.title}');
    
    // Show a snackbar or dialog to inform user about the notification
    if (message.notification != null) {
      developer.log('Notification: ${message.notification!.title} - ${message.notification!.body}');
    }
  }

  /// Handle background messages
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    developer.log('Background message received: ${message.notification?.title}');
    
    // Handle background message
    // Note: This callback must be a top-level function or static method
    if (message.notification != null) {
      developer.log('Background notification: ${message.notification!.title} - ${message.notification!.body}');
    }
  }

  /// Handle message when tapped
  void _handleMessage(RemoteMessage message) {
    developer.log('Notification tapped: ${message.notification?.title}');
    
    // Navigate to appropriate screen based on notification data
    if (message.data.isNotEmpty) {
      developer.log('Notification data: ${message.data}');
      // Handle deep linking based on data payload
    }
  }
  
  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    developer.log('Subscribed to topic: $topic');
  }
  
  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    developer.log('Unsubscribed from topic: $topic');
  }
}

/// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider to initialize notification service
final initializeNotificationProvider = Provider<bool>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  notificationService.initialize();
  return true;
});