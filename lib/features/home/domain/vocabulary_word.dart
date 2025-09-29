import 'package:freezed_annotation/freezed_annotation.dart';
import '../../profile/domain/user_statistics.dart';

part 'vocabulary_word.freezed.dart';
part 'vocabulary_word.g.dart';

@freezed
class VocabularyWord with _$VocabularyWord {
  const factory VocabularyWord({
    required String word,
    required String meaning,
    required String mnemonic,
    String? image,
    String? video,
    required String example,
    required List<String> synonyms,
    required List<String> antonyms,
    required WordDifficulty difficulty,
    required String category,
    @Default(<String>[]) List<String> setIds,
  }) = _VocabularyWord;

  factory VocabularyWord.fromJson(Map<String, dynamic> json) => _$VocabularyWordFromJson(json);
} 