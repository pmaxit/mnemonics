import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../infrastructure/auth_repository.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncData(null));

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => _authRepository.signInWithEmailAndPassword(email, password));
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        _authRepository.createUserWithEmailAndPassword(email, password, name));
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authRepository.signOut());
  }
}
