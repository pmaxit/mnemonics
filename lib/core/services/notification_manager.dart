import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A simple notification manager to show in-app notifications
class NotificationManager extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  void showNotification({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 5),
  }) {
    final id = DateTime.now().millisecondsSinceEpoch;
    final notification = NotificationItem(
      id: id,
      title: title,
      message: message,
      timestamp: DateTime.now(),
    );
    
    _notifications.add(notification);
    notifyListeners();
    
    // Auto-remove after duration
    Future.delayed(duration, () {
      _removeNotification(id);
    });
  }
  
  void dismissNotification(int id) {
    _removeNotification(id);
  }
  
  void _removeNotification(int id) {
    _notifications.removeWhere((notification) => notification.id == id);
    notifyListeners();
  }
}

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final DateTime timestamp;
  
  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
  });
}

final notificationManagerProvider = ChangeNotifierProvider<NotificationManager>((ref) {
  return NotificationManager();
});