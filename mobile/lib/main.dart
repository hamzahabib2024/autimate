import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers/app_providers.dart';
import 'core/services/app_services.dart';
import 'core/services/tts_service.dart';
import 'core/data/local_store.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/app_shell.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final keyValueStore = SharedPrefsKeyValueStore(prefs);

  final ttsService = QueuedTtsService();
  await ttsService.initialise();

  final container = ProviderContainer(
    overrides: [keyValueStoreProvider.overrideWithValue(keyValueStore)],
  );

  final appState = container.read(appStateProvider);
  await appState.loadPersistedSettings();
  appState.startListeningToConnectivity();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: AutiMateApp(appState: appState),
    ),
  );
}

class AutiMateApp extends StatelessWidget {
  const AutiMateApp({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
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
        locale: appState.locale,
        supportedLocales: const [Locale('en'), Locale('ur')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: appState.onboarded
            ? AppShell(appState: appState)
            : OnboardingScreen(appState: appState),
      ),
    );
  }
}
