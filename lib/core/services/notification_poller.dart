import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:mnemonics/core/config/notification_api_config.dart';
import 'package:mnemonics/core/platform/desktop_compat.dart';
import 'package:mnemonics/core/services/local_notifications.dart';
import 'package:mnemonics/core/services/notification_manager.dart';
import 'package:path_provider/path_provider.dart';

/// Pulls notifications the admin marked as sent and shows them in-app.
///
/// The admin UI does not send FCM. It creates a row then POSTs
/// `/api/notifications/:id/send`. This poller is how the phone sees those.
class NotificationPoller with WidgetsBindingObserver {
  NotificationPoller._();
  static final NotificationPoller instance = NotificationPoller._();

  static const _pollInterval = Duration(seconds: 5);
  static const _firstLaunchGrace = Duration(seconds: 45);

  Timer? _timer;
  bool _started = false;
  bool _loaded = false;
  bool _busy = false;
  final Set<String> _seenIds = {};

  Future<void> start() async {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    await _loadSeen();
    await poll();
    _timer = Timer.periodic(_pollInterval, (_) => poll());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    if (_started) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _started = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      poll();
    }
  }

  Future<void> markSeen(String id) async {
    if (_seenIds.add(id)) {
      await _saveSeen();
    }
  }

  Future<void> poll() async {
    if (_busy) return;
    _busy = true;
    try {
      final uri = Uri.parse(
        '${NotificationApiConfig.baseUrl}/api/notifications',
      ).replace(queryParameters: {
        'status': 'sent',
        'limit': '30',
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        developer.log(
          'Notification poll failed: ${response.statusCode}',
          name: 'NotificationPoller',
        );
        return;
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final raw = decoded['notifications'] as List<dynamic>? ?? [];
      final items = raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      if (_seenIds.isEmpty) {
        final cutoff = DateTime.now().subtract(_firstLaunchGrace);
        for (final item in items) {
          final id = item['id'] as String?;
          if (id == null) continue;
          final sentAt = DateTime.tryParse(
                item['sentAt'] as String? ?? '',
              ) ??
              DateTime.tryParse(item['createdAt'] as String? ?? '');
          if (sentAt != null && sentAt.isBefore(cutoff)) {
            _seenIds.add(id);
          }
        }
        await _saveSeen();
      }

      final userId = _currentUserId();
      final fresh = <Map<String, dynamic>>[];
      for (final item in items.reversed) {
        final id = item['id'] as String?;
        if (id == null || _seenIds.contains(id)) continue;
        final target = item['targetUserId'] as String?;
        if (target != null &&
            target.isNotEmpty &&
            userId != null &&
            target != userId) {
          _seenIds.add(id);
          continue;
        }
        fresh.add(item);
      }

      for (final item in fresh) {
        final id = item['id'] as String;
        _seenIds.add(id);
        NotificationManager.instance.showNotification(
          title: item['title'] as String? ?? 'Notification',
          message: item['body'] as String? ?? '',
          sourceKey: id,
          showToast: false,
        );
        await LocalNotifications.show(
          title: item['title'] as String? ?? 'Notification',
          body: item['body'] as String? ?? '',
          id: id,
        );
      }
      if (fresh.isNotEmpty) await _saveSeen();
    } catch (e) {
      developer.log('Notification poll error: $e', name: 'NotificationPoller');
    } finally {
      _busy = false;
    }
  }

  String? _currentUserId() {
    if (desktopAuthBypass) return desktopLocalUserId;
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  Future<File> _seenFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/seen_admin_notifications.json');
  }

  Future<void> _loadSeen() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final file = await _seenFile();
      if (!await file.exists()) return;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is List) {
        _seenIds.addAll(decoded.whereType<String>());
      }
    } catch (_) {}
  }

  Future<void> _saveSeen() async {
    try {
      final file = await _seenFile();
      final ids = _seenIds.toList();
      if (ids.length > 200) {
        ids.removeRange(0, ids.length - 200);
        _seenIds
          ..clear()
          ..addAll(ids);
      }
      await file.writeAsString(jsonEncode(ids));
    } catch (_) {}
  }
}
