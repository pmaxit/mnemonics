import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/vocabulary_word.dart';

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return VocabularyRepository();
});

class VocabularyRepository {
  static const String _jsonPath = 'assets/vocabulary.json';

  Future<List<VocabularyWord>> loadVocabulary() async {
    try {
      final jsonString = await rootBundle.loadString(_jsonPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => VocabularyWord.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Handle error: log, rethrow, or return empty list
      print('Error loading vocabulary: $e');
      return [];
    }
  }
} 