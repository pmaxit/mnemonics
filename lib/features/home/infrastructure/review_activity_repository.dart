import 'package:hive/hive.dart';
import '../domain/review_activity.dart';

class ReviewActivityRepository {
  static const String boxName = 'review_activity';

  Future<void> addActivity(ReviewActivity activity) async {
    final box = await Hive.openBox<ReviewActivity>(boxName);
    await box.add(activity);
  }

  Future<void> saveActivity(ReviewActivity activity) async {
    final box = await Hive.openBox<ReviewActivity>(boxName);
    await box.add(activity);
  }

  Future<List<ReviewActivity>> getAllActivities() async {
    final box = await Hive.openBox<ReviewActivity>(boxName);
    return box.values.toList();
  }

  Future<void> clearAllData() async {
    final box = await Hive.openBox<ReviewActivity>(boxName);
    await box.clear();
  }
} 