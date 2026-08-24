import 'dart:convert';
import 'dart:io';

/// Stores FCM device tokens so admin broadcasts can reach phones.
class DeviceRegistry {
  DeviceRegistry({String? persistencePath})
      : _filePath = persistencePath == null
            ? null
            : '$persistencePath/devices.json' {
    _load();
  }

  final String? _filePath;
  final Map<String, RegisteredDevice> _byToken = {};

  int get count => _byToken.length;

  void register({
    required String token,
    String? userId,
    String? platform,
  }) {
    _byToken[token] = RegisteredDevice(
      token: token,
      userId: userId,
      platform: platform,
      updatedAt: DateTime.now().toUtc(),
    );
    _persist();
  }

  List<RegisteredDevice> all() => _byToken.values.toList(growable: false);

  List<RegisteredDevice> forUser(String userId) => _byToken.values
      .where((device) => device.userId == userId)
      .toList(growable: false);

  void _load() {
    final path = _filePath;
    if (path == null) return;
    try {
      final file = File(path);
      if (!file.existsSync()) return;
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! List) return;
      for (final item in decoded) {
        if (item is! Map) continue;
        final device = RegisteredDevice.fromJson(
          Map<String, dynamic>.from(item),
        );
        _byToken[device.token] = device;
      }
    } catch (_) {}
  }

  void _persist() {
    final path = _filePath;
    if (path == null) return;
    try {
      File(path).writeAsStringSync(
        jsonEncode(_byToken.values.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }
}

class RegisteredDevice {
  RegisteredDevice({
    required this.token,
    this.userId,
    this.platform,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now().toUtc();

  final String token;
  final String? userId;
  final String? platform;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'token': token,
        'userId': userId,
        'platform': platform,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory RegisteredDevice.fromJson(Map<String, dynamic> json) =>
      RegisteredDevice(
        token: json['token'] as String,
        userId: json['userId'] as String?,
        platform: json['platform'] as String?,
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now().toUtc(),
      );
}
