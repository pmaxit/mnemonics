import 'package:hive/hive.dart';
import '../../profile/domain/user_statistics.dart';

part 'review_activity.g.dart';

@HiveType(typeId: 2)
class ReviewActivity extends HiveObject {
  @HiveField(0)
  String word;

  @HiveField(1)
  DateTime reviewedAt;

  @HiveField(2)
  ReviewDifficultyRating rating;

  ReviewActivity({
    required this.word,
    required this.reviewedAt,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
    'word': word,
    'reviewedAt': reviewedAt.toIso8601String(),
    'rating': rating.name,
  };

  factory ReviewActivity.fromJson(Map<String, dynamic> json) => ReviewActivity(
    word: json['word'] as String,
    reviewedAt: DateTime.parse(json['reviewedAt']),
    rating: ReviewDifficultyRating.values.firstWhere(
      (rating) => rating.name == (json['rating'] as String? ?? 'medium'),
      orElse: () => ReviewDifficultyRating.medium,
    ),
  );
} 