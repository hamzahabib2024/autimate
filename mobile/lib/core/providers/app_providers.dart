import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../data/backend_contracts.dart';
import '../data/backup/backup_service.dart';
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
import '../../features/ai/data/ml_kit_expression_service.dart';
import '../../features/ai/data/platform_camera_permissions.dart';
import '../../features/ai/data/rule_based_ai_engine.dart';
import '../../features/ai/data/simulated_expression_service.dart';
import '../../features/ai/domain/ai_contracts.dart';
import '../../features/authentication/data/firebase_auth_repository.dart';
import '../../features/communication/data/image_source_service.dart';
import '../../features/communication/data/quick_phrase_widget_service.dart';
import '../../features/communication/data/voice_recording_service.dart';
import '../../features/communication/domain/phrase_bank.dart';
import '../../features/sensory_support/data/platform_ambient_sound_service.dart';
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

/// On-device expression classifier. Rule-based and explainable — see
/// `expression_classifier.dart` for why it is not a trained model.
final aiEngineProvider = Provider<AiEngine>((ref) => RuleBasedAiEngine());

/// Real OS camera permission, including the permanently-denied case that
/// must route to settings rather than re-prompt.
final cameraPermissionServiceProvider = Provider<CameraPermissionService>(
  (ref) => const PlatformCameraPermissionService(),
);

/// Expression practice source.
///
/// The ML Kit adapter is the real one; `SimulatedExpressionService` stays as
/// the fallback so the flow is demonstrable on a machine with no camera and
/// so a camera failure never leaves the screen dead. Which one is live is
/// decided at runtime by [MlKitExpressionService.isSupported].
final expressionPracticeServiceProvider =
    Provider<ExpressionPracticeService>((ref) => MlKitExpressionService());

/// The offline stand-in, provided separately so a caller can fall back to
/// it explicitly rather than by catching an error.
final simulatedExpressionServiceProvider =
    Provider<ExpressionPracticeService>(
  (ref) => SimulatedExpressionService(),
);

/// Records and plays caregiver voice clips for AAC cards.
final voiceRecordingServiceProvider = Provider<VoiceRecordingService>(
  (ref) => PlatformVoiceRecordingService(),
);

/// Assembles and applies profile backups.
final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    appState: ref.watch(appStateProvider),
    customCards: ref.watch(customCardRepositoryProvider),
    routines: ref.watch(routineRepositoryProvider),
  ),
);

/// Saved whole sentences, per child.
final phraseBankRepositoryProvider = Provider<PhraseBankRepository>(
  (ref) => LocalPhraseBankRepository(ref.watch(keyValueStoreProvider)),
);

/// Publishes urgent phrases to the home-screen widget. The native side is
/// written but has never run on a device.
final quickPhraseWidgetServiceProvider =
    Provider<QuickPhraseWidgetService>(
  (ref) => const QuickPhraseWidgetService(),
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
    phraseBankRepository: ref.watch(phraseBankRepositoryProvider),
    ambientSoundService: ref.watch(ambientSoundServiceProvider),
    settingsStore: ref.watch(keyValueStoreProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});
