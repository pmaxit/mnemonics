import 'dart:convert';

class WordInsights {
  final String origin;
  final String usageContexts;
  final String popCulture;
  final String funFact;

  WordInsights({
    required this.origin,
    required this.usageContexts,
    required this.popCulture,
    required this.funFact,
  });

  Map<String, dynamic> toMap() {
    return {
      'origin': origin,
      'usage_contexts': usageContexts,
      'pop_culture': popCulture,
      'fun_fact': funFact,
    };
  }

  factory WordInsights.fromMap(Map<String, dynamic> map) {
    return WordInsights(
      origin: map['origin'] as String? ?? 'No origin information available.',
      usageContexts:
          map['usage_contexts'] as String? ?? 'No usage context available.',
      popCulture: map['pop_culture'] as String? ??
          'No pop culture references available.',
      funFact: map['fun_fact'] as String? ?? 'No fun facts available.',
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
