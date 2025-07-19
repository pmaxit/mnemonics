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

  @HiveField(4)
  int reviewCount;

  @HiveField(5)
  DateTime? lastReviewedAt;

  @HiveField(6)
  DateTime? firstLearnedAt;

  @HiveField(7)
  int correctAnswers;

  @HiveField(8)
  int totalAnswers;

  @HiveField(9)
  String learningStage;

  UserWordData({
    required this.word,
    this.notes = '',
    this.isLearned = false,
    this.nextReview,
    this.reviewCount = 0,
    this.lastReviewedAt,
    this.firstLearnedAt,
    this.correctAnswers = 0,
    this.totalAnswers = 0,
    this.learningStage = 'new',
  });

  double get accuracyRate => totalAnswers > 0 ? correctAnswers / totalAnswers : 0.0;

  bool get isInProgress => learningStage == 'learning' || (reviewCount > 0 && !isLearned);

  bool get isMastered => learningStage == 'mastered' || (isLearned && accuracyRate >= 0.8);

  Map<String, dynamic> toJson() => {
    'word': word,
    'notes': notes,
    'isLearned': isLearned,
    'nextReview': nextReview?.toIso8601String(),
    'reviewCount': reviewCount,
    'lastReviewedAt': lastReviewedAt?.toIso8601String(),
    'firstLearnedAt': firstLearnedAt?.toIso8601String(),
    'correctAnswers': correctAnswers,
    'totalAnswers': totalAnswers,
    'learningStage': learningStage,
  };

  factory UserWordData.fromJson(Map<String, dynamic> json) => UserWordData(
    word: json['word'] as String,
    notes: json['notes'] as String? ?? '',
    isLearned: json['isLearned'] as bool? ?? false,
    nextReview: json['nextReview'] != null ? DateTime.parse(json['nextReview']) : null,
    reviewCount: json['reviewCount'] as int? ?? 0,
    lastReviewedAt: json['lastReviewedAt'] != null ? DateTime.parse(json['lastReviewedAt']) : null,
    firstLearnedAt: json['firstLearnedAt'] != null ? DateTime.parse(json['firstLearnedAt']) : null,
    correctAnswers: json['correctAnswers'] as int? ?? 0,
    totalAnswers: json['totalAnswers'] as int? ?? 0,
    learningStage: json['learningStage'] as String? ?? 'new',
  );
} 