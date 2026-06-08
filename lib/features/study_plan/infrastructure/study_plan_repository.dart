import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/study_plan.dart';
import '../../../../core/config/api_config.dart';

class StudyPlanRepository {
  /// Create a new study plan via the agentic backend
  Future<StudyPlan> createStudyPlan({
    required int totalWords,
    required int wordsPerDay,
    required String startDate,
    String userId = 'default',
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/study-plans'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'total_words': totalWords,
        'words_per_day': wordsPerDay,
        'start_date': startDate,
        'user_id': userId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create study plan: ${response.body}');
    }

    final data = json.decode(response.body);
    // The create endpoint returns a slightly different structure,
    // so we need to adapt it
    return StudyPlan(
      id: data['plan_id'],
      totalWords: data['total_words'],
      wordsPerDay: data['words_per_day'],
      totalDays: data['total_days'],
      startDate: data['start_date'],
      status: data['status'] ?? 'active',
    );
  }

  /// List all study plans for a user
  Future<List<StudyPlan>> listStudyPlans({String userId = 'default'}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/study-plans?user_id=$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to list study plans: ${response.body}');
    }

    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((j) => StudyPlan.fromJson(j)).toList();
  }

  /// Get full plan with day statuses (for calendar view)
  Future<StudyPlan> getStudyPlan(int planId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/study-plans/$planId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get study plan: ${response.body}');
    }

    return StudyPlan.fromJson(json.decode(response.body));
  }

  /// Get the word list for a specific day
  Future<StudyPlanDayDetail> getStudyPlanDay(int planId, int dayNum) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/study-plans/$planId/days/$dayNum'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get study plan day: ${response.body}');
    }

    return StudyPlanDayDetail.fromJson(json.decode(response.body));
  }

  /// Update the status of a word
  Future<Map<String, String>> updateWordStatus({
    required int planId,
    required int dayNum,
    required String word,
    required String status,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/study-plans/$planId/days/$dayNum/words/$word'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update word status: ${response.body}');
    }

    final data = json.decode(response.body);
    return {
      'word_status': data['word_status'],
      'day_status': data['day_status'],
    };
  }
}
