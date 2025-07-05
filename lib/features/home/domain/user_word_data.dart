import 'package:hive/hive.dart';

part 'user_word_data.g.dart';

@HiveType(typeId: 0)
class UserWordData extends HiveObject {
  @HiveField(0)
  String word;

  @HiveField(1)
  String notes;

  @HiveField(2)
  bool isLearned;

  @HiveField(3)
  DateTime? nextReview;

  UserWordData({
    required this.word,
    this.notes = '',
    this.isLearned = false,
    this.nextReview,
  });

  Map<String, dynamic> toJson() => {
    'word': word,
    'notes': notes,
    'isLearned': isLearned,
    'nextReview': nextReview?.toIso8601String(),
  };

  factory UserWordData.fromJson(Map<String, dynamic> json) => UserWordData(
    word: json['word'] as String,
    notes: json['notes'] as String? ?? '',
    isLearned: json['isLearned'] as bool? ?? false,
    nextReview: json['nextReview'] != null ? DateTime.parse(json['nextReview']) : null,
  );
} 