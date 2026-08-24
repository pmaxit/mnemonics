import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Posts a system (lock-screen / Notification Center) notification on iOS.
class LocalNotifications {
  static const _channel = MethodChannel('mnemonics/local_notifications');

  static Future<bool> requestPermission() async {
    try {
      final granted = await _channel.invokeMethod<bool>('requestPermission');
      return granted ?? false;
    } catch (e) {
      debugPrint('LocalNotifications.requestPermission failed: $e');
      return false;
    }
  }

  static Future<void> prime() async {
    try {
      await _channel.invokeMethod<void>('prime');
    } catch (e) {
      debugPrint('LocalNotifications.prime failed: $e');
    }
  }

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
