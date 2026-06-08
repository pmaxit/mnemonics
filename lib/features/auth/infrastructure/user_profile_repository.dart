import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile.dart';
import '../../../core/config/api_config.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository();
});

class UserProfileRepository {
  Future<UserProfile?> getUserProfile(String userId) async {
    final response = await http.get(Uri.parse(ApiConfig.userProfile(userId)));

    if (response.statusCode == 200) {
      return UserProfile.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final response = await http.post(
      Uri.parse(ApiConfig.userProfile(profile.userId)),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(profile.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save user profile: ${response.statusCode}');
    }
  }

  Future<void> curateOnboarding({
    required String userId,
    required String goal,
    required int score,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/onboarding/curate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'goal': goal,
        'score': score,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to curate onboarding: ${response.statusCode}');
    }
  }

  Future<String> getSettingsSummary(String level, String enabledSets) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/settings/summary'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'level': level,
        'enabled_sets': enabledSets,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['summary'] ?? '';
    }
    return 'Your journey continues at Level $level with $enabledSets.';
  }
}
