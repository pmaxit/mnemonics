import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';

/// Stores FCM device tokens so admin broadcasts can reach phones.
///
/// Prefers Postgres (`DATABASE_URL`) so registrations survive deploys.
/// Falls back to `devices.json` when no database is configured.
class DeviceRegistry {
  DeviceRegistry._({
    String? persistencePath,
    this.pool,
  }) : _filePath = persistencePath == null
            ? null
            : '$persistencePath/devices.json';

  static Future<DeviceRegistry> create({
    String? databaseUrl,
    String? persistencePath,
  }) async {
    Pool? pool;
    final url = databaseUrl ?? Platform.environment['DATABASE_URL'];
    if (url != null && url.trim().isNotEmpty) {
      pool = _openPool(url.trim());
    }
    final registry = DeviceRegistry._(
      persistencePath: persistencePath,
      pool: pool,
    );
    if (pool != null) {
      await registry._ensureSchema();
    }
    await registry._load();
    print('Device registry: ${registry.storeName} (${registry.count} devices)');
    return registry;
  }

  final String? _filePath;
  final Pool? pool;
  final Map<String, RegisteredDevice> _byToken = {};

  String get storeName => pool != null ? 'postgres' : 'file';

  int get count => _byToken.length;

  Future<void> register({
    required String token,
    String? userId,
    String? platform,
  }) async {
    final device = RegisteredDevice(
      token: token,
      userId: userId,
      platform: platform,
      updatedAt: DateTime.now().toUtc(),
    );
    _byToken[token] = device;
    final db = pool;
    if (db != null) {
      try {
        await db.execute(
          Sql.named('''
            INSERT INTO notification_devices (token, user_id, platform, updated_at)
            VALUES (@token, @userId, @platform, @updatedAt)
            ON CONFLICT (token) DO UPDATE SET
              user_id = EXCLUDED.user_id,
              platform = EXCLUDED.platform,
              updated_at = EXCLUDED.updated_at
          '''),
          parameters: {
            'token': device.token,
            'userId': device.userId,
            'platform': device.platform,
            'updatedAt': device.updatedAt,
          },
        );
        return;
      } catch (e) {
        print('Postgres device upsert failed: $e');
      }
    }
    _persistFile();
  }

  List<RegisteredDevice> all() => _byToken.values.toList(growable: false);

  List<RegisteredDevice> forUser(String userId) => _byToken.values
      .where((device) => device.userId == userId)
      .toList(growable: false);

  Future<void> close() async {
    await pool?.close();
  }

  static Pool _openPool(String databaseUrl) {
    final uri = Uri.parse(databaseUrl);
    final userInfo = uri.userInfo.split(':');
    final username =
        userInfo.isEmpty ? 'postgres' : Uri.decodeComponent(userInfo.first);
    final password = userInfo.length > 1
        ? Uri.decodeComponent(userInfo.sublist(1).join(':'))
        : null;
    var database = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
    if (database.contains('?')) {
      database = database.split('?').first;
    }
    if (database.contains('/')) {
      database = database.split('/').first;
    }
    if (database.isEmpty) database = 'railway';

    final sslmode = uri.queryParameters['sslmode'] ?? '';
    final sslMode =
        sslmode == 'disable' ? SslMode.disable : SslMode.require;

    return Pool.withEndpoints(
      [
        Endpoint(
          host: uri.host,
          port: uri.hasPort ? uri.port : 5432,
          database: database,
          username: username,
          password: password,
        ),
      ],
      settings: PoolSettings(
        maxConnectionCount: 3,
        sslMode: sslMode,
      ),
    );
  }

  Future<void> _ensureSchema() async {
    final db = pool;
    if (db == null) return;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notification_devices (
        token TEXT PRIMARY KEY,
        user_id VARCHAR(128),
        platform VARCHAR(32),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_notification_devices_user
        ON notification_devices (user_id)
    ''');
  }

  Future<void> _load() async {
    final db = pool;
    if (db != null) {
      try {
        final rows = await db.execute(
          'SELECT token, user_id, platform, updated_at FROM notification_devices',
        );
        for (final row in rows) {
          final device = RegisteredDevice(
            token: row[0] as String,
            userId: row[1] as String?,
            platform: row[2] as String?,
            updatedAt: (row[3] as DateTime?)?.toUtc() ?? DateTime.now().toUtc(),
          );
          _byToken[device.token] = device;
        }
        return;
      } catch (e) {
        print('Postgres device load failed: $e');
      }
    }
    _loadFile();
  }

  void _loadFile() {
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

  void _persistFile() {
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
