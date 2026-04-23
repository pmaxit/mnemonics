import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../domain/user_word_data.dart';
import '../../auth/infrastructure/auth_repository.dart';

final userWordDataRepositoryProvider = Provider<UserWordDataRepository>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return UserWordDataRepository(authRepository);
});

class UserWordDataRepository {
  static const String boxName = 'user_word_data';
  static const String baseUrl =
      'https://mnemonics-api-1078980357394.us-central1.run.app';
  final AuthRepository _authRepository;

  UserWordDataRepository(this._authRepository);

  Future<Box<UserWordData>> _openBox() async {
    return await Hive.openBox<UserWordData>(boxName);
  }

  String get _userId => _authRepository.currentUser?.uid ?? 'default';

  /// Fetch user progress from the remote database and cache it locally
  Future<void> syncFromRemote() async {
    if (_userId == 'default') return;
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/user_progress/$_userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final progressMap = data['progress'] as Map<String, dynamic>? ?? {};
        
        final box = await _openBox();
        await box.clear(); // Clear local cache to sync fresh from remote

        for (final entry in progressMap.entries) {
          try {
            final wordDataJson = json.decode(entry.value) as Map<String, dynamic>;
            final userWordData = UserWordData.fromJson(wordDataJson);
            await box.put(entry.key, userWordData);
          } catch (e) {
            print('Error parsing remote UserWordData for word ${entry.key}: $e');
          }
        }
      }
    } catch (e) {
      print('Failed to sync UserWordData from remote: $e');
    }
  }

  Future<UserWordData?> getUserWordData(String word) async {
    final box = await _openBox();
    return box.get(word);
  }

  Future<void> saveOrUpdateUserWordData(UserWordData data) async {
    await saveUserWordData(data);
  }

  Future<void> saveUserWordData(UserWordData data) async {
    // 1. Save locally
    final box = await _openBox();
    await box.put(data.word, data);
    
    // 2. Sync to remote
    if (_userId != 'default') {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/user_progress/$_userId/${data.word}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data.toJson()),
        );
        if (response.statusCode != 200) {
           print('Failed to sync progress to server for ${data.word}');
        }
      } catch (e) {
        print('Error syncing progress to server: $e');
      }
    }
  }

  Future<void> deleteUserWordData(String word) async {
    final box = await _openBox();
    await box.delete(word);
    
    // There is no explicit delete endpoint for single words besides resetting everything right now.
    // If needed, we can implement a specific delete endpoint on the backend in the future.
  }

  Future<List<UserWordData>> getAllUserWordData() async {
    // If empty locally, attempt to sync from remote first
    final box = await _openBox();
    if (box.isEmpty) {
        await syncFromRemote();
    }
    return box.values.toList();
  }

  /// Extremely destructive - clears local cache entirely. 
  /// Use this when logging out or switching accounts!
  Future<void> clearAllData() async {
    final box = await _openBox();
    await box.clear();
  }
} 