import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../config/app_config.dart';

/// Brings Firebase up from `--dart-define` values, or reports honestly that
/// it could not.
///
/// Two deliberate choices here.
///
/// **Options come from [AppConfig], not a generated `firebase_options.dart`.**
/// That means no file has to be generated or committed to switch the backend
/// on: whoever holds the credentials supplies them at build time and nothing
/// in source control changes. It also keeps secrets out of the repository by
/// construction rather than by discipline.
///
/// **Failure is never fatal.** If credentials are absent, wrong, or the
/// platform rejects them, [ensureInitialised] returns false and the app
/// carries on against local repositories. A child in the middle of building
/// a sentence must not lose the app because a backend is misconfigured.
class FirebaseBootstrap {
  const FirebaseBootstrap();

  /// Attempts initialisation. Returns true only when Firebase is genuinely
  /// usable; callers should treat false as "run local-only".
  static Future<bool> ensureInitialised(AppConfig config) async {
    if (!config.firebaseConfigured) return false;
    try {
      if (Firebase.apps.isNotEmpty) return true;
      await Firebase.initializeApp(options: optionsFrom(config));
      return true;
    } catch (error, stack) {
      debugPrint('Firebase unavailable, continuing offline-only: $error');
      assert(() {
        debugPrintStack(stackTrace: stack, label: 'firebase-init');
        return true;
      }());
      return false;
    }
  }

  /// Maps the injected configuration onto [FirebaseOptions].
  ///
  /// `messagingSenderId` and `storageBucket` are optional in practice — a
  /// build that only needs Auth and Firestore can leave them empty.
  static FirebaseOptions optionsFrom(AppConfig config) => FirebaseOptions(
    apiKey: config.firebaseApiKey,
    appId: config.firebaseAppId,
    projectId: config.firebaseProjectId,
    messagingSenderId: config.firebaseMessagingSenderId,
    storageBucket: config.firebaseStorageBucket.isEmpty
        ? null
        : config.firebaseStorageBucket,
  );
}
