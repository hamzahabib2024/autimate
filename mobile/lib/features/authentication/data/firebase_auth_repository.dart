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

  /// True until a caregiver has authenticated. Firebase persists sessions
  /// across launches, so a returning caregiver is not asked again.
  @override
  bool get requiresSignIn => !isSignedIn;

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
      //
      // Both codes have to be handled. Firebase projects created since 2023
      // have email enumeration protection on by default, and it deliberately
      // collapses "no such account" and "wrong password" into the single
      // ambiguous `invalid-credential` so an attacker cannot use the error
      // to discover which addresses are registered. Matching only
      // `user-not-found` therefore works on an older project and silently
      // locks every first-time caregiver out of a new one.
      if (error.code == 'user-not-found' ||
          error.code == 'invalid-credential' ||
          error.code == 'INVALID_LOGIN_CREDENTIALS') {
        // Because the code is ambiguous, registration is also how we find
        // out which case it was: `email-already-in-use` coming back means
        // the account exists and the password was simply wrong, which
        // [register] reports as false. No account is ever overwritten.
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
    } on FirebaseAuthException catch (error) {
      // Reached routinely via the ambiguous-credential path above, where it
      // means "existing account, wrong password" rather than a fault.
      if (error.code == 'email-already-in-use') {
        debugPrint('Caregiver sign-in refused: wrong password');
        return false;
      }
      debugPrint('Caregiver registration failed: ${error.code}');
      return false;
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
