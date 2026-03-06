import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/vocabulary_word.dart';
import '../../profile/services/data_migration_service.dart';

class MysqlDatabaseService {
  static const String _apiUrl =
      'https://mnemonics-api-1078980357394.us-central1.run.app/vocabulary';

  DateTime? _lastFetchTime;
  List<VocabularyWord>? _cachedWords;
  static const Duration _cacheTimeout = Duration(hours: 1);

  Future<List<VocabularyWord>> fetchVocabulary(
      {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedWords != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheTimeout) {
      return _cachedWords!;
    }

    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to load vocabulary: ${response.statusCode}');
      }

      final List<dynamic> jsonList = json.decode(response.body);
      final words = <VocabularyWord>[];

      for (var row in jsonList) {
        try {
          List<String> parseList(String? value) {
            if (value == null || value.isEmpty) return [];
            return value
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
          }

          final word = row['word']?.toString().trim() ?? '';
          final meaning = row['meaning']?.toString().trim() ?? '';

          if (word.isEmpty || meaning.isEmpty) continue;

          final mnemonic = row['mnemonic']?.toString().trim() ?? '';
          final imageUrl = row['imageUrl']?.toString().trim() ?? '';
          final videoUrl = row['videoUrl']?.toString().trim() ?? '';
          final example = row['example']?.toString().trim() ?? '';
          final synonyms = parseList(row['synonyms']?.toString());
          final antonyms = parseList(row['antonyms']?.toString());
          final difficulty = row['difficulty']?.toString().trim() ?? '';
          final category = row['category']?.toString().trim() ?? '';
          final setIds = parseList(row['setIds']?.toString());
          final aiMnemonic = row['aiMnemonic']?.toString().trim() ?? '';
          final aiInsights = row['aiInsights']?.toString().trim() ?? '';

          final vocabWord = VocabularyWord(
            word: word,
            meaning: meaning,
            mnemonic: mnemonic.isEmpty ? 'No mnemonic available' : mnemonic,
            example: example.isEmpty ? 'No example available' : example,
            category: category.isEmpty ? 'General' : category,
            difficulty: DataMigrationService.migrateDifficultyFromString(
                difficulty.isNotEmpty ? difficulty : 'medium'),
            synonyms: synonyms,
            antonyms: antonyms,
            image: imageUrl.isEmpty ? null : imageUrl,
            video: videoUrl.isEmpty ? null : videoUrl,
            aiMnemonic: aiMnemonic.isEmpty ? null : aiMnemonic,
            aiInsights: aiInsights.isEmpty ? null : aiInsights,
            setIds: setIds,
          );
          words.add(vocabWord);
        } catch (e) {
          print('Error parsing word row: $e');
        }
      }

      _cachedWords = words;
      _lastFetchTime = DateTime.now();

      return words;
    } catch (e) {
      if (_cachedWords != null) {
        print('Network error, returning cached data: $e');
        return _cachedWords!;
      }
      throw Exception('Failed to fetch from MySQL API: $e');
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
