import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/ai_service.dart';
import '../../home/infrastructure/user_word_data_repository.dart';
import '../../home/domain/user_word_data.dart';
import '../domain/word_insights.dart';

part 'ai_word_insights_provider.g.dart';

@riverpod
class AiWordInsights extends _$AiWordInsights {
  @override
  AsyncValue<WordInsights?> build(String word) {
    return const AsyncValue.data(null);
  }

  Future<void> loadOrGenerateInsights() async {
    state = const AsyncValue.loading();
    try {
      final userWordRepo = ref.read(userWordDataRepositoryProvider);
      final userData = await userWordRepo.getUserWordData(word);

      // 1. Check if we already have it locally
      if (userData != null &&
          userData.aiInsights != null &&
          userData.aiInsights!.isNotEmpty) {
        try {
          final insights = WordInsights.fromJson(userData.aiInsights!);
          state = AsyncValue.data(insights);
          return;
        } catch (e) {
          log('Failed to parse cached insights, regenerating: $e');
        }
      }

      // 2. Otherwise generate it
      final aiService = ref.read(aiServiceProvider);
      final jsonResponse = await aiService.generateWordInsights(word: word);
      final parsedInsights = WordInsights.fromJson(jsonResponse);

      // 3. Save it back to local database
      if (userData != null) {
        userData.aiInsights = jsonResponse;
        await userWordRepo.saveOrUpdateUserWordData(userData);
      } else {
        final newData = UserWordData(word: word, aiInsights: jsonResponse);
        await userWordRepo.saveOrUpdateUserWordData(newData);
      }

      state = AsyncValue.data(parsedInsights);
    } catch (e, st) {
      log('Error in generation: $e');
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
