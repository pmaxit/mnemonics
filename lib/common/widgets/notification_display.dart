import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mnemonics/core/services/notification_manager.dart';
import 'package:mnemonics/core/services/notification_poller.dart';
import 'package:mnemonics/common/widgets/notification_banner.dart';

/// Displays floating notification banners and starts admin-inbox polling.
class NotificationDisplay extends ConsumerStatefulWidget {
  final Widget child;

  const NotificationDisplay({super.key, required this.child});

  @override
  ConsumerState<NotificationDisplay> createState() =>
      _NotificationDisplayState();
}

class _NotificationDisplayState extends ConsumerState<NotificationDisplay> {
  @override
  void initState() {
    super.initState();
    NotificationPoller.instance.start();
  }

  @override
  void dispose() {
    NotificationPoller.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationManager = ref.watch(notificationManagerProvider);
    final toasts = notificationManager.toastNotifications;

    return Stack(
      children: [
        widget.child,
        if (toasts.isNotEmpty)
          Positioned(
            top: kToolbarHeight + 16.0,
            left: 16.0,
            right: 16.0,
            child: Column(
              children: toasts.map((notification) {
                return NotificationBanner(
                  key: ValueKey(notification.id),
                  title: notification.title,
                  message: notification.message,
                  onDismiss: () =>
                      notificationManager.dismissNotification(notification.id),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
