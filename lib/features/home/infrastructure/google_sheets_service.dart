import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import '../domain/vocabulary_word.dart';
import '../../profile/services/data_migration_service.dart';

class GoogleSheetsService {
  static const String _credentialsPath = 'assets/credentials.json';
  static const String _spreadsheetId = '1DkfyiJh5P9Zcq5L7LimYGrHZzKHVHjM-uBmsdFkkTHM';
  static const String _range = 'Sheet1!A:L'; // Columns A through L based on the sheet structure
  static const List<String> _scopes = [SheetsApi.spreadsheetsReadonlyScope];
  
  SheetsApi? _sheetsApi;
  DateTime? _lastFetchTime;
  List<VocabularyWord>? _cachedWords;
  static const Duration _cacheTimeout = Duration(hours: 1);

  Future<SheetsApi> _getSheetsApi() async {
    if (_sheetsApi != null) return _sheetsApi!;

    try {
      // Load service account credentials
      final credentialsJson = await rootBundle.loadString(_credentialsPath);
      final credentials = ServiceAccountCredentials.fromJson(
        json.decode(credentialsJson),
      );

      // Create authenticated HTTP client
      final httpClient = await clientViaServiceAccount(credentials, _scopes);
      
      // Initialize Sheets API
      _sheetsApi = SheetsApi(httpClient);
      return _sheetsApi!;
    } catch (e) {
      throw Exception('Failed to initialize Google Sheets API: $e');
    }
  }

  Future<List<VocabularyWord>> fetchVocabulary({bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh && 
        _cachedWords != null && 
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheTimeout) {
      return _cachedWords!;
    }

    try {
      final sheetsApi = await _getSheetsApi();
      
      // Fetch data from Google Sheets
      final response = await sheetsApi.spreadsheets.values.get(
        _spreadsheetId,
        _range,
      );

      final values = response.values;
      if (values == null || values.isEmpty) {
        throw Exception('No data found in Google Sheets');
      }

      // Skip header row and convert to VocabularyWord objects
      final words = <VocabularyWord>[];
      for (int i = 1; i < values.length; i++) {
        try {
          final row = values[i];
          if (row.isEmpty) continue;

          final word = _parseRowToVocabularyWord(row);
          if (word != null) {
            words.add(word);
          }
        } catch (e) {
          print('Error parsing row $i: $e');
          // Continue with other rows even if one fails
        }
      }

      // Update cache
      _cachedWords = words;
      _lastFetchTime = DateTime.now();

      return words;
    } catch (e) {
      // If we have cached data, return it during network errors
      if (_cachedWords != null) {
        print('Network error, returning cached data: $e');
        return _cachedWords!;
      }
      
      throw Exception('Failed to fetch vocabulary from Google Sheets: $e');
    }
  }

  VocabularyWord? _parseRowToVocabularyWord(List<Object?> row) {
    try {
      // Ensure we have enough columns based on your sheet structure
      while (row.length < 12) {
        row.add('');
      }

      // Helper function to safely get string value
      String getValue(int index) {
        if (index >= row.length) return '';
        return row[index]?.toString() ?? '';
      }

      // Helper function to parse list from comma-separated string
      List<String> parseList(String value) {
        if (value.isEmpty) return [];
        return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }

      // Parse the row based on your Google Sheets column structure:
      // A=word, B=meaning, C=mnemonic, D=image, E=video, F=example, 
      // G=synonyms, H=antonyms, I=difficulty, J=category, K=setIds
      final word = getValue(0).trim(); // Column A
      final meaning = getValue(1).trim(); // Column B
      final mnemonic = getValue(2).trim(); // Column C
      final imageUrl = getValue(3).trim(); // Column D
      final videoUrl = getValue(4).trim(); // Column E (not used in current model)
      final example = getValue(5).trim(); // Column F
      final synonyms = parseList(getValue(6)); // Column G
      final antonyms = parseList(getValue(7)); // Column H
      final difficulty = getValue(8).trim(); // Column I
      final category = getValue(9).trim(); // Column J
      final setIds = parseList(getValue(10)); // Column K

      // Validate required fields
      if (word.isEmpty || meaning.isEmpty) {
        return null;
      }

      return VocabularyWord(
        word: word,
        meaning: meaning,
        mnemonic: mnemonic.isEmpty ? 'No mnemonic available' : mnemonic,
        example: example.isEmpty ? 'No example available' : example,
        category: category.isEmpty ? 'General' : category,
        difficulty: DataMigrationService.migrateDifficultyFromString(difficulty.isNotEmpty ? difficulty : 'medium'),
        synonyms: synonyms,
        antonyms: antonyms,
        image: imageUrl.isEmpty ? null : imageUrl,
        video: videoUrl.isEmpty ? null : videoUrl,
        setIds: setIds,
      );
    } catch (e) {
      print('Error parsing vocabulary word from row: $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    _cachedWords = null;
    _lastFetchTime = null;
  }

  Future<List<String>> getAvailableCategories() async {
    final words = await fetchVocabulary();
    final categories = words.map((w) => w.category).toSet().toList();
    categories.sort();
    return categories;
  }

  Future<List<String>> getAvailableWordSets() async {
    final words = await fetchVocabulary();
    final wordSets = <String>{};
    for (final word in words) {
      wordSets.addAll(word.setIds);
    }
    final sortedWordSets = wordSets.toList();
    sortedWordSets.sort();
    return sortedWordSets;
  }

  bool get hasCachedData => _cachedWords != null;
  
  DateTime? get lastFetchTime => _lastFetchTime;
  
  int get cachedWordsCount => _cachedWords?.length ?? 0;
}