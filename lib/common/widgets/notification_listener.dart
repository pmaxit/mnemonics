import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mnemonics/core/services/notification_manager.dart';

/// Hosts the optional local test banner. FCM handling lives in NotificationService.
class FcmNotificationListener extends ConsumerStatefulWidget {
  final Widget child;

  const FcmNotificationListener({super.key, required this.child});

  @override
  ConsumerState<FcmNotificationListener> createState() =>
      _FcmNotificationListenerState();
}

class _FcmNotificationListenerState
    extends ConsumerState<FcmNotificationListener> {
  @override
  void initState() {
    super.initState();
    if (const bool.fromEnvironment('SHOW_TEST_NOTIFICATION')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(notificationManagerProvider).showNotification(
          title: 'Phone test',
          message: 'In-app notifications are working on this device',
          sourceKey: 'phone-test',
        );
        developer.log('Local test notification shown');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
