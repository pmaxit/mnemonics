import '../../home/domain/vocabulary_word.dart';
import '../domain/user_statistics.dart';

class DataMigrationService {
  /// Migrates string-based difficulty to enum
  static WordDifficulty migrateDifficultyFromString(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return WordDifficulty.basic;
      case 'medium':
        return WordDifficulty.intermediate;
      case 'hard':
        return WordDifficulty.advanced;
      case 'basic':
        return WordDifficulty.basic;
      case 'intermediate':
        return WordDifficulty.intermediate;
      case 'advanced':
        return WordDifficulty.advanced;
      default:
        return WordDifficulty.intermediate; // Default fallback
    }
  }

  /// Migrates string-based learning stage to enum
  static LearningStage migrateLearningStageFromString(String stage) {
    switch (stage.toLowerCase()) {
      case 'new':
        return LearningStage.newWord;
      case 'learning':
        return LearningStage.learning;
      case 'mastered':
        return LearningStage.mastered;
      default:
        return LearningStage.newWord; // Default fallback
    }
  }

  /// Migrates string-based review rating to enum
  static ReviewDifficultyRating migrateRatingFromString(String rating) {
    switch (rating.toLowerCase()) {
      case 'easy':
        return ReviewDifficultyRating.easy;
      case 'medium':
        return ReviewDifficultyRating.medium;
      case 'hard':
        return ReviewDifficultyRating.hard;
      default:
        return ReviewDifficultyRating.medium; // Default fallback
    }
  }

  /// Migrates vocabulary data from JSON with string difficulty to enum difficulty
  static VocabularyWord migrateVocabularyWord(Map<String, dynamic> json) {
    return VocabularyWord(
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      mnemonic: json['mnemonic'] as String,
      image: json['image'] as String?,
      example: json['example'] as String,
      synonyms: (json['synonyms'] as List<dynamic>?)?.cast<String>() ?? [],
      antonyms: (json['antonyms'] as List<dynamic>?)?.cast<String>() ?? [],
      difficulty: migrateDifficultyFromString(
          json['difficulty'] as String? ?? 'medium'),
      category: json['category'] as String,
      setIds: (json['setIds'] as List<dynamic>?)?.cast<String>() ?? [],
      definition: json['definition'] as String?,
      phrases:
          (json['phrases'] as List<dynamic>?)?.cast<String>() ?? <String>[],
      exampleSentences: (json['exampleSentences'] as List<dynamic>?)
              ?.map((e) => (e as List<dynamic>).cast<String>())
              .toList() ??
          <List<String>>[],
    );
  }

  /// Creates a compatibility wrapper to handle legacy data
  static Map<String, dynamic> convertDifficultyStatsToLegacy(
      Map<WordDifficulty, int> difficultyStats) {
    return {
      'basic': difficultyStats[WordDifficulty.basic] ?? 0,
      'intermediate': difficultyStats[WordDifficulty.intermediate] ?? 0,
      'advanced': difficultyStats[WordDifficulty.advanced] ?? 0,
    };
  }

  /// Converts enum-based difficulty stats back to string-based for legacy components
  static Map<String, int> convertDifficultyStatsToStringMap(
      Map<WordDifficulty, int> difficultyStats) {
    return {
      'basic': difficultyStats[WordDifficulty.basic] ?? 0,
      'intermediate': difficultyStats[WordDifficulty.intermediate] ?? 0,
      'advanced': difficultyStats[WordDifficulty.advanced] ?? 0,
    };
  }

  /// Converts UserStatistics to legacy ProfileStatistics format for backward compatibility
  static Map<String, dynamic> convertToLegacyProfileStatistics(
      UserStatistics stats) {
    final categoryStats = stats.categoryStats.values
        .map((cat) => {
              'categoryName': cat.categoryName,
              'wordsLearned': cat.wordsLearned,
              'totalWords': cat.totalWords,
              'averageAccuracy': cat.averageAccuracy,
            })
        .toList();

    final difficultyStats = stats.difficultyStats.values
        .map((diff) => {
              'difficulty': diff.difficulty.name,
              'wordsLearned': diff.wordsLearned,
              'totalWords': diff.totalWords,
              'averageAccuracy': diff.averageAccuracy,
            })
        .toList();

    return {
      'totalWordsLearned': stats.totalWordsLearned,
      'wordsLearnedToday': stats.wordsLearnedToday,
      'wordsLearnedThisWeek': stats.wordsLearnedThisWeek,
      'currentStreak': stats.currentStreak,
      'longestStreak': stats.longestStreak,
      'totalStudyTimeMinutes': stats.totalStudyTimeMinutes,
      'averageAccuracy': stats.averageAccuracy,
      'studySessionsThisWeek': stats.recentActions
          .where((action) => _isWithinCurrentWeek(action.timestamp))
          .length,
      'learningVelocity': stats.learningVelocity,
      'categoryStats': categoryStats,
      'difficultyStats': difficultyStats,
      'milestones': stats.milestones
          .map((m) => {
                'id': m.id,
                'title': m.title,
                'description': m.description,
                'type': m.type.name,
                'targetValue': m.targetValue,
                'currentValue': m.currentValue,
                'isUnlocked': m.isUnlocked,
                'unlockedAt': m.unlockedAt?.toIso8601String(),
              })
          .toList(),
      'joinDate': stats.joinDate?.toIso8601String(),
    };
  }

  static bool _isWithinCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return date.isAfter(weekStart) &&
        date.isBefore(weekEnd.add(const Duration(days: 1)));
  }
}
