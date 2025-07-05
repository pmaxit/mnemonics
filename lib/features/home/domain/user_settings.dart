import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 1)
class UserSettings extends HiveObject {
  @HiveField(0)
  int dailyGoal;

  @HiveField(1)
  List<String> languageCodes;

  @HiveField(2)
  int reviewFrequency;

  UserSettings({
    this.dailyGoal = 60,
    this.languageCodes = const ['en'],
    this.reviewFrequency = 30,
  });

  Map<String, dynamic> toJson() => {
    'dailyGoal': dailyGoal,
    'languageCodes': languageCodes,
    'reviewFrequency': reviewFrequency,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    dailyGoal: json['dailyGoal'] as int? ?? 60,
    languageCodes: (json['languageCodes'] as List<dynamic>?)?.cast<String>() ?? ['en'],
    reviewFrequency: json['reviewFrequency'] as int? ?? 30,
  );
} 