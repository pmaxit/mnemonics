import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';

class ApiService {
  final http.Client _client;
  final String baseUrl;
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? ApiConfig.baseUrl;

  Future<DashboardStats> fetchStats() async {
    final r = await _client.get(Uri.parse('$baseUrl/api/stats'));
    _check(r);
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    return DashboardStats.fromJson(j);
  }

  Future<Map<String, dynamic>> fetchHealth() async {
    final r = await _client.get(Uri.parse('$baseUrl/api/health'));
    _check(r);
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<List<ActivityLogEntry>> fetchLogs({int limit = 50, int offset = 0}) async {
    final r = await _client.get(Uri.parse('$baseUrl/api/activity-logs?limit=$limit&offset=$offset'));
    _check(r);
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    return (j['logs'] as List).map((e) => ActivityLogEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, int>> fetchLogTypes() async {
    final r = await _client.get(Uri.parse('$baseUrl/api/activity-logs/types'));
    _check(r);
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    return j.map((k, v) => MapEntry(k, v as int));
  }

  Future<List<AppNotification>> fetchNotifications({int limit = 50, String? scheme, String? status}) async {
    final q = <String, String>{'limit': '$limit'};
    if (scheme != null) q['schemeType'] = scheme;
    if (status != null) q['status'] = status;
    final uri = Uri.parse('$baseUrl/api/notifications').replace(queryParameters: q);
    final r = await _client.get(uri);
    _check(r);
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    return (j['notifications'] as List).map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AppNotification> createNotification({
    required String title,
    required String body,
    required NotificationSchemeType schemeType,
    NotificationPriority priority = NotificationPriority.medium,
    String? targetUserId,
    String? targetUserSegment,
  }) async {
    final payload = {
      'title': title,
      'body': body,
      'schemeType': schemeType.name,
      'priority': priority.name,
      if (targetUserId != null && targetUserId.isNotEmpty) 'targetUserId': targetUserId,
      if (targetUserSegment != null && targetUserSegment.isNotEmpty) 'targetUserSegment': targetUserSegment,
    };
    final r = await _client.post(
      Uri.parse('$baseUrl/api/notifications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    _check(r);
    return AppNotification.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<void> sendNotification(String id) async {
    final r = await _client.post(Uri.parse('$baseUrl/api/notifications/$id/send'));
    _check(r);
  }

  Future<List<AgentSuggestion>> fetchSuggestions({bool pendingOnly = false}) async {
    final uri = Uri.parse('$baseUrl/api/suggestions${pendingOnly ? '?pending=true' : ''}');
    final r = await _client.get(uri);
    _check(r);
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    return (j['suggestions'] as List).map((e) => AgentSuggestion.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<AgentSuggestion>> triggerAgent() async {
    final r = await _client.post(Uri.parse('$baseUrl/api/agent/analyze'));
    _check(r);
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    return (j['suggestions'] as List).map((e) => AgentSuggestion.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> applySuggestion(String id) async {
    final r = await _client.post(Uri.parse('$baseUrl/api/suggestions/$id/apply'));
    _check(r);
  }

  Future<void> discardSuggestion(String id) async {
    final r = await _client.post(Uri.parse('$baseUrl/api/suggestions/$id/discard'));
    _check(r);
  }

  void _check(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('API ${r.statusCode}: ${r.body}');
    }
  }
}
