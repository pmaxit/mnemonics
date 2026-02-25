import 'package:hive/hive.dart';
import '../../profile/domain/user_statistics.dart';

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
  LearningStage learningStage;

  @HiveField(10, defaultValue: 2.5)
  double easeFactor;

  @HiveField(11, defaultValue: 0)
  int interval;

  @HiveField(12, defaultValue: 0)
  int repetitions;

  @HiveField(13, defaultValue: false)
  bool hasBeenTested;

  @HiveField(14)
  String? aiMnemonic;

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
    this.learningStage = LearningStage.newWord,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    this.hasBeenTested = false,
    this.aiMnemonic,
  });

  double get accuracyRate =>
      hasBeenTested && totalAnswers > 0 ? correctAnswers / totalAnswers : 0.0;

  bool get isInProgress =>
      learningStage == LearningStage.learning ||
      (reviewCount > 0 && !isLearned);

  bool get isMastered =>
      learningStage == LearningStage.mastered ||
      (isLearned && accuracyRate >= 0.8);

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
        'learningStage': learningStage.name,
        'easeFactor': easeFactor,
        'interval': interval,
        'repetitions': repetitions,
        'hasBeenTested': hasBeenTested,
        'aiMnemonic': aiMnemonic,
      };

  factory UserWordData.fromJson(Map<String, dynamic> json) => UserWordData(
        word: json['word'] as String,
        notes: json['notes'] as String? ?? '',
        isLearned: json['isLearned'] as bool? ?? false,
        nextReview: json['nextReview'] != null
            ? DateTime.parse(json['nextReview'])
            : null,
        reviewCount: json['reviewCount'] as int? ?? 0,
        lastReviewedAt: json['lastReviewedAt'] != null
            ? DateTime.parse(json['lastReviewedAt'])
            : null,
        firstLearnedAt: json['firstLearnedAt'] != null
            ? DateTime.parse(json['firstLearnedAt'])
            : null,
        correctAnswers: json['correctAnswers'] as int? ?? 0,
        totalAnswers: json['totalAnswers'] as int? ?? 0,
        learningStage: LearningStage.values.firstWhere(
          (stage) =>
              stage.name == (json['learningStage'] as String? ?? 'newWord'),
          orElse: () => LearningStage.newWord,
        ),
        easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
        interval: json['interval'] as int? ?? 0,
        repetitions: json['repetitions'] as int? ?? 0,
        hasBeenTested: json['hasBeenTested'] as bool? ?? false,
        aiMnemonic: json['aiMnemonic'] as String?,
      );
}

// Hive adapter for LearningStage enum
class LearningStageAdapter extends TypeAdapter<LearningStage> {
  @override
  final int typeId = 3; // Use a unique typeId

  @override
  LearningStage read(BinaryReader reader) {
    final index = reader.readByte();
    return LearningStage.values[index];
  }

  @override
  void write(BinaryWriter writer, LearningStage obj) {
    writer.writeByte(obj.index);
  }
}
