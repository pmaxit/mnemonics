import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/ai_service.dart';
import '../../home/infrastructure/user_word_data_repository.dart';
import '../../home/domain/user_word_data.dart';

part 'ai_mnemonic_provider.g.dart';

@riverpod
class AiMnemonic extends _$AiMnemonic {
  @override
  AsyncValue<String?> build(String word) {
    return const AsyncValue.data(null);
  }

  Future<void> generateMnemonic({
    required String meaning,
    String? nativeLanguage,
  }) async {
    state = const AsyncValue.loading();
    try {
      final aiService = ref.read(aiServiceProvider);
      final mnemonic = await aiService.generateMnemonic(
        word: word,
        meaning: meaning,
        nativeLanguage: nativeLanguage,
      );

      final userWordRepo = ref.read(userWordDataRepositoryProvider);
      final userData = await userWordRepo.getUserWordData(word);

      if (userData != null) {
        userData.aiMnemonic = mnemonic;
        await userWordRepo.saveOrUpdateUserWordData(userData);
      } else {
        final newData = UserWordData(word: word, aiMnemonic: mnemonic);
        await userWordRepo.saveOrUpdateUserWordData(newData);
      }

      state = AsyncValue.data(mnemonic);
    } catch (e, st) {
      log('Error in generation: $e');
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
