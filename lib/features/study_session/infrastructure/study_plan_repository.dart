import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../domain/study_plan.dart';
import '../domain/study_plan_day.dart';
import '../domain/daily_study_plan.dart';
import '../../../core/config/api_config.dart';

class StudyPlanRepository {
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  String _shortError(String prefix, http.Response response) {
    final body = response.body.trim();
    if (body.isEmpty ||
        body.startsWith('<') ||
        body.toLowerCase().contains('<!doctype')) {
      return '$prefix (HTTP ${response.statusCode})';
    }
    final clipped = body.length > 160 ? '${body.substring(0, 160)}…' : body;
    return '$prefix: $clipped';
  }

  // ---------------------------------------------------------------------------
  // Create plan (AI-powered with difficulty curve)
  // ---------------------------------------------------------------------------
  Future<StudyPlan> createStudyPlan({
    required int totalWords,
    required int numDays,
    required int wordsPerDay,
    String? title,
    String difficultyPref = 'balanced',
    String dailyCommitment = 'standard',
  }) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not authenticated');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/study-plan/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': uid,
        'total_words': totalWords,
        'num_days': numDays,
        'words_per_day': wordsPerDay,
        if (title != null) 'title': title,
        'difficulty_pref': difficultyPref,
        'daily_commitment': dailyCommitment,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(_shortError('Failed to create study plan', response));
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return StudyPlan.fromJson(json);
  }

  Future<DailyStudyPlan> getTodaysPlan({int minutes = 20}) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not authenticated');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/study-plan/$uid/today?minutes=$minutes'),
    );

    if (response.statusCode != 200) {
      throw Exception(_shortError("Failed to load today's study plan", response));
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return DailyStudyPlan.fromJson(json);
  }

  Future<void> completeTodaysPlan({
    required int wordsCompleted,
    required int points,
  }) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not authenticated');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/study-plan/$uid/today/complete'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'words_completed': wordsCompleted,
        'points': points,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_shortError("Failed to complete today's plan", response));
    }
  }

  // -------------------------------------------------------------------------
  // Get active plan(s)
  // ---------------------------------------------------------------------------
  Future<List<StudyPlan>> getActivePlans() async {
    final uid = _userId;
    if (uid == null) return [];

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/study-plan/$uid'),
    );

    if (response.statusCode == 404) return [];
    if (response.statusCode != 200) {
      throw Exception(_shortError('Failed to load study plans', response));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Failed to load study plans');
    }
    final list = decoded;
    final plans = <StudyPlan>[];
    for (final item in list) {
      try {
        plans.add(StudyPlan.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        print('Error parsing study plan: $e');
      }
    }
    return plans;
  }

  // ---------------------------------------------------------------------------
  // Get a specific day's words
  // ---------------------------------------------------------------------------
  Future<StudyPlanDay> getDay(int dayNumber) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not authenticated');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/study-plan/$uid/day/$dayNumber'),
    );

    if (response.statusCode != 200) {
      throw Exception(_shortError('Failed to load day $dayNumber', response));
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return StudyPlanDay.fromJson(json);
  }

  // ---------------------------------------------------------------------------
  // Update day status
  // ---------------------------------------------------------------------------
  Future<void> updateDayStatus(int dayNumber, DayStatus status) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not authenticated');

    final statusStr = status == DayStatus.done ? 'done' : 'in_progress';

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/study-plan/$uid/day/$dayNumber/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': statusStr}),
    );

    if (response.statusCode != 200) {
      throw Exception(_shortError('Failed to update day status', response));
    }
  }

  // ---------------------------------------------------------------------------
  // Delete plan
  // ---------------------------------------------------------------------------
  Future<void> deletePlan(String planId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/study-plan/$planId'),
    );

    if (response.statusCode != 200) {
      throw Exception(_shortError('Failed to delete study plan', response));
    }
  }
}
