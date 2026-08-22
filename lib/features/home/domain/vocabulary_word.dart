import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../profile/domain/user_statistics.dart';

part 'vocabulary_word.freezed.dart';
part 'vocabulary_word.g.dart';

/// Parses a JSON list, JSON string, or Dart-style `[a, b]` / comma-separated string.
List<String> parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value.map((e) => e.toString()).toList();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return [];
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {
        return _splitCsv(trimmed.substring(1, trimmed.length - 1));
      }
    }
    return _splitCsv(trimmed);
  }
  return [];
}

List<String> _splitCsv(String value) {
  return value.split(',').map((e) {
    var item = e.trim();
    if ((item.startsWith('"') && item.endsWith('"')) ||
        (item.startsWith("'") && item.endsWith("'"))) {
      item = item.substring(1, item.length - 1);
    }
    return item;
  }).where((e) => e.isNotEmpty).toList();
}

class PhrasesConverter implements JsonConverter<List<String>, dynamic> {
  const PhrasesConverter();

  @override
  List<String> fromJson(dynamic json) => parseStringList(json);

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
