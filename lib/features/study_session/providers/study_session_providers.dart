import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/study_plan.dart';
import '../domain/study_plan_day.dart';
import '../infrastructure/study_plan_repository.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------
final studyPlanRepositoryProvider = Provider<StudyPlanRepository>((ref) {
  return StudyPlanRepository();
});

// ---------------------------------------------------------------------------
// Active plans — loads from backend
// ---------------------------------------------------------------------------
final activePlansProvider = FutureProvider<List<StudyPlan>>((ref) async {
  final repo = ref.watch(studyPlanRepositoryProvider);
  return repo.getActivePlans();
});

// ---------------------------------------------------------------------------
// Single day detail
// ---------------------------------------------------------------------------
final studyDayProvider =
    FutureProvider.family<StudyPlanDay, int>((ref, dayNumber) async {
  final repo = ref.watch(studyPlanRepositoryProvider);
  return repo.getDay(dayNumber);
});

// ---------------------------------------------------------------------------
// Plan creation notifier
// ---------------------------------------------------------------------------
class StudyPlanCreationState {
  final bool isLoading;
  final String? error;
  final StudyPlan? createdPlan;

  const StudyPlanCreationState({
    this.isLoading = false,
    this.error,
    this.createdPlan,
  });

  StudyPlanCreationState copyWith({
    bool? isLoading,
    String? error,
    StudyPlan? createdPlan,
  }) =>
      StudyPlanCreationState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        createdPlan: createdPlan ?? this.createdPlan,
      );
}

class StudyPlanCreationNotifier extends StateNotifier<StudyPlanCreationState> {
  final StudyPlanRepository _repo;
  final Ref _ref;

  StudyPlanCreationNotifier(this._repo, this._ref)
      : super(const StudyPlanCreationState());

  Future<void> createPlan({
    required int totalWords,
    required int numDays,
    required int wordsPerDay,
    String? title,
  }) async {
    state = const StudyPlanCreationState(isLoading: true);
    try {
      final plan = await _repo.createStudyPlan(
        totalWords: totalWords,
        numDays: numDays,
        wordsPerDay: wordsPerDay,
        title: title,
      );
      // Invalidate the active plans cache so the calendar refreshes
      _ref.invalidate(activePlansProvider);
      state = StudyPlanCreationState(createdPlan: plan);
    } catch (e) {
      state = StudyPlanCreationState(error: e.toString());
    }
  }

  void reset() => state = const StudyPlanCreationState();
}

final studyPlanCreationProvider =
    StateNotifierProvider<StudyPlanCreationNotifier, StudyPlanCreationState>(
        (ref) {
  final repo = ref.watch(studyPlanRepositoryProvider);
  return StudyPlanCreationNotifier(repo, ref);
});

// ---------------------------------------------------------------------------
// Day status update notifier
// ---------------------------------------------------------------------------
class DayStatusNotifier extends StateNotifier<AsyncValue<void>> {
  final StudyPlanRepository _repo;
  final Ref _ref;

  DayStatusNotifier(this._repo, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> markInProgress(int dayNumber) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _repo.updateDayStatus(dayNumber, DayStatus.inProgress));
    _ref.invalidate(activePlansProvider);
  }

  Future<void> markDone(int dayNumber) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _repo.updateDayStatus(dayNumber, DayStatus.done));
    _ref.invalidate(activePlansProvider);
  }

  Future<void> deletePlan(String planId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.deletePlan(planId));
    _ref.invalidate(activePlansProvider);
  }
}

final dayStatusNotifierProvider =
    StateNotifierProvider<DayStatusNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(studyPlanRepositoryProvider);
  return DayStatusNotifier(repo, ref);
});
