import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/vocabulary_word.dart';
import '../../profile/services/data_migration_service.dart';
import '../../../core/config/api_config.dart';

class MysqlDatabaseService {
  static const String _apiUrl = ApiConfig.vocabulary;

  DateTime? _lastFetchTime;
  List<VocabularyWord>? _cachedWords;
  static const Duration _cacheTimeout = Duration(hours: 1);

  Future<List<VocabularyWord>> fetchVocabulary(
      {bool forceRefresh = false, String? userId}) async {
    if (!forceRefresh &&
        _cachedWords != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheTimeout) {
      return _cachedWords!;
    }

    try {
      final uri = Uri.parse(_apiUrl).replace(
        queryParameters: userId != null ? {'user_id': userId} : null,
      );
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to load vocabulary: ${response.statusCode}');
      }

      final List<dynamic> jsonList = json.decode(response.body);
      final words = <VocabularyWord>[];

      for (var row in jsonList) {
        try {
          final word = row['word']?.toString().trim() ?? '';
          final meaning = row['meaning']?.toString().trim() ?? '';

          if (word.isEmpty || meaning.isEmpty) continue;

          final mnemonic = row['mnemonic']?.toString().trim() ?? '';
          final imageUrl =
              (row['imageUrl'] ?? row['image_url'])?.toString().trim() ?? '';
          final videoUrl =
              (row['videoUrl'] ?? row['video_url'])?.toString().trim() ?? '';
          final example = row['example']?.toString().trim() ?? '';
          final synonyms = parseStringList(row['synonyms']);
          final antonyms = parseStringList(row['antonyms']);
          final difficulty = row['difficulty']?.toString().trim() ?? '';
          final category = row['category']?.toString().trim() ?? '';
          final setIds = parseStringList(row['setIds'] ?? row['set_ids']);
          final aiMnemonic =
              (row['aiMnemonic'] ?? row['ai_mnemonic'])?.toString().trim() ??
                  '';
          final aiInsights =
              (row['aiInsights'] ?? row['ai_insights'])?.toString().trim() ??
                  '';
          final definition = row['definition']?.toString().trim();

          final parsedPhrases =
              const PhrasesConverter().fromJson(row['phrases']);
          final parsedExampleSentences =
              const ExampleSentencesConverter().fromJson(
            row['exampleSentences'] ?? row['example_sentences'],
          );

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
            definition: definition?.isEmpty ?? true ? null : definition,
            phrases: parsedPhrases,
            exampleSentences: parsedExampleSentences,
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
    final categories = <String>{};
    for (final word in words) {
      if (word.category.isNotEmpty) {
        categories.add(word.category);
      }
    }
    final sortedWordSets = categories.toList();
    sortedWordSets.sort();
    return sortedWordSets;
  }

  bool get hasCachedData => _cachedWords != null;
  DateTime? get lastFetchTime => _lastFetchTime;
  int get cachedWordsCount => _cachedWords?.length ?? 0;
}
