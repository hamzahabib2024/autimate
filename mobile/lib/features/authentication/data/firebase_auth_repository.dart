import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/app_services.dart';

/// Firebase Authentication for **caregivers only**.
///
/// A scope rule this class exists to hold: the child never has an account.
/// Children are profiles owned by a caregiver, which is why there is no
/// child sign-in path here and why [uid] is the caregiver's — it is the
/// Firestore ownership key that `firestore.rules` checks against.
///
/// Every failure resolves to `false` rather than an exception. The caller
/// is a sign-in form, and a thrown `FirebaseAuthException` there would
/// surface a raw error code to a parent.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// The signed-in caregiver's id, or empty when signed out. Repositories
  /// read this on every call rather than caching it.
  String get uid => _auth.currentUser?.uid ?? '';

  bool get isSignedIn => _auth.currentUser != null;

  /// Emits on sign-in and sign-out so the shell can react.
  Stream<bool> get signedInChanges =>
      _auth.authStateChanges().map((user) => user != null);

  @override
  Future<bool> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) return false;
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user != null;
    } on FirebaseAuthException catch (error) {
      // An unknown caregiver on first run is the expected path, not a fault.
      if (error.code == 'user-not-found') {
        return register(email, password);
      }
      debugPrint('Caregiver sign-in refused: ${error.code}');
      return false;
    } catch (error) {
      debugPrint('Caregiver sign-in failed: $error');
      return false;
    }
  }

  /// Creates a caregiver account. Teacher accounts are created the same way
  /// and distinguished by the role written alongside their profile, not by
  /// a different credential type.
  Future<bool> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user != null;
    } catch (error) {
      debugPrint('Caregiver registration failed: $error');
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error) {
      debugPrint('Sign-out failed: $error');
    }
  }
}
