import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mnemonics/common/design/design_system.dart';
import 'package:mnemonics/core/services/notification_manager.dart';

/// App-bar bell that badges unread items and opens the in-app inbox.
class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(notificationManagerProvider);
    final unread = manager.unreadCount;

    return IconButton(
      tooltip: 'Notifications',
      onPressed: () {
        manager.markAllRead();
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const _NotificationInboxSheet(),
        );
      },
      icon: Badge(
        isLabelVisible: unread > 0,
        backgroundColor: MnemonicsColors.secondaryOrange,
        textColor: Colors.white,
        label: Text(unread > 99 ? '99+' : '$unread'),
        child: Icon(
          unread > 0 ? Icons.notifications : Icons.notifications_none,
        ),
      ),
    );
  }
}

class _NotificationInboxSheet extends ConsumerWidget {
  const _NotificationInboxSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(notificationManagerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? MnemonicsColors.darkSurface : Colors.white;
    final textColor =
        isDark ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary;
    final muted =
        isDark ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: muted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Notifications',
                        style: MnemonicsTypography.headingMedium.copyWith(
                          color: textColor,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    if (manager.inbox.isNotEmpty)
                      TextButton(
                        onPressed: manager.clearAll,
                        child: const Text('Clear all'),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: manager.inbox.isEmpty
                    ? ListView(
                        controller: scrollController,
                        children: [
                          const SizedBox(height: 48),
                          Icon(
                            Icons.notifications_none,
                            size: 48,
                            color: muted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No notifications yet',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: muted, fontSize: 16),
                          ),
                        ],
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: manager.inbox.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = manager.inbox[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  MnemonicsColors.primaryGreen.withOpacity(0.15),
                              child: const Icon(
                                Icons.notifications,
                                color: MnemonicsColors.primaryGreen,
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: item.read
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            subtitle: Text(
                              '${item.message}\n${_timeLabel(item.timestamp)}',
                              style: TextStyle(color: muted),
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              tooltip: 'Dismiss',
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  manager.dismissNotification(item.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _timeLabel(DateTime timestamp) {
    final delta = DateTime.now().difference(timestamp);
    if (delta.inMinutes < 1) return 'Just now';
    if (delta.inHours < 1) return '${delta.inMinutes}m ago';
    if (delta.inDays < 1) return '${delta.inHours}h ago';
    return '${delta.inDays}d ago';
  }
}
