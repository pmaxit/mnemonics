import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_word_data.dart';

final userWordDataRepositoryProvider = Provider<UserWordDataRepository>((ref) {
  return UserWordDataRepository();
});

class UserWordDataRepository {
  static const String boxName = 'user_word_data';

  Future<Box<UserWordData>> _openBox() async {
    return await Hive.openBox<UserWordData>(boxName);
  }

  Future<UserWordData?> getUserWordData(String word) async {
    final box = await _openBox();
    return box.get(word);
  }

  Future<void> saveOrUpdateUserWordData(UserWordData data) async {
    final box = await _openBox();
    await box.put(data.word, data);
  }

  Future<void> saveUserWordData(UserWordData data) async {
    final box = await _openBox();
    await box.put(data.word, data);
  }

  Future<void> deleteUserWordData(String word) async {
    final box = await _openBox();
    await box.delete(word);
  }

  Future<List<UserWordData>> getAllUserWordData() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> clearAllData() async {
    final box = await _openBox();
    await box.clear();
  }
} 