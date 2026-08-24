import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final statsProvider = FutureProvider<DashboardStats>((ref) async {
  return ref.read(apiServiceProvider).fetchStats();
});

final activityLogsProvider = FutureProvider<List<ActivityLogEntry>>((ref) async {
  return ref.read(apiServiceProvider).fetchLogs(limit: 50);
});

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  return ref.read(apiServiceProvider).fetchNotifications(limit: 50);
});

final suggestionsProvider = FutureProvider<List<AgentSuggestion>>((ref) async {
  return ref.read(apiServiceProvider).fetchSuggestions();
});

final apiBaseUrlProvider = Provider<String>((ref) => ref.read(apiServiceProvider).baseUrl);
