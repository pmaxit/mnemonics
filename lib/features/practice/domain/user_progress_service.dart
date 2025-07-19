import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/domain/user_word_data.dart';
import '../../home/domain/review_activity.dart';
import '../../home/infrastructure/user_word_data_repository.dart';
import '../../home/infrastructure/review_activity_repository.dart';
import '../../home/providers.dart';

final userProgressServiceProvider = Provider<UserProgressService>((ref) {
  return UserProgressService(
    userWordDataRepository: ref.watch(userWordDataRepositoryProvider),
    reviewActivityRepository: ref.watch(reviewActivityRepositoryProvider),
    ref: ref,
  );
});

class UserProgressService {
  final UserWordDataRepository userWordDataRepository;
  final ReviewActivityRepository reviewActivityRepository;
  final Ref ref;

  UserProgressService({
    required this.userWordDataRepository,
    required this.reviewActivityRepository,
    required this.ref,
  });

  Future<void> recordWordLearned(String word, {bool isCorrect = true}) async {
    var userData = await userWordDataRepository.getUserWordData(word);
    final now = DateTime.now();
    
    if (userData == null) {
      userData = UserWordData(
        word: word,
        firstLearnedAt: now,
        learningStage: 'learning',
        reviewCount: 1,
        lastReviewedAt: now,
        correctAnswers: isCorrect ? 1 : 0,
        totalAnswers: 1,
      );
    } else {
      userData.reviewCount++;
      userData.lastReviewedAt = now;
      userData.totalAnswers++;
      if (isCorrect) {
        userData.correctAnswers++;
      }
      
      if (userData.firstLearnedAt == null) {
        userData.firstLearnedAt = now;
      }
      
      _updateLearningStage(userData);
    }
    
    await userWordDataRepository.saveUserWordData(userData);
    
    // Invalidate related providers to trigger statistics refresh
    ref.invalidate(allUserWordDataProvider);
    ref.invalidate(reviewActivityListProvider);
  }

  Future<void> recordReviewActivity(String word, String rating) async {
    final activity = ReviewActivity(
      word: word,
      reviewedAt: DateTime.now(),
      rating: rating,
    );
    
    await reviewActivityRepository.saveActivity(activity);
    
    final isCorrect = rating == 'correct' || rating == 'easy';
    await recordWordLearned(word, isCorrect: isCorrect);
    
    // Invalidate providers for real-time updates
    ref.invalidate(allUserWordDataProvider);
    ref.invalidate(reviewActivityListProvider);
  }

  Future<void> markWordAsLearned(String word) async {
    var userData = await userWordDataRepository.getUserWordData(word);
    final now = DateTime.now();
    
    if (userData == null) {
      userData = UserWordData(
        word: word,
        isLearned: true,
        firstLearnedAt: now,
        learningStage: 'mastered',
        reviewCount: 1,
        lastReviewedAt: now,
        correctAnswers: 1,
        totalAnswers: 1,
      );
    } else {
      userData.isLearned = true;
      userData.learningStage = 'mastered';
      if (userData.firstLearnedAt == null) {
        userData.firstLearnedAt = now;
      }
    }
    
    await userWordDataRepository.saveUserWordData(userData);
    
    // Invalidate providers for real-time updates
    ref.invalidate(allUserWordDataProvider);
    ref.invalidate(reviewActivityListProvider);
  }

  Future<void> resetWordProgress(String word) async {
    var userData = await userWordDataRepository.getUserWordData(word);
    if (userData != null) {
      userData.isLearned = false;
      userData.learningStage = 'new';
      userData.reviewCount = 0;
      userData.correctAnswers = 0;
      userData.totalAnswers = 0;
      userData.firstLearnedAt = null;
      userData.lastReviewedAt = null;
      userData.nextReview = null;
      
      await userWordDataRepository.saveUserWordData(userData);
      
      // Invalidate providers for real-time updates
      ref.invalidate(allUserWordDataProvider);
      ref.invalidate(reviewActivityListProvider);
    }
  }

  void _updateLearningStage(UserWordData userData) {
    if (userData.accuracyRate >= 0.8 && userData.reviewCount >= 3) {
      userData.learningStage = 'mastered';
      userData.isLearned = true;
    } else if (userData.reviewCount > 0) {
      userData.learningStage = 'learning';
    } else {
      userData.learningStage = 'new';
    }
  }
}