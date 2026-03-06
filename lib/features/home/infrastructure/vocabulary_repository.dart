import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/vocabulary_word.dart';
import '../../profile/services/data_migration_service.dart';
import 'mysql_database_service.dart';

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return VocabularyRepository();
});

class VocabularyRepository {
  static const String _jsonPath = 'assets/vocabulary.json';
  final MysqlDatabaseService _mysqlService = MysqlDatabaseService();

  Future<List<VocabularyWord>> loadVocabulary(
      {bool forceRefresh = false}) async {
    try {
      // Try to load from MySQL database first
      return await _mysqlService.fetchVocabulary(forceRefresh: forceRefresh);
    } catch (e) {
      print('Error loading vocabulary from MySQL: $e');

      // Fallback to local JSON file
      try {
        print('Falling back to local vocabulary.json');
        return await _loadVocabularyFromJson();
      } catch (jsonError) {
        print('Error loading vocabulary from JSON: $jsonError');
        return [];
      }
    }
  }

  Future<List<VocabularyWord>> _loadVocabularyFromJson() async {
    final jsonString = await rootBundle.loadString(_jsonPath);
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map((e) => DataMigrationService.migrateVocabularyWord(
            e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> getAvailableCategories() async {
    try {
      return await _mysqlService.getAvailableCategories();
    } catch (e) {
      print('Error getting categories from MySQL: $e');
      // Fallback
      final words = await _loadVocabularyFromJson();
      final categories = words.map((w) => w.category).toSet().toList();
      categories.sort();
      return categories;
    }
  }

  Future<List<String>> getAvailableWordSets() async {
    try {
      return await _mysqlService.getAvailableWordSets();
    } catch (e) {
      print('Error getting word sets from MySQL: $e');
      // Fallback
      final words = await _loadVocabularyFromJson();
      final wordSets = <String>{};
      for (final word in words) {
        wordSets.addAll(word.setIds);
      }
      final sortedWordSets = wordSets.toList();
      sortedWordSets.sort();
      return sortedWordSets;
    }
  }

  Future<void> refreshVocabulary() async {
    try {
      await _mysqlService.clearCache();
      await loadVocabulary(forceRefresh: true);
    } catch (e) {
      print('Error refreshing vocabulary: $e');
      rethrow;
    }
  }

  bool get hasCachedData => _mysqlService.hasCachedData;

  DateTime? get lastFetchTime => _mysqlService.lastFetchTime;

  int get cachedWordsCount => _mysqlService.cachedWordsCount;
}
