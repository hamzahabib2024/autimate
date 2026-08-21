import 'package:flutter/material.dart';

import 'core/services/app_services.dart';
import 'core/services/tts_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ttsService = QueuedTtsService();
  await ttsService.initialise();
  final appState = AppState(MockAuthRepository(), ttsService);
  runApp(AutiMateApp(appState: appState));
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
        theme: AppTheme.light(sensoryMode: appState.sensoryMode),
        locale: appState.locale,
        supportedLocales: const [Locale('en'), Locale('ur')],
        home: AppShell(appState: appState),
      ),
    );
  }
}
