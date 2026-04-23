import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../profile/domain/user_statistics.dart';

part 'vocabulary_word.freezed.dart';
part 'vocabulary_word.g.dart';

class PhrasesConverter implements JsonConverter<List<String>, dynamic> {
  const PhrasesConverter();

  @override
  List<String> fromJson(dynamic json) {
    if (json == null) return [];
    if (json is List) return json.map((e) => e.toString()).toList();
    if (json is String) {
      final trimmed = json.trim();
      if (trimmed.isEmpty) return [];
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is List) return decoded.map((e) => e.toString()).toList();
        } catch (_) {}
      }
      return trimmed.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  @override
  dynamic toJson(List<String> object) => object;
}

class ExampleSentencesConverter implements JsonConverter<List<List<String>>, dynamic> {
  const ExampleSentencesConverter();

  @override
  List<List<String>> fromJson(dynamic json) {
    if (json == null) return [];
    if (json is List) {
      return json.map((inner) {
        if (inner is List) return inner.map((e) => e.toString()).toList();
        return [inner.toString()];
      }).toList();
    }
    if (json is String) {
      final trimmed = json.trim();
      if (trimmed.isEmpty) return [];
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is List) {
            return decoded.map((inner) {
              if (inner is List) return inner.map((e) => e.toString()).toList();
              return [inner.toString()];
            }).toList();
          }
        } catch (_) {}
      }
      return [[trimmed]];
    }
    return [];
  }

  @override
  dynamic toJson(List<List<String>> object) => object;
}

@freezed
class VocabularyWord with _$VocabularyWord {
  const factory VocabularyWord({
    required String word,
    required String meaning,
    required String mnemonic,
    String? aiMnemonic,
    String? aiInsights,
    @JsonKey(name: 'imageUrl') String? image,
    @JsonKey(name: 'videoUrl') String? video,
    required String example,
    required List<String> synonyms,
    required List<String> antonyms,
    required WordDifficulty difficulty,
    required String category,
    @Default(<String>[]) List<String> setIds,
    String? definition,
    @PhrasesConverter() @Default(<String>[]) List<String> phrases,
    @ExampleSentencesConverter() @Default(<List<String>>[]) List<List<String>> exampleSentences,
  }) = _VocabularyWord;

  factory VocabularyWord.fromJson(Map<String, dynamic> json) =>
      _$VocabularyWordFromJson(json);
}
