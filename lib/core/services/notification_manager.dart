import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-app notification inbox plus short-lived toast overlays.
class NotificationManager extends ChangeNotifier {
  NotificationManager._();
  static final NotificationManager instance = NotificationManager._();
  factory NotificationManager() => instance;

  static const int _maxInboxSize = 50;

  final List<NotificationItem> _inbox = [];
  final Set<int> _toastIds = {};

  List<NotificationItem> get inbox => List.unmodifiable(_inbox);

  /// Notifications currently shown as floating banners.
  List<NotificationItem> get toastNotifications => _inbox
      .where((notification) => _toastIds.contains(notification.id))
      .toList(growable: false);

  /// Backwards-compatible alias used by overlay widgets.
  List<NotificationItem> get notifications => toastNotifications;

  int get unreadCount => _inbox.where((notification) => !notification.read).length;

  void showNotification({
    required String title,
    required String message,
    String? sourceKey,
    Duration duration = const Duration(seconds: 5),
    bool showToast = true,
  }) {
    if (sourceKey != null &&
        _inbox.any((notification) => notification.sourceKey == sourceKey)) {
      return;
    }
    final id = DateTime.now().millisecondsSinceEpoch;
    final notification = NotificationItem(
      id: id,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      sourceKey: sourceKey,
    );

    _inbox.insert(0, notification);
    if (showToast) {
      _toastIds.add(id);
    }
    if (_inbox.length > _maxInboxSize) {
      final removed = _inbox.removeLast();
      _toastIds.remove(removed.id);
    }
    notifyListeners();

    if (showToast) {
      Future.delayed(duration, () {
        if (_toastIds.remove(id)) {
          notifyListeners();
        }
      });
    }
  }

  void dismissNotification(int id) {
    _toastIds.remove(id);
    _inbox.removeWhere((notification) => notification.id == id);
    notifyListeners();
  }

  void markAllRead() {
    var changed = false;
    for (final notification in _inbox) {
      if (!notification.read) {
        notification.read = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void clearAll() {
    _inbox.clear();
    _toastIds.clear();
    notifyListeners();
  }
}

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String? sourceKey;
  bool read;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.sourceKey,
    this.read = false,
  });
}

final notificationManagerProvider =
    ChangeNotifierProvider<NotificationManager>((ref) {
  return NotificationManager.instance;
});
