import 'package:hive/hive.dart';

part 'review_activity.g.dart';

@HiveType(typeId: 2)
class ReviewActivity extends HiveObject {
  @HiveField(0)
  String word;

  @HiveField(1)
  DateTime reviewedAt;

  @HiveField(2)
  String rating;

  ReviewActivity({
    required this.word,
    required this.reviewedAt,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
    'word': word,
    'reviewedAt': reviewedAt.toIso8601String(),
    'rating': rating,
  };

  factory ReviewActivity.fromJson(Map<String, dynamic> json) => ReviewActivity(
    word: json['word'] as String,
    reviewedAt: DateTime.parse(json['reviewedAt']),
    rating: json['rating'] as String,
  );
} 