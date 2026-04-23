import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../infrastructure/auth_repository.dart';
import '../../home/infrastructure/user_word_data_repository.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(
    ref.watch(authRepositoryProvider),
    ref.watch(userWordDataRepositoryProvider),
  );
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  final UserWordDataRepository _userWordDataRepository;

  AuthController(this._authRepository, this._userWordDataRepository) : super(const AsyncData(null));

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _userWordDataRepository.clearAllData();
      await _authRepository.signInWithEmailAndPassword(email, password);
      await _userWordDataRepository.syncFromRemote();
    });
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _userWordDataRepository.clearAllData();
      await _authRepository.createUserWithEmailAndPassword(email, password, name);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _userWordDataRepository.clearAllData();
      await _authRepository.signOut();
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _userWordDataRepository.clearAllData();
      await _authRepository.signInWithGoogle();
      await _userWordDataRepository.syncFromRemote();
    });
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _userWordDataRepository.clearAllData();
      await _authRepository.signInWithApple();
      await _userWordDataRepository.syncFromRemote();
    });
  }
}
