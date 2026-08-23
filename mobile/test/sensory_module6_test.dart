import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/ai/domain/ai_contracts.dart';
import 'package:autimate/features/home/presentation/app_shell.dart';
import 'package:autimate/features/sensory_support/presentation/calm_activities_screen.dart';
import 'package:autimate/features/sensory_support/presentation/sensory_support_screen.dart';

import 'helpers/test_app.dart';

class _RecordingAmbient implements AmbientSoundService {
  bool playing = false;

  @override
  bool get isPlaying => playing;

  @override
  Future<void> play() async => playing = true;

  @override
  Future<void> stop() async => playing = false;
}

void main() {
  late AppState appState;

  setUp(() {
    appState = AppState(MockAuthRepository(), MockTtsService());
  });

  tearDown(() {
    appState.dispose();
  });

  group('guided breathing', () {
    testWidgets('cycles inhale, hold, exhale over twelve seconds',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(testApp(BreathingScreen(appState: appState)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('breathing-toggle')));
      await tester.pump();
      // Inhale phase.
      expect(find.text('Breathe in'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4, milliseconds: 200));
      expect(find.text('Hold'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4, milliseconds: 200));
      expect(find.text('Breathe out'), findsOneWidget);
    });

    testWidgets('resting after a full cycle awards exactly one star',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final starsBefore = appState.stars;
      await tester.pumpWidget(testApp(BreathingScreen(appState: appState)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('breathing-toggle')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 12, milliseconds: 100));
      await tester.tap(find.byKey(const ValueKey('breathing-toggle')));
      await tester.pumpAndSettle();

      expect(appState.stars, starsBefore + 1);
    });

    testWidgets('sensory mode slows the cycle to sixteen seconds',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      appState.toggleSensoryMode(true);
      await tester.pumpWidget(testApp(BreathingScreen(appState: appState)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('breathing-toggle')));
      await tester.pump();
      // Four seconds in, still inhaling on the slower cycle.
      await tester.pump(const Duration(seconds: 4, milliseconds: 200));
      expect(find.text('Breathe in'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1, milliseconds: 500));
      expect(find.text('Hold'), findsOneWidget);
    });
  });

  group('calming patterns', () {
    testWidgets('renders the drifting composition and sound defaults to off',
        (tester) async {
      final ambient = _RecordingAmbient();
      final state = AppState(
        MockAuthRepository(),
        MockTtsService(),
        ambientSoundService: ambient,
      );
      addTearDown(state.dispose);

      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(testApp(CalmingScreen(appState: state)));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(const ValueKey('calm-pattern')), findsOneWidget);
      for (var i = 0; i < 5; i++) {
        expect(find.byKey(ValueKey('calm-shape-$i')), findsOneWidget);
      }
      expect(find.text('Gentle sound off'), findsOneWidget);
      expect(ambient.playing, isFalse);
    });

    testWidgets('sound toggle plays and stops without looping on its own',
        (tester) async {
      final ambient = _RecordingAmbient();
      final state = AppState(
        MockAuthRepository(),
        MockTtsService(),
        ambientSoundService: ambient,
      );
      addTearDown(state.dispose);

      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(testApp(CalmingScreen(appState: state)));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const ValueKey('calm-sound')));
      // The drift animation never rests, so only fixed pumps are safe here.
      await tester.pump();
      expect(ambient.playing, isTrue);
      expect(find.text('Gentle sound on'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('calm-sound')));
      await tester.pump();
      expect(ambient.playing, isFalse);
      expect(find.text('Gentle sound off'), findsOneWidget);
    });

    testWidgets('shapes stay still when sensory mode is on',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      appState.toggleSensoryMode(true);
      await tester.pumpWidget(testApp(CalmingScreen(appState: appState)));

      final before = tester.getTopLeft(
        find.byKey(const ValueKey('calm-shape-2')),
      );
      await tester.pump(const Duration(seconds: 3));
      final after = tester.getTopLeft(
        find.byKey(const ValueKey('calm-shape-2')),
      );
      expect(after, before);
    });
  });

  group('child-mode reachability', () {
    testWidgets('home shows the sensory tile while child mode is active',
        (tester) async {
      tester.view.physicalSize = const Size(900, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      appState.setChildMode(true);
      await tester.pumpWidget(testApp(AppShell(appState: appState)));
      await tester.pumpAndSettle();

      // The tile is reachable without any gate while child mode is active.
      expect(find.text('Sensory support'), findsOneWidget);
    });

    testWidgets('hub opens both calm activities', (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(testApp(SensorySupportScreen(appState: appState)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('open-breathing')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('breathing-cue')), findsOneWidget);
      expect(find.text('Begin'), findsWidgets);
      await tester.pageBack();
      await tester.pumpAndSettle();

      final calmingCard = find.byKey(const ValueKey('open-calming'));
      await tester.ensureVisible(calmingCard);
      await tester.pumpAndSettle();
      await tester.tap(calmingCard);
      // Drift never settles; two fixed pumps carry the push transition.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('calm-pattern')), findsOneWidget);
    });
  });
}
