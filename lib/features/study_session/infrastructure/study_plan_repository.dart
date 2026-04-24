import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../domain/study_plan.dart';
import '../domain/study_plan_day.dart';

class StudyPlanRepository {
  static const String _baseUrl =
      'https://mnemonics-api-1078980357394.us-central1.run.app';

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // -------------------------------------------------------------------------
  // Create plan (agentic)
  // -------------------------------------------------------------------------
  Future<StudyPlan> createStudyPlan({
    required int totalWords,
    required int numDays,
    required int wordsPerDay,
    String? title,
  }) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not authenticated');

    final response = await http.post(
      Uri.parse('$_baseUrl/study-plan/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': uid,
        'total_words': totalWords,
        'num_days': numDays,
        'words_per_day': wordsPerDay,
        if (title != null) 'title': title,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create study plan: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return StudyPlan.fromJson(json);
  }

  // -------------------------------------------------------------------------
  // Get active plan(s)
  // -------------------------------------------------------------------------
  Future<List<StudyPlan>> getActivePlans() async {
    final uid = _userId;
    if (uid == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/study-plan/$uid'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load study plans: ${response.body}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    final plans = <StudyPlan>[];
    for (final item in list) {
      try {
        plans.add(StudyPlan.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        // Log the error and continue to the next plan
        print('Error parsing study plan: $e');
      }
    }
    return plans;
  }

  // -------------------------------------------------------------------------
  // Get a specific day's words
  // -------------------------------------------------------------------------
  Future<StudyPlanDay> getDay(int dayNumber) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not authenticated');

    final response = await http.get(
      Uri.parse('$_baseUrl/study-plan/$uid/day/$dayNumber'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load day $dayNumber: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return StudyPlanDay.fromJson(json);
  }

  // -------------------------------------------------------------------------
  // Update day status
  // -------------------------------------------------------------------------
  Future<void> updateDayStatus(int dayNumber, DayStatus status) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not authenticated');

    final statusStr = status == DayStatus.done ? 'done' : 'in_progress';

    final response = await http.post(
      Uri.parse('$_baseUrl/study-plan/$uid/day/$dayNumber/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': statusStr}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update day status: ${response.body}');
    }
  }

  // -------------------------------------------------------------------------
  // Delete plan
  // -------------------------------------------------------------------------
  Future<void> deletePlan(String planId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/study-plan/$planId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete study plan: ${response.body}');
    }
  }
}
