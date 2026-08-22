import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/platform/desktop_compat.dart';
import 'infrastructure/vocabulary_repository.dart';
import 'domain/vocabulary_word.dart';
import 'domain/word_recommendation.dart';
import 'infrastructure/user_word_data_repository.dart';
import 'domain/user_word_data.dart';
import 'domain/user_settings.dart';
import 'package:hive/hive.dart';
import 'infrastructure/review_activity_repository.dart';
import 'domain/review_activity.dart';
import 'infrastructure/word_set_repository.dart';
import '../auth/providers/user_profile_provider.dart';

/// Holds the current index of the bottom navigation bar (0 = Learn, 1 = Progress, 2 = Profile)
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

final vocabularyListProvider = FutureProvider<List<VocabularyWord>>((ref) async {
  final repo = ref.watch(vocabularyRepositoryProvider);
  // On Linux/Pi, Firebase is unavailable; use a local user id instead of
  // touching FirebaseAuth (which would throw).
  String? userId;
  if (desktopAuthBypass) {
    userId = desktopLocalUserId;
  } else {
    userId = FirebaseAuth.instance.currentUser?.uid;
  }
  return await repo.loadVocabulary(userId: userId);
});

final userWordDataProvider = FutureProvider.family<UserWordData?, String>((ref, word) async {
  final repo = ref.watch(userWordDataRepositoryProvider);
  return await repo.getUserWordData(word);
});

final allUserWordDataProvider = FutureProvider<List<UserWordData>>((ref) async {
  final repo = ref.watch(userWordDataRepositoryProvider);
  return await repo.getAllUserWordData();
});

/// Level-aware recommended words for the "My Words" practice section.
///
/// Combines the available vocabulary, the user's profile (levels + enabled
/// categories from onboarding), and what they have already learned. Re-runs
/// automatically whenever any of those inputs change.
final recommendedWordsProvider = FutureProvider<List<VocabularyWord>>((ref) async {
  final vocab = await ref.watch(vocabularyListProvider.future);
  final learned = await ref.watch(allUserWordDataProvider.future);
  final profile = ref.watch(userProfileProvider).value;

  final learnedWords = learned.where((d) => d.isLearned).map((d) => d.word).toSet();
  final levels = WordRecommendation.parseLevels(profile?.vocabularyLevel);
  final enabledCategories = (profile?.enabledWordSets ?? '')
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toSet();

  return WordRecommendation.recommend(
    available: vocab,
    learnedWords: learnedWords,
    levels: levels,
    enabledCategories: enabledCategories,
  );
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

  Future<void> saveSettings(UserSettings settings) async {
    state = settings;
    final box = await Hive.openBox<UserSettings>(boxName);
    await box.putAt(0, state!);
  }
}