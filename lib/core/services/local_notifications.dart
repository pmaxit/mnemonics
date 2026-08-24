import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Posts a system (lock-screen / Notification Center) notification on iOS.
class LocalNotifications {
  static const _channel = MethodChannel('mnemonics/local_notifications');

  static Future<void> show({
    required String title,
    required String body,
    String? id,
  }) async {
    try {
      await _channel.invokeMethod<void>('show', {
        'title': title,
        'body': body,
        if (id != null) 'id': id,
      });
    } catch (e) {
      debugPrint('LocalNotifications.show failed: $e');
    }
  }
}
