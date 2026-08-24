import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mnemonics/core/services/notification_manager.dart';

/// A widget that listens for Firebase messages and shows them as banners
class NotificationListener extends ConsumerStatefulWidget {
  final Widget child;

  const NotificationListener({super.key, required this.child});

  @override
  ConsumerState<NotificationListener> createState() => _NotificationListenerState();
}

class _NotificationListenerState extends ConsumerState<NotificationListener> {
  @override
  void initState() {
    super.initState();
    
    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      // Schedule the state update for the next frame to avoid issues with context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Add to notification manager
          final notificationManager = ref.read(notificationManagerProvider);
          notificationManager.showNotification(
            title: message.notification!.title ?? 'Notification',
            message: message.notification!.body ?? '',
          );
          
          developer.log('Notification received: ${message.notification!.title}');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}