import 'dart:convert';

class WordInsights {
  final String definition;
  final List<String> commonPhrases;
  final List<String> exampleSentences;
  final List<String> synonyms;
  final String memoryTip;

  WordInsights({
    required this.definition,
    required this.commonPhrases,
    required this.exampleSentences,
    required this.synonyms,
    required this.memoryTip,
  });

  Map<String, dynamic> toMap() {
    return {
      'definition': definition,
      'common_phrases': commonPhrases,
      'example_sentences': exampleSentences,
      'synonyms': synonyms,
      'memory_tip': memoryTip,
    };
  }

  factory WordInsights.fromMap(Map<String, dynamic> map) {
    return WordInsights(
      definition: map['definition'] as String? ?? 'No definition available.',
      commonPhrases: List<String>.from(map['common_phrases'] ?? []),
      exampleSentences: List<String>.from(map['example_sentences'] ?? []),
      synonyms: List<String>.from(map['synonyms'] ?? []),
      memoryTip: map['memory_tip'] as String? ?? 'No memory tip available.',
    );
  }

  String toJson() => json.encode(toMap());

  factory WordInsights.fromJson(String source) {
    String cleanSource = source.trim();
    if (cleanSource.startsWith('```json')) {
      cleanSource = cleanSource.substring(7);
    } else if (cleanSource.startsWith('```')) {
      cleanSource = cleanSource.substring(3);
    }
    if (cleanSource.endsWith('```')) {
      cleanSource = cleanSource.substring(0, cleanSource.length - 3);
    }
    return WordInsights.fromMap(
        json.decode(cleanSource.trim()) as Map<String, dynamic>);
  }
}
