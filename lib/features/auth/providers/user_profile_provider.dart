import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/user_profile.dart';
import '../infrastructure/user_profile_repository.dart';
import '../infrastructure/auth_repository.dart';

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  final authState = ref.watch(firebaseAuthProvider);
  return UserProfileNotifier(repository, authState);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final UserProfileRepository _repository;
  final FirebaseAuth _auth;

  UserProfileNotifier(this._repository, this._auth) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await fetchProfile(user.uid);
      } else {
        state = const AsyncValue.data(null);
      }
    });
  }

  Future<void> fetchProfile(String userId) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getUserProfile(userId);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      await _repository.saveUserProfile(profile);
      state = AsyncValue.data(profile);
    } catch (e) {
      // In a real app, you might want to show an error SnackBar
      print('Error updating profile: $e');
    }
  }

  Future<void> curateAndCompleteOnboarding({
    required String userId,
    required String goal,
    required int score,
  }) async {
    try {
      await _repository.curateOnboarding(
        userId: userId,
        goal: goal,
        score: score,
      );
      // Refresh the profile to get the updated level and sets
      await fetchProfile(userId);
    } catch (e) {
      print('Error during curation: $e');
    }
  }
}

final settingsSummaryProvider = FutureProvider<String>((ref) async {
  final profile = ref.watch(userProfileProvider).value;
  if (profile == null) return 'Select your categories and level to get started.';

  final repository = ref.read(userProfileRepositoryProvider);
  return repository.getSettingsSummary(profile.vocabularyLevel, profile.enabledWordSets);
});
