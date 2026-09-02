import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../data/backend_contracts.dart';
import '../data/firebase/firebase_bootstrap.dart';
import '../data/firebase/firestore_child_repository.dart';
import '../data/firebase/firestore_progress_repository.dart';
import '../data/firebase/firestore_sync_backend.dart';
import '../data/local_progress_repository.dart';
import '../data/local_store.dart';
import '../data/offline_sync_queue.dart';
import '../services/app_services.dart';
import '../services/connectivity_service.dart';
import '../services/tts_service.dart';
import '../../features/authentication/data/firebase_auth_repository.dart';
import '../../features/communication/data/image_source_service.dart';
import '../../features/sensory_support/data/platform_ambient_sound_service.dart';
import '../../features/sensory_support/domain/ambient_sound.dart';
import '../../features/communication/domain/custom_card_repository.dart';
import '../../features/progress/domain/progress_models.dart';
import '../../features/routines/domain/routine_repository.dart';

/// Compile-time environment configuration.
final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);

/// Durable key-value storage. Overridden in `main()` after
/// `SharedPreferences.getInstance()` resolves; tests override with an
/// [InMemoryKeyValueStore].
final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => throw UnimplementedError(
    'keyValueStoreProvider must be overridden before use',
  ),
);

/// Offline mutation queue drained by a future Firestore adapter.
final offlineSyncQueueProvider = Provider<OfflineSyncQueue>(
  (ref) => OfflineSyncQueue(store: ref.watch(keyValueStoreProvider)),
);

/// Platform TTS. A test/demo override can supply [MockTtsService].
final ttsServiceProvider = Provider<TtsService>(
  (ref) => QueuedTtsService(),
);

/// Whether Firebase actually came up this run.
///
/// Overridden in `main()` with the result of [FirebaseBootstrap]. It is a
/// separate flag from `AppConfig.firebaseConfigured` on purpose: credentials
/// being *present* and Firebase being *usable* are different facts, and only
/// the second one should switch the app off local repositories.
final firebaseReadyProvider = Provider<bool>((ref) => false);

/// Live Firestore handle. Only ever read when [firebaseReadyProvider] is
/// true — touching it otherwise would hit an uninitialised plugin.
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

/// Caregiver authentication. Falls back to the mock repository whenever
/// Firebase is not up, so sign-in still works offline for demos.
final firebaseAuthRepositoryProvider = Provider<FirebaseAuthRepository?>(
  (ref) => ref.watch(firebaseReadyProvider)
      ? FirebaseAuthRepository()
      : null,
);

/// The signed-in caregiver's id, or empty. Firestore repositories call this
/// on every operation rather than caching, so signing in mid-session takes
/// effect immediately.
final currentUidProvider = Provider<String Function()>((ref) {
  final auth = ref.watch(firebaseAuthRepositoryProvider);
  return () => auth?.uid ?? '';
});

/// The child whose data writes should be attributed to.
///
/// Overridden in `main()` to read `AppState.selectedChild`. It is a
/// provider rather than a constructor argument because the active child
/// changes while the app is running.
final currentChildIdProvider = Provider<String Function()>(
  (ref) => () => '',
);

/// Authentication boundary.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) =>
      ref.watch(firebaseAuthRepositoryProvider) ?? MockAuthRepository(),
);

/// Progress store.
///
/// Local is the default and remains the source of truth for the child-facing
/// flows; Firestore takes over only with working credentials. Objective O7
/// (core features work offline) depends on this defaulting the safe way.
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  if (ref.watch(firebaseReadyProvider)) {
    return FirestoreProgressRepository(
      firestore: ref.watch(firestoreProvider),
      currentUid: ref.watch(currentUidProvider),
      currentChildId: ref.watch(currentChildIdProvider),
    );
  }
  return LocalProgressRepository(store: ref.watch(keyValueStoreProvider));
});

/// Child profiles. Local until Firebase is up.
final childRepositoryProvider = Provider<ChildRepository>((ref) {
  if (ref.watch(firebaseReadyProvider)) {
    return FirestoreChildRepository(
      firestore: ref.watch(firestoreProvider),
      currentUid: ref.watch(currentUidProvider),
    );
  }
  return MockChildRepository();
});

/// Drains `OfflineSyncQueue` into Firestore on reconnect. Null while
/// Firebase is unavailable, which is what keeps the queue accumulating
/// rather than discarding.
final syncBackendProvider = Provider<FirestoreSyncBackend?>((ref) {
  if (!ref.watch(firebaseReadyProvider)) return null;
  return FirestoreSyncBackend(
    firestore: ref.watch(firestoreProvider),
    currentUid: ref.watch(currentUidProvider),
  );
});

/// Durable offline routine store.
final routineRepositoryProvider = Provider<RoutineRepository>(
  (ref) => LocalRoutineRepository(store: ref.watch(keyValueStoreProvider)),
);

/// Durable store for caregiver-authored AAC cards.
final customCardRepositoryProvider = Provider<CustomCardRepository>(
  (ref) => LocalCustomCardRepository(ref.watch(keyValueStoreProvider)),
);

/// Gallery/camera boundary for custom-card pictures. Tests and desktop
/// runs override this with [UnavailableImageSourceService].
final imageSourceServiceProvider = Provider<ImageSourceService>(
  (ref) => PlatformImageSourceService(),
);

/// Gentle ambient sound for the calm screen. Falls back to silence when no
/// audio output exists, so the toggle stays honest either way.
final ambientSoundServiceProvider = Provider<AmbientSoundService>(
  (ref) => PlatformAmbientSoundService(),
);

/// Connectivity boundary. A verified connectivity_plus adapter replaces
/// the static implementation on device.
final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => const StaticConnectivityService(),
);

/// Application state wired from the providers above.
final appStateProvider = ChangeNotifierProvider<AppState>((ref) {
  return AppState(
    ref.watch(authRepositoryProvider),
    ref.watch(ttsServiceProvider),
    progressRepository: ref.watch(progressRepositoryProvider),
    routineRepository: ref.watch(routineRepositoryProvider),
    customCardRepository: ref.watch(customCardRepositoryProvider),
    ambientSoundService: ref.watch(ambientSoundServiceProvider),
    settingsStore: ref.watch(keyValueStoreProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});
