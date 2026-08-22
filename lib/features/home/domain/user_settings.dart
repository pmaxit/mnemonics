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

  /// Whether the personalized "My Words" practice section is shown on the
  /// home screen. Defaults to true (opt-out).
  @HiveField(3, defaultValue: true)
  bool showMyWords;

  UserSettings({
    this.dailyGoal = 60,
    this.languageCodes = const ['en'],
    this.reviewFrequency = 30,
    this.showMyWords = true,
  });

  Map<String, dynamic> toJson() => {
    'dailyGoal': dailyGoal,
    'languageCodes': languageCodes,
    'reviewFrequency': reviewFrequency,
    'showMyWords': showMyWords,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    dailyGoal: json['dailyGoal'] as int? ?? 60,
    languageCodes: (json['languageCodes'] as List<dynamic>?)?.cast<String>() ?? ['en'],
    reviewFrequency: json['reviewFrequency'] as int? ?? 30,
    showMyWords: json['showMyWords'] as bool? ?? true,
  );
} 