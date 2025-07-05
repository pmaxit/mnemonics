import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'infrastructure/vocabulary_repository.dart';
import 'domain/vocabulary_word.dart';
import 'infrastructure/user_word_data_repository.dart';
import 'domain/user_word_data.dart';
import 'domain/user_settings.dart';
import 'package:hive/hive.dart';
import 'infrastructure/review_activity_repository.dart';
import 'domain/review_activity.dart';
import 'infrastructure/word_set_repository.dart';

/// Holds the current index of the bottom navigation bar (0 = Learn, 1 = Progress, 2 = Profile)
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

final vocabularyListProvider = FutureProvider<List<VocabularyWord>>((ref) async {
  final repo = ref.watch(vocabularyRepositoryProvider);
  return await repo.loadVocabulary();
});

final userWordDataProvider = FutureProvider.family<UserWordData?, String>((ref, word) async {
  final repo = ref.watch(userWordDataRepositoryProvider);
  return await repo.getUserWordData(word);
});

final allUserWordDataProvider = FutureProvider<List<UserWordData>>((ref) async {
  final repo = ref.watch(userWordDataRepositoryProvider);
  return await repo.getAllUserWordData();
});

final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettings?>((ref) {
  return UserSettingsNotifier();
});

final reviewActivityRepositoryProvider = Provider<ReviewActivityRepository>((ref) {
  return ReviewActivityRepository();
});

final reviewActivityListProvider = FutureProvider<List<ReviewActivity>>((ref) async {
  final repo = ref.watch(reviewActivityRepositoryProvider);
  return await repo.getAllActivities();
});

final wordSetRepositoryProvider = Provider<WordSetRepository>((ref) {
  return WordSetRepository();
});

final wordSetListProvider = FutureProvider<List<WordSet>>((ref) async {
  final repo = ref.watch(wordSetRepositoryProvider);
  return await repo.loadWordSets();
});

class UserSettingsNotifier extends StateNotifier<UserSettings?> {
  static const String boxName = 'user_settings';
  UserSettingsNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox<UserSettings>(boxName);
    if (box.isNotEmpty) {
      state = box.getAt(0);
    } else {
      state = UserSettings();
      await box.add(state!);
    }
  }

  Future<void> updateDailyGoal(int goal) async {
    if (state == null) return;
    state = UserSettings(
      dailyGoal: goal,
      languageCodes: state!.languageCodes,
      reviewFrequency: state!.reviewFrequency,
    );
    final box = await Hive.openBox<UserSettings>(boxName);
    await box.putAt(0, state!);
  }

  Future<void> updateLanguages(List<String> codes) async {
    if (state == null) return;
    state = UserSettings(
      dailyGoal: state!.dailyGoal,
      languageCodes: codes,
      reviewFrequency: state!.reviewFrequency,
    );
    final box = await Hive.openBox<UserSettings>(boxName);
    await box.putAt(0, state!);
  }

  Future<void> updateReviewFrequency(int freq) async {
    if (state == null) return;
    state = UserSettings(
      dailyGoal: state!.dailyGoal,
      languageCodes: state!.languageCodes,
      reviewFrequency: freq,
    );
    final box = await Hive.openBox<UserSettings>(boxName);
    await box.putAt(0, state!);
  }
} 