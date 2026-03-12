import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
});

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository(this._auth);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userCredential.user?.updateDisplayName(name);
    return userCredential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stubs for future social login implementations
  Future<UserCredential> signInWithGoogle() async {
    throw UnimplementedError('Google sign in is not yet implemented.');
  }

  Future<UserCredential> signInWithApple() async {
    throw UnimplementedError('Apple sign in is not yet implemented.');
  }

  Future<UserCredential> signInWithFacebook() async {
    throw UnimplementedError('Facebook sign in is not yet implemented.');
  }
}
