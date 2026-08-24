import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mnemonics/core/services/notification_manager.dart';
import 'package:mnemonics/common/widgets/notification_banner.dart';

/// A widget that displays notifications at the top of the screen
class NotificationDisplay extends ConsumerWidget {
  final Widget child;

  const NotificationDisplay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationManager = ref.watch(notificationManagerProvider);
    
    return Stack(
      children: [
        child,
        if (notificationManager.notifications.isNotEmpty)
          Positioned(
            top: kToolbarHeight + 16.0, // Below app bar
            left: 16.0,
            right: 16.0,
            child: Column(
              children: notificationManager.notifications.map((notification) {
                return NotificationBanner(
                  key: ValueKey(notification.id),
                  title: notification.title,
                  message: notification.message,
                  onDismiss: () => notificationManager.dismissNotification(notification.id),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}