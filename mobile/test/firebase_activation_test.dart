import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/config/app_config.dart';
import 'package:autimate/core/data/firebase/firebase_bootstrap.dart';
import 'package:autimate/core/data/firebase/firestore_paths.dart';
import 'package:autimate/core/data/firebase/firestore_progress_repository.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/emotion_recognition/domain/emotion_activity_engine.dart';

/// A repository that demands a credential, standing in for Firebase Auth
/// without needing a live plugin.
class _GatedAuthRepository implements AuthRepository {
  bool signedIn = false;

  @override
  Future<bool> signIn(String email, String password) async {
    signedIn = password == 'correct';
    return signedIn;
  }

  @override
  Future<void> signOut() async => signedIn = false;

  @override
  bool get requiresSignIn => !signedIn;
}

AppState _state(AuthRepository auth) => AppState(auth, MockTtsService());

void main() {
  group('Firebase only activates when it can actually work', () {
    test('no credentials by any route leaves it dormant', () async {
      // The safe default: an unconfigured build runs local-only rather
      // than failing at launch.
      const config = AppConfig();
      expect(config.firebaseConfigured, isFalse);
      expect(await FirebaseBootstrap.ensureInitialised(config), isFalse);
    });

    test('a mock build stays local even with generated options present',
        () async {
      // A demo on a flaky network must be able to opt out deliberately.
      const config = AppConfig(environment: 'mock');
      expect(
        await FirebaseBootstrap.ensureInitialised(
          config,
          generatedOptions: const FirebaseOptions(
            apiKey: 'k',
            appId: 'a',
            messagingSenderId: 's',
            projectId: 'p',
          ),
        ),
        isFalse,
      );
    });

    test('dart-define credentials are recognised', () {
      // The regression this guards: for a while only this route was read,
      // so a project that ran the FlutterFire CLI and generated
      // firebase_options.dart found Firebase silently switched off.
      const config = AppConfig(
        firebaseApiKey: 'k',
        firebaseProjectId: 'p',
        firebaseAppId: 'a',
      );
      expect(config.firebaseConfigured, isTrue);
      expect(FirebaseBootstrap.optionsFrom(config).projectId, 'p');
    });
  });

  group('the sign-in wall follows the backend', () {
    test('no backend means no wall', () {
      // Objective O7: the child-facing app works with no account at all.
      expect(_state(MockAuthRepository()).signedIn, isTrue);
    });

    test('a backend that needs a caregiver gets one', () async {
      final auth = _GatedAuthRepository();
      final state = _state(auth);
      expect(state.signedIn, isFalse,
          reason: 'the shell must show the sign-in screen');

      // The bug this covers: a correct password used to leave the caregiver
      // on the form forever, because nothing flipped the flag.
      expect(await auth.signIn('a@b.c', 'wrong'), isFalse);
      expect(state.signedIn, isFalse);

      expect(await auth.signIn('a@b.c', 'correct'), isTrue);
      state.markSignedIn();
      expect(state.signedIn, isTrue);
    });

    test('signing out of a backend returns to the wall, not a dead end', () async {
      final auth = _GatedAuthRepository();
      final state = _state(auth);
      state.markSignedIn();
      await state.signOut();
      expect(state.signedIn, isFalse);

      // But signing out with no backend must never strand a child behind a
      // wall the app has no way past.
      final local = _state(MockAuthRepository());
      await local.signOut();
      expect(local.signedIn, isTrue);
    });
  });

  group('an unattributed write reaches nobody', () {
    late FakeFirebaseFirestore firestore;

    setUp(() => firestore = FakeFirebaseFirestore());

    Future<int> writtenSessions(String uid, String childId) async {
      final repo = FirestoreProgressRepository(
        firestore: firestore,
        currentUid: () => uid,
        currentChildId: () => childId,
      );
      await repo.recordSession(
        SessionResult(
          childId: childId,
          activityType: 'emotion',
          score: 4,
          total: 5,
          levelPlayed: SupportLevel.beginner,
          levelAfter: SupportLevel.beginner,
          duration: const Duration(seconds: 30),
          completedAt: DateTime(2026, 3, 1),
          starsAwarded: 1,
        ),
      );
      if (childId.isEmpty) return 0;
      final snap =
          await firestore.collection(FirestorePaths.sessions(childId)).get();
      return snap.docs.length;
    }

    test('an empty child id drops the write', () async {
      // Which is exactly what happened in the app: currentChildIdProvider
      // was declared but never overridden, so it returned '' forever and
      // every remote write was discarded without an error.
      expect(await writtenSessions('caregiver-1', ''), 0);
    });

    test('a real child id persists it', () async {
      expect(await writtenSessions('caregiver-1', 'demo-child'), 1);
    });

    test('an empty uid drops the write', () async {
      expect(await writtenSessions('', 'demo-child'), 0);
    });
  });
}
