import 'dart:convert';
import 'package:flutter/services.dart';

class WordSet {
  final String id;
  final String name;
  final String description;

  WordSet({required this.id, required this.name, required this.description});

  factory WordSet.fromJson(Map<String, dynamic> json) => WordSet(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
  );
}

class WordSetRepository {
  static const String _jsonPath = 'assets/word_sets.json';

  Future<List<WordSet>> loadWordSets() async {
    final jsonString = await rootBundle.loadString(_jsonPath);
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final List<dynamic> setsJson = jsonMap['sets'] as List<dynamic>;
    return setsJson.map((e) => WordSet.fromJson(e as Map<String, dynamic>)).toList();
  }
} 