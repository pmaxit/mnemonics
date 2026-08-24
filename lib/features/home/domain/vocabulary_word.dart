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

/// Returns real usage sentences for a word, excluding phrase fragments and filler.
extension VocabularyWordContextX on VocabularyWord {
  List<String> get contextSentences {
    final seen = <String>{};
    final results = <String>[];

    void addCandidate(String? raw) {
      if (raw == null) return;
      final sentence = raw.trim();
      if (sentence.isEmpty || sentence == 'No example available') return;
      if (!_looksLikeUsageSentence(sentence, word)) return;
      final key = sentence.toLowerCase();
      if (seen.add(key)) results.add(sentence);
    }

    for (final group in exampleSentences) {
      for (final sentence in group) {
        addCandidate(sentence);
      }
    }

    addCandidate(example);

    for (final sentence in _parseAiInsightsListField(aiInsights, const [
      'example_sentences',
      'exampleSentences',
    ])) {
      addCandidate(sentence);
    }

    return results;
  }

  /// Short 2-4 word collocations for this word. Prefers the dedicated
  /// `phrases` column, falling back to `common_phrases` parsed out of the
  /// AI-insights blob so already-generated content isn't wasted.
  List<String> get effectivePhrases {
    if (phrases.isNotEmpty) return phrases;
    return _parseAiInsightsListField(aiInsights, const [
      'common_phrases',
      'commonPhrases',
    ]);
  }

  /// Synonyms, falling back to the AI-insights blob when the dedicated
  /// `synonyms` column is empty (true for most legacy rows).
  List<String> get effectiveSynonyms {
    if (synonyms.isNotEmpty) return synonyms;
    return _parseAiInsightsListField(aiInsights, const ['synonyms']);
  }
}

bool _looksLikeUsageSentence(String sentence, String word) {
  if (sentence.length < 20) return false;
  if (!_containsWordForm(sentence, word)) return false;
  if (sentence.split(RegExp(r'\s+')).length < 5) return false;

  final lower = sentence.toLowerCase();
  const blocked = [
    'comes up often',
    'make your own sentence',
    'explain the meaning',
    'used correctly in',
    'practising',
    'first saw',
    'will make it stick',
  ];
  for (final phrase in blocked) {
    if (lower.contains(phrase)) return false;
  }
  return true;
}

bool _containsWordForm(String sentence, String word) {
  final lower = sentence.toLowerCase();
  final w = word.toLowerCase();
  if (lower.contains(w)) return true;
  if (w.length > 4) {
    final stem = w.substring(0, w.length - 1);
    if (stem.length >= 4 && lower.contains(stem)) return true;
  }
  return false;
}

List<String> _parseAiInsightsListField(String? aiInsights, List<String> keys) {
  if (aiInsights == null || aiInsights.isEmpty) return [];
  try {
    var cleaned = aiInsights.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^```json?\s*'), '');
      cleaned = cleaned.replaceFirst(RegExp(r'\s*```$'), '');
    }
    final data = jsonDecode(cleaned) as Map<String, dynamic>;
    for (final key in keys) {
      final raw = data[key];
      if (raw is List) return raw.map((e) => e.toString()).toList();
    }
  } catch (_) {}
  return [];
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
