import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../home/domain/vocabulary_word.dart';
import '../../home/domain/user_word_data.dart';
import '../../home/infrastructure/vocabulary_repository.dart';
import '../../home/infrastructure/user_word_data_repository.dart';
import '../presentation/screens/detailed_word_statistics_screen.dart';
import '../domain/user_statistics.dart';

part 'detailed_statistics_provider.g.dart';

class WordWithUserData {
  final VocabularyWord word;
  final UserWordData? userData;

  WordWithUserData({
    required this.word,
    this.userData,
  });
}

class FilterParams {
  final WordStatType statType;
  final String? categoryFilter;
  final String searchQuery;
  final String sortBy;
  final bool sortAscending;
  final int page;
  final int pageSize;

  FilterParams({
    required this.statType,
    this.categoryFilter,
    this.searchQuery = '',
    this.sortBy = 'word',
    this.sortAscending = true,
    this.page = 0,
    this.pageSize = 20,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterParams &&
          runtimeType == other.runtimeType &&
          statType == other.statType &&
          categoryFilter == other.categoryFilter &&
          searchQuery == other.searchQuery &&
          sortBy == other.sortBy &&
          sortAscending == other.sortAscending &&
          page == other.page &&
          pageSize == other.pageSize;

  @override
  int get hashCode =>
      statType.hashCode ^
      categoryFilter.hashCode ^
      searchQuery.hashCode ^
      sortBy.hashCode ^
      sortAscending.hashCode ^
      page.hashCode ^
      pageSize.hashCode;
}

@riverpod
Future<List<WordWithUserData>> filteredWords(
  FilteredWordsRef ref,
  FilterParams params,
) async {
  try {
    // Get all vocabulary words and user data
    final vocabularyRepo = ref.read(vocabularyRepositoryProvider);
    final userWordRepo = ref.read(userWordDataRepositoryProvider);

    final allWords = await vocabularyRepo.loadVocabulary();
    final allUserData = await userWordRepo.getAllUserWordData();

    // Create map for quick lookup of user data
    final userDataMap = <String, UserWordData>{
      for (final data in allUserData) data.word: data
    };

    // Create combined data list
    List<WordWithUserData> combinedData = allWords.map((word) {
      return WordWithUserData(
        word: word,
        userData: userDataMap[word.word],
      );
    }).toList();

    // Apply stat type filter
    combinedData = _filterByStatType(combinedData, params.statType);

    // Apply category filter
    if (params.categoryFilter != null && params.categoryFilter!.isNotEmpty) {
      combinedData = combinedData.where((item) {
        return item.word.category.toLowerCase() ==
            params.categoryFilter!.toLowerCase();
      }).toList();
    }

    // Apply search filter
    if (params.searchQuery.isNotEmpty) {
      final query = params.searchQuery.toLowerCase();
      combinedData = combinedData.where((item) {
        return item.word.word.toLowerCase().contains(query) ||
            item.word.meaning.toLowerCase().contains(query) ||
            item.word.mnemonic.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    combinedData =
        _sortWords(combinedData, params.sortBy, params.sortAscending);

    // Apply pagination
    final startIndex = params.page * params.pageSize;
    final endIndex =
        (startIndex + params.pageSize).clamp(0, combinedData.length);

    if (startIndex >= combinedData.length) {
      return [];
    }

    return combinedData.sublist(startIndex, endIndex);
  } catch (e) {
    throw Exception('Failed to load filtered words: $e');
  }
}

List<WordWithUserData> _filterByStatType(
    List<WordWithUserData> words, WordStatType statType) {
  switch (statType) {
    case WordStatType.learned:
      return words.where((item) {
        return item.userData?.learningStage == 'mastered' ||
            item.userData?.isLearned == true;
      }).toList();

    case WordStatType.struggling:
      return words.where((item) {
        final userData = item.userData;
        if (userData == null || userData.totalAnswers == 0) return false;
        return userData.accuracyRate < 0.6; // Less than 60% accuracy
      }).toList();

    case WordStatType.newWords:
      return words.where((item) {
        return item.userData == null ||
            item.userData!.learningStage == 'new' ||
            item.userData!.reviewCount == 0;
      }).toList();

    case WordStatType.basic:
      return words.where((item) {
        return item.word.difficulty == WordDifficulty.basic;
      }).toList();

    case WordStatType.intermediate:
      return words.where((item) {
        return item.word.difficulty == WordDifficulty.intermediate;
      }).toList();

    case WordStatType.advanced:
      return words.where((item) {
        return item.word.difficulty == WordDifficulty.advanced;
      }).toList();

    case WordStatType.category:
      // Category filtering is handled separately
      return words;

    case WordStatType.allWords:
      return words;
  }
}

List<WordWithUserData> _sortWords(
    List<WordWithUserData> words, String sortBy, bool ascending) {
  words.sort((a, b) {
    int comparison = 0;

    switch (sortBy) {
      case 'word':
        comparison = a.word.word.compareTo(b.word.word);
        break;

      case 'accuracy':
        final aAccuracy = a.userData?.accuracyRate ?? 0.0;
        final bAccuracy = b.userData?.accuracyRate ?? 0.0;
        comparison = aAccuracy.compareTo(bAccuracy);
        break;

      case 'difficulty':
        final aDifficulty = a.word.difficulty.numericValue;
        final bDifficulty = b.word.difficulty.numericValue;
        comparison = aDifficulty.compareTo(bDifficulty);
        break;

      case 'lastReviewed':
        final aDate = a.userData?.lastReviewedAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.userData?.lastReviewedAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        comparison = aDate.compareTo(bDate);
        break;

      default:
        comparison = a.word.word.compareTo(b.word.word);
    }

    return ascending ? comparison : -comparison;
  });

  return words;
}

// Provider for category-specific statistics
@riverpod
Future<Map<String, CategoryStats>> categoryDetailedStats(
    CategoryDetailedStatsRef ref) async {
  try {
    final vocabularyRepo = ref.read(vocabularyRepositoryProvider);
    final userWordRepo = ref.read(userWordDataRepositoryProvider);

    final allWords = await vocabularyRepo.loadVocabulary();
    final allUserData = await userWordRepo.getAllUserWordData();

    final userDataMap = <String, UserWordData>{
      for (final data in allUserData) data.word: data
    };

    final categoryStats = <String, CategoryStats>{};

    // Group words by category
    final wordsByCategory = <String, List<VocabularyWord>>{};
    for (final word in allWords) {
      wordsByCategory.putIfAbsent(word.category, () => []).add(word);
    }

    // Calculate stats for each category
    for (final entry in wordsByCategory.entries) {
      final category = entry.key;
      final words = entry.value;

      int totalWords = words.length;
      int learnedWords = 0;
      int strugglingWords = 0;
      double totalAccuracy = 0.0;
      int wordsWithData = 0;

      for (final word in words) {
        final userData = userDataMap[word.word];
        if (userData != null) {
          if (userData.learningStage == 'mastered' || userData.isLearned) {
            learnedWords++;
          }
          if (userData.totalAnswers > 0) {
            totalAccuracy += userData.accuracyRate;
            wordsWithData++;
            if (userData.accuracyRate < 0.6) {
              strugglingWords++;
            }
          }
        }
      }

      final averageAccuracy =
          wordsWithData > 0 ? totalAccuracy / wordsWithData : 0.0;

      categoryStats[category] = CategoryStats(
        category: category,
        totalWords: totalWords,
        learnedWords: learnedWords,
        strugglingWords: strugglingWords,
        averageAccuracy: averageAccuracy,
        progressPercentage: totalWords > 0 ? (learnedWords / totalWords) : 0.0,
      );
    }

    return categoryStats;
  } catch (e) {
    throw Exception('Failed to load category stats: $e');
  }
}

class CategoryStats {
  final String category;
  final int totalWords;
  final int learnedWords;
  final int strugglingWords;
  final double averageAccuracy;
  final double progressPercentage;

  CategoryStats({
    required this.category,
    required this.totalWords,
    required this.learnedWords,
    required this.strugglingWords,
    required this.averageAccuracy,
    required this.progressPercentage,
  });
}

// Provider for difficulty breakdown statistics
@riverpod
Future<Map<String, DifficultyStats>> difficultyDetailedStats(
    DifficultyDetailedStatsRef ref) async {
  try {
    final vocabularyRepo = ref.read(vocabularyRepositoryProvider);
    final userWordRepo = ref.read(userWordDataRepositoryProvider);

    final allWords = await vocabularyRepo.loadVocabulary();
    final allUserData = await userWordRepo.getAllUserWordData();

    final userDataMap = <String, UserWordData>{
      for (final data in allUserData) data.word: data
    };

    final difficultyStats = <String, DifficultyStats>{};

    // Group words by difficulty
    final wordsByDifficulty = <String, List<VocabularyWord>>{};
    for (final word in allWords) {
      final difficulty = word.difficulty.name;
      wordsByDifficulty.putIfAbsent(difficulty, () => []).add(word);
    }

    // Calculate stats for each difficulty
    for (final entry in wordsByDifficulty.entries) {
      final difficulty = entry.key;
      final words = entry.value;

      int totalWords = words.length;
      int learnedWords = 0;
      int strugglingWords = 0;
      double totalAccuracy = 0.0;
      int wordsWithData = 0;
      double averageReviewTime = 0.0;

      for (final word in words) {
        final userData = userDataMap[word.word];
        if (userData != null) {
          if (userData.learningStage == 'mastered' || userData.isLearned) {
            learnedWords++;
          }
          if (userData.totalAnswers > 0) {
            totalAccuracy += userData.accuracyRate;
            wordsWithData++;
            if (userData.accuracyRate < 0.6) {
              strugglingWords++;
            }
          }
        }
      }

      final averageAccuracy =
          wordsWithData > 0 ? totalAccuracy / wordsWithData : 0.0;

      difficultyStats[difficulty] = DifficultyStats(
        difficulty: difficulty,
        totalWords: totalWords,
        learnedWords: learnedWords,
        strugglingWords: strugglingWords,
        averageAccuracy: averageAccuracy,
        progressPercentage: totalWords > 0 ? (learnedWords / totalWords) : 0.0,
        averageReviewTime: averageReviewTime,
      );
    }

    return difficultyStats;
  } catch (e) {
    throw Exception('Failed to load difficulty stats: $e');
  }
}

class DifficultyStats {
  final String difficulty;
  final int totalWords;
  final int learnedWords;
  final int strugglingWords;
  final double averageAccuracy;
  final double progressPercentage;
  final double averageReviewTime;

  DifficultyStats({
    required this.difficulty,
    required this.totalWords,
    required this.learnedWords,
    required this.strugglingWords,
    required this.averageAccuracy,
    required this.progressPercentage,
    required this.averageReviewTime,
  });
}
