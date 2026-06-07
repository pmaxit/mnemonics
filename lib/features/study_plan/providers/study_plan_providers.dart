import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/study_plan.dart';
import '../infrastructure/study_plan_repository.dart';

/// Singleton repository provider
final studyPlanRepositoryProvider = Provider<StudyPlanRepository>((ref) {
  return StudyPlanRepository();
});

/// Provider to list all study plans
final studyPlanListProvider = FutureProvider<List<StudyPlan>>((ref) async {
  final repo = ref.watch(studyPlanRepositoryProvider);
  return await repo.listStudyPlans();
});

/// Provider for the currently selected/active plan (full details with days)
final activeStudyPlanProvider =
    FutureProvider.family<StudyPlan, int>((ref, planId) async {
  final repo = ref.watch(studyPlanRepositoryProvider);
  return await repo.getStudyPlan(planId);
});

/// Provider for a specific day's word list
final studyPlanDayProvider =
    FutureProvider.family<StudyPlanDayDetail, ({int planId, int dayNum})>(
        (ref, params) async {
  final repo = ref.watch(studyPlanRepositoryProvider);
  return await repo.getStudyPlanDay(params.planId, params.dayNum);
});

/// StateProvider to track the currently selected plan ID
final selectedPlanIdProvider = StateProvider<int?>((ref) => null);

/// Notifier for creating plans and updating word statuses
class StudyPlanNotifier extends StateNotifier<AsyncValue<void>> {
  final StudyPlanRepository _repo;
  final Ref _ref;

  StudyPlanNotifier(this._repo, this._ref) : super(const AsyncValue.data(null));

  Future<StudyPlan> createPlan({
    required int totalWords,
    required int wordsPerDay,
    required String startDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final plan = await _repo.createStudyPlan(
        totalWords: totalWords,
        wordsPerDay: wordsPerDay,
        startDate: startDate,
      );
      // Invalidate the list to refetch
      _ref.invalidate(studyPlanListProvider);
      state = const AsyncValue.data(null);
      return plan;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateWordStatus({
    required int planId,
    required int dayNum,
    required String word,
    required String status,
  }) async {
    try {
      await _repo.updateWordStatus(
        planId: planId,
        dayNum: dayNum,
        word: word,
        status: status,
      );
      // Invalidate both day and plan data to refresh UI
      _ref.invalidate(studyPlanDayProvider);
      _ref.invalidate(activeStudyPlanProvider);
    } catch (e) {
      rethrow;
    }
  }
}

final studyPlanNotifierProvider =
    StateNotifierProvider<StudyPlanNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(studyPlanRepositoryProvider);
  return StudyPlanNotifier(repo, ref);
});
