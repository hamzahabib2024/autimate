import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../data/local_progress_repository.dart';
import '../data/local_store.dart';
import '../data/offline_sync_queue.dart';
import '../services/app_services.dart';
import '../services/tts_service.dart';
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

/// Authentication boundary. Firebase Auth replaces this when configured.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);

/// Durable offline progress store.
final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => LocalProgressRepository(store: ref.watch(keyValueStoreProvider)),
);

/// Durable offline routine store.
final routineRepositoryProvider = Provider<RoutineRepository>(
  (ref) => LocalRoutineRepository(store: ref.watch(keyValueStoreProvider)),
);

/// Application state wired from the providers above.
final appStateProvider = ChangeNotifierProvider<AppState>((ref) {
  return AppState(
    ref.watch(authRepositoryProvider),
    ref.watch(ttsServiceProvider),
    progressRepository: ref.watch(progressRepositoryProvider),
    routineRepository: ref.watch(routineRepositoryProvider),
    settingsStore: ref.watch(keyValueStoreProvider),
  );
});
