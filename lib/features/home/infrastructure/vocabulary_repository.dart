import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/vocabulary_word.dart';
import '../../profile/services/data_migration_service.dart';
import 'google_sheets_service.dart';

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return VocabularyRepository();
});

class VocabularyRepository {
  static const String _jsonPath = 'assets/vocabulary.json';
  final GoogleSheetsService _googleSheetsService = GoogleSheetsService();

  Future<List<VocabularyWord>> loadVocabulary({bool forceRefresh = false}) async {
    try {
      // Try to load from Google Sheets first
      return await _googleSheetsService.fetchVocabulary(forceRefresh: forceRefresh);
    } catch (e) {
      print('Error loading vocabulary from Google Sheets: $e');
      
      // Fallback to local JSON file if Google Sheets fails
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
    return jsonList.map((e) => DataMigrationService.migrateVocabularyWord(e as Map<String, dynamic>)).toList();
  }

  Future<List<String>> getAvailableCategories() async {
    try {
      return await _googleSheetsService.getAvailableCategories();
    } catch (e) {
      print('Error getting categories from Google Sheets: $e');
      // Fallback to extracting categories from local data
      final words = await _loadVocabularyFromJson();
      final categories = words.map((w) => w.category).toSet().toList();
      categories.sort();
      return categories;
    }
  }

  Future<List<String>> getAvailableWordSets() async {
    try {
      return await _googleSheetsService.getAvailableWordSets();
    } catch (e) {
      print('Error getting word sets from Google Sheets: $e');
      // Fallback to extracting word sets from local data
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
      await _googleSheetsService.clearCache();
      await loadVocabulary(forceRefresh: true);
    } catch (e) {
      print('Error refreshing vocabulary: $e');
      rethrow;
    }
  }

  bool get hasCachedData => _googleSheetsService.hasCachedData;
  
  DateTime? get lastFetchTime => _googleSheetsService.lastFetchTime;
  
  int get cachedWordsCount => _googleSheetsService.cachedWordsCount;
} 