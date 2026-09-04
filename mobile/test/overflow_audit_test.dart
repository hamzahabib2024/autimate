import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/backup/backup_service.dart';
import 'package:autimate/core/data/local_progress_repository.dart';
import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/communication/domain/custom_card_repository.dart';
import 'package:autimate/features/communication/presentation/aac_screen.dart';
import 'package:autimate/features/communication/presentation/board_options_screen.dart';
import 'package:autimate/features/communication/presentation/literacy_screen.dart';
import 'package:autimate/features/emotion_recognition/domain/emotion_activity_engine.dart';
import 'package:autimate/features/emotion_recognition/presentation/emotion_screen.dart';
import 'package:autimate/features/emotion_recognition/presentation/intensity_screen.dart';
import 'package:autimate/features/gamification/presentation/gamification_screen.dart';
import 'package:autimate/features/learning/presentation/learning_path_screen.dart';
import 'package:autimate/features/onboarding/presentation/onboarding_screen.dart';
import 'package:autimate/features/parent_dashboard/presentation/achievements_screen.dart';
import 'package:autimate/features/parent_dashboard/presentation/dashboard_screen.dart';
import 'package:autimate/features/routines/domain/routine_repository.dart';
import 'package:autimate/features/routines/presentation/routines_screen.dart';
import 'package:autimate/features/routines/presentation/waiting_screen.dart';
import 'package:autimate/features/sensory_support/presentation/calm_activities_screen.dart';
import 'package:autimate/features/sensory_support/presentation/sensory_support_screen.dart';
import 'package:autimate/features/settings/presentation/backup_screen.dart';
import 'package:autimate/features/settings/presentation/parent_gate_screen.dart';
import 'package:autimate/features/settings/presentation/settings_screen.dart';
import 'package:autimate/features/social_communication/presentation/social_stories_screen.dart';

import 'helpers/test_app.dart';

/// Every screen, at the sizes that actually break layouts.
///
/// This suite exists because a real overflow reached a device: the parent
/// gate sized its keypad from `MediaQuery.sizeOf(context).width` rather than
/// the width it was given, so on a wide phone the keys added up to more than
/// the padded column could hold. Nothing in the suite caught it, because
/// every widget test until now ran at one comfortable size.
///
/// The sizes below are chosen to hurt:
///
/// * **320 x 640** — a small budget Android phone, the likeliest device in
///   the intended market.
/// * **430 x 932** — a large modern phone, which is where the parent-gate
///   bug appeared, since a wider screen made the fixed keys wider still.
/// * **320 x 640 at 1.6x text** — a caregiver with large system text, which
///   is common and which no other test covers.
///
/// A layout overflow surfaces as an exception during pump, so
/// `tester.takeException()` is the assertion.
const List<({String name, Size size, double textScale})> _viewports = [
  (name: 'small phone', size: Size(320, 640), textScale: 1.0),
  (name: 'large phone', size: Size(430, 932), textScale: 1.0),
  (name: 'small phone, large text', size: Size(320, 640), textScale: 1.6),
];

AppState _appState({bool sensory = false}) {
  final store = InMemoryKeyValueStore();
  final state = AppState(
    MockAuthRepository(),
    MockTtsService(),
    progressRepository: LocalProgressRepository(store: store),
    routineRepository: LocalRoutineRepository(store: store),
    customCardRepository: InMemoryCustomCardRepository(),
    settingsStore: store,
  );
  if (sensory) state.toggleSensoryMode(true);
  return state;
}

BackupService _backup(AppState appState) => BackupService(
  appState: appState,
  customCards: InMemoryCustomCardRepository(),
  routines: LocalRoutineRepository(store: InMemoryKeyValueStore()),
);

/// Pumps [build] at [viewport] and fails if anything overflowed.
Future<void> _expectNoOverflow(
  WidgetTester tester,
  ({String name, Size size, double textScale}) viewport,
  Widget Function(AppState appState) build, {
  bool sensory = false,
}) async {
  tester.view.physicalSize = viewport.size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final appState = _appState(sensory: sensory);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: viewport.size,
        textScaler: TextScaler.linear(viewport.textScale),
      ),
      child: testApp(build(appState)),
    ),
  );
  // Fixed pumps rather than pumpAndSettle: the calming screen's drift and
  // the mascot's breath are continuous by design and never settle, so
  // settling would time out rather than tell us anything about layout.
  for (var frame = 0; frame < 6; frame++) {
    await tester.pump(const Duration(milliseconds: 120));
  }

  final failure = tester.takeException();
  expect(
    failure,
    isNull,
    reason: 'overflowed on ${viewport.name} '
        '(${viewport.size.width.toInt()}x${viewport.size.height.toInt()}, '
        'text ${viewport.textScale}x)',
  );
}

void main() {
  final screens = <String, Widget Function(AppState)>{
    'AAC board': (state) => AacScreen(appState: state),
    'board options': (state) => BoardOptionsScreen(appState: state),
    'reading support': (state) => LiteracyScreen(appState: state),
    'emotion practice': (state) => EmotionScreen(appState: state),
    'intensity scale': (state) =>
        IntensityScreen(appState: state, emotion: EmotionLabel.angry),
    'routines': (state) => RoutinesScreen(appState: state),
    'waiting board': (state) => WaitingScreen(appState: state),
    'sensory support': (state) => SensorySupportScreen(appState: state),
    'breathing': (state) => BreathingScreen(appState: state),
    'calming': (state) => CalmingScreen(appState: state),
    'dashboard': (state) => DashboardScreen(appState: state),
    'achievements': (state) => AchievementsScreen(appState: state),
    'gamification': (state) => GamificationScreen(appState: state),
    'learning path': (state) => LearningPathScreen(appState: state),
    'social stories': (state) => SocialStoriesScreen(appState: state),
    'settings': (state) => SettingsScreen(appState: state),
    'parent gate': (state) => ParentGateScreen(appState: state),
    'onboarding': (state) => OnboardingScreen(appState: state),
  };

  group('no screen overflows', () {
    for (final entry in screens.entries) {
      for (final viewport in _viewports) {
        testWidgets('${entry.key} — ${viewport.name}', (tester) async {
          await _expectNoOverflow(tester, viewport, entry.value);
        });
      }
    }

    // Backup takes a service, so it is built separately rather than being
    // squeezed into the map above.
    for (final viewport in _viewports) {
      testWidgets('backup — ${viewport.name}', (tester) async {
        await _expectNoOverflow(
          tester,
          viewport,
          (state) => BackupScreen(appState: state, service: _backup(state)),
        );
      });
    }
  });

  group('sensory mode does not change layout safety', () {
    // Sensory mode flattens elevation and swaps borders in, which changes
    // box metrics. Worth its own pass rather than assuming.
    for (final entry in screens.entries) {
      testWidgets('${entry.key} — small phone, sensory', (tester) async {
        await _expectNoOverflow(
          tester,
          _viewports.first,
          entry.value,
          sensory: true,
        );
      });
    }
  });

  group('the parent-gate keypad fits at every width', () {
    // The specific regression: keys were sized from the screen rather than
    // from the space the pad was given.
    for (final width in [280.0, 320.0, 360.0, 390.0, 430.0, 600.0]) {
      testWidgets('keypad at ${width.toInt()}dp', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // The gate auto-passes until a PIN exists, so one must be set or
        // the keypad is never built.
        final appState = _appState();
        await appState.setParentPin('1234');

        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(size: Size(width, 800)),
            child: testApp(ParentGateScreen(appState: appState)),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull,
            reason: 'keypad overflowed at ${width}dp');
        // Every key is still reachable, not merely non-overflowing.
        for (var digit = 0; digit <= 9; digit++) {
          expect(
            find.byKey(ValueKey('pin-digit-$digit')),
            findsOneWidget,
            reason: 'digit $digit missing at ${width}dp',
          );
        }
        expect(find.byKey(const ValueKey('pin-delete')), findsOneWidget);
      });
    }
  });
}
