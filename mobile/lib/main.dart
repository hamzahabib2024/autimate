import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/data/firebase/firebase_bootstrap.dart';
import 'firebase_options.dart';
import 'core/providers/app_providers.dart';
import 'core/services/app_services.dart';
import 'core/services/tts_service.dart';
import 'core/data/backup/backup_service.dart';
import 'core/data/local_store.dart';
import 'features/communication/data/image_source_service.dart';
import 'features/communication/data/voice_recording_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'features/home/presentation/app_shell.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/onboarding/presentation/splash_screen.dart';
import 'l10n/generated/app_localizations.dart';

/// The FlutterFire-generated options for this platform, or null when the
/// current platform has none configured.
///
/// Wrapped because `DefaultFirebaseOptions.currentPlatform` throws for an
/// unconfigured platform rather than returning null, and an unconfigured
/// desktop run must fall back to local repositories rather than crash on
/// launch.
FirebaseOptions? _generatedFirebaseOptions() {
  try {
    return DefaultFirebaseOptions.currentPlatform;
  } catch (_) {
    return null;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final keyValueStore = SharedPrefsKeyValueStore(prefs);

  final ttsService = QueuedTtsService();
  await ttsService.initialise();

  // Firebase is attempted only when credentials were injected at build
  // time, and a failure here is not fatal: the app falls back to local
  // repositories so a misconfigured backend can never cost a child the app.
  final config = AppConfig.fromEnvironment();
  // The generated options win when present; dart-defines remain the
  // alternative for a build that keeps configuration out of the repository.
  final firebaseReady = await FirebaseBootstrap.ensureInitialised(
    config,
    generatedOptions: _generatedFirebaseOptions(),
  );

  // A holder, because the override has to exist before the container is
  // built while AppState can only be read out of it afterwards — and
  // AppState itself depends on the progress repository that reads this.
  // Safe because the closure is only ever called during a write, long
  // after the assignment below.
  AppState? activeState;

  final container = ProviderContainer(
    overrides: [
      keyValueStoreProvider.overrideWithValue(keyValueStore),
      firebaseReadyProvider.overrideWithValue(firebaseReady),
      // Without this the Firestore repositories wrote against an empty
      // child id, which their own guards treat as "no child selected" —
      // so every remote write silently did nothing.
      currentChildIdProvider.overrideWithValue(
        () => activeState?.selectedChild.id ?? '',
      ),
    ],
  );

  final appState = container.read(appStateProvider);
  activeState = appState;
  await appState.loadPersistedSettings();
  appState.startListeningToConnectivity();

  // Replay anything queued while offline, then again on every reconnect.
  final syncBackend = container.read(syncBackendProvider);
  if (syncBackend != null) {
    final queue = container.read(offlineSyncQueueProvider);
    unawaited(syncBackend.drain(queue));
    appState.addListener(() {
      if (!appState.offline) unawaited(syncBackend.drain(queue));
    });
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: AutiMateApp(
        appState: appState,
        backupService: container.read(backupServiceProvider),
        imageSource: container.read(imageSourceServiceProvider),
        voiceRecorder: container.read(voiceRecordingServiceProvider),
      ),
    ),
  );
}

class AutiMateApp extends StatefulWidget {
  const AutiMateApp({
    required this.appState,
    this.backupService,
    this.imageSource = const UnavailableImageSourceService(),
    this.voiceRecorder = const UnavailableVoiceRecordingService(),
    super.key,
  });

  final AppState appState;

  /// Platform services, supplied by the composition root. They default to
  /// inert implementations so a widget test can build the whole app without
  /// a filesystem, a microphone, or a document picker.
  final BackupService? backupService;
  final ImageSourceService imageSource;
  final VoiceRecordingService voiceRecorder;

  @override
  State<AutiMateApp> createState() => _AutiMateAppState();
}

class _AutiMateAppState extends State<AutiMateApp> {
  /// The intro plays once per launch and is never a gate — it ends itself,
  /// and a tap anywhere ends it sooner.
  bool _introDone = false;

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) => MaterialApp(
        title: 'AutiMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(
          sensoryMode: appState.sensoryMode,
          locale: appState.locale,
        ),
        darkTheme: AppTheme.dark(
          sensoryMode: appState.sensoryMode,
          locale: appState.locale,
        ),
        themeMode: appState.themeMode,
        // One place caps the OS text scaler for the whole app — see
        // AppTypography.maxSystemTextScale for why.
        builder: (context, child) =>
            AppTypography.clampTextScale(child: child ?? const SizedBox()),
        locale: appState.locale,
        supportedLocales: const [Locale('en'), Locale('ur')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: !_introDone
            ? SplashScreen(
                appState: appState,
                onComplete: () => setState(() => _introDone = true),
              )
            : appState.onboarded
            ? AppShell(
                appState: appState,
                backupService: widget.backupService,
                imageSource: widget.imageSource,
                voiceRecorder: widget.voiceRecorder,
              )
            : OnboardingScreen(appState: appState),
      ),
    );
  }
}
