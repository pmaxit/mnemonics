import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocabulary_word.freezed.dart';
part 'vocabulary_word.g.dart';

@freezed
class VocabularyWord with _$VocabularyWord {
  const factory VocabularyWord({
    required String word,
    required String meaning,
    required String mnemonic,
    String? image,
    required String example,
    required List<String> synonyms,
    required List<String> antonyms,
    required String difficulty,
    required String category,
    @Default(<String>[]) List<String> setIds,
  }) = _VocabularyWord;

  factory VocabularyWord.fromJson(Map<String, dynamic> json) => _$VocabularyWordFromJson(json);
} 