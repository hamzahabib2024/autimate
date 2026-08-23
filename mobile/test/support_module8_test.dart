import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/core/services/tts_service.dart';
import 'package:autimate/features/emotion_recognition/domain/emotion_activity_engine.dart';
import 'package:autimate/features/learning/presentation/learning_path_screen.dart';
import 'package:autimate/features/settings/presentation/settings_screen.dart';
import 'package:autimate/features/settings/presentation/support_level_screen.dart';
import 'package:autimate/features/learning/domain/interest_repository.dart';

import 'helpers/test_app.dart';

class _MapStore implements KeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
}

class _RecordingTts implements TtsService {
  final List<String> spoken = [];

  @override
  Future<void> initialise() async {}

  @override
  Future<void> speak(String text, Locale locale) async => spoken.add(text);

  @override
  Future<void> stop() async {}
}

void main() {
  late AppState appState;

  setUp(() {
    appState = AppState(MockAuthRepository(), MockTtsService());
  });

  tearDown(() {
    appState.dispose();
  });

  group('support preference state', () {
    test('effective level falls back to the profile assessment', () {
      expect(
        appState.effectiveSupportFor('demo-child'),
        SupportLevel.beginner,
      );
      appState.updateChild(
        id: 'demo-child',
        name: 'Ayaan',
        supportLevel: 'Advanced',
      );
      expect(
        appState.effectiveSupportFor('demo-child'),
        SupportLevel.advanced,
      );
    });

    test('caregiver override beats the profile level', () {
      appState.setSupportPreference(
        childId: 'demo-child',
        locked: false,
        level: SupportLevel.intermediate,
      );
      expect(
        appState.supportOverrideFor('demo-child'),
        SupportLevel.intermediate,
      );
      expect(
        appState.effectiveSupportFor('demo-child'),
        SupportLevel.intermediate,
      );
      expect(appState.isSupportLockedFor('demo-child'), isFalse);
    });

    test('lock and override persist per child across reloads', () async {
      final store = _MapStore();
      final state = AppState(
        MockAuthRepository(),
        MockTtsService(),
        settingsStore: store,
      );
      addTearDown(state.dispose);

      state.setSupportPreference(
        childId: 'demo-child',
        locked: true,
        level: SupportLevel.intermediate,
      );

      final reloaded = AppState(
        MockAuthRepository(),
        MockTtsService(),
        settingsStore: store,
      );
      addTearDown(reloaded.dispose);
      await reloaded.loadPersistedSettings();

      expect(reloaded.supportOverrideFor('demo-child'),
          SupportLevel.intermediate);
      expect(reloaded.isSupportLockedFor('demo-child'), isTrue);
    });

    test('clearing the override returns the child to automatic rules',
        () async {
      appState.setSupportPreference(
        childId: 'demo-child',
        locked: true,
        level: SupportLevel.beginner,
      );
      appState.setSupportPreference(
        childId: 'demo-child',
        locked: false,
        level: null,
      );
      expect(appState.supportOverrideFor('demo-child'), isNull);
      expect(appState.isSupportLockedFor('demo-child'), isFalse);
    });
  });

  group('picker screen', () {
    testWidgets('settings tile opens the picker instead of a placeholder',
        (tester) async {
      tester.view.physicalSize = const Size(900, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(testApp(SettingsScreen(appState: appState)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Support level'));
      await tester.pumpAndSettle();

      expect(find.text('Follow progress automatically'), findsOneWidget);
      expect(find.byKey(const ValueKey('level-lock')), findsOneWidget);
    });

    testWidgets('choosing a level persists it live; lock stops stepping',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(testApp(SupportLevelScreen(appState: appState)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('level-option-advanced')));
      await tester.pumpAndSettle();
      expect(
        appState.supportOverrideFor('demo-child'),
        SupportLevel.advanced,
      );

      await tester.tap(find.byKey(const ValueKey('level-lock')));
      await tester.pumpAndSettle();
      expect(appState.isSupportLockedFor('demo-child'), isTrue);
      // Locked notice names the fixed level.
      expect(find.textContaining('Locked'), findsOneWidget);
    });
  });

  group('beginner audio assistance', () {
    testWidgets('learning activity speaks questions at beginner only',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final tts = _RecordingTts();
      final seeded = _MapStore();
      await LocalInterestRepository(store: seeded).setInterests(
        'demo-child',
        {'cars'},
      );
      final withRepo = AppState(
        MockAuthRepository(),
        tts,
        interestRepository: LocalInterestRepository(store: seeded),
      );
      addTearDown(withRepo.dispose);
      withRepo.setSupportPreference(
        childId: 'demo-child',
        locked: false,
        level: SupportLevel.beginner,
      );

      await tester.pumpWidget(testApp(LearningPathScreen(appState: withRepo)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('path-wheels-count')));
      await tester.pumpAndSettle();

      expect(tts.spoken, hasLength(1));
      expect(tts.spoken.single, contains('How many'));

      // Answer correctly → next question is also spoken.
      await tester.tap(find.byKey(const ValueKey('answer-0')));
      await tester.pumpAndSettle();
      expect(tts.spoken, hasLength(2));
    });

    testWidgets('advanced support stays silent', (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final tts = _RecordingTts();
      final seeded = _MapStore();
      await LocalInterestRepository(store: seeded).setInterests(
        'demo-child',
        {'cars'},
      );
      final state = AppState(
        MockAuthRepository(),
        tts,
        interestRepository: LocalInterestRepository(store: seeded),
      );
      addTearDown(state.dispose);
      state.setSupportPreference(
        childId: 'demo-child',
        locked: false,
        level: SupportLevel.advanced,
      );

      await tester.pumpWidget(testApp(LearningPathScreen(appState: state)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('path-wheels-count')));
      await tester.pumpAndSettle();
      expect(tts.spoken, isEmpty);
    });

    testWidgets('emotion practice honours the locked caregiver level',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final state = AppState(MockAuthRepository(), MockTtsService());
      addTearDown(state.dispose);
      state.setSupportPreference(
        childId: 'demo-child',
        locked: true,
        level: SupportLevel.advanced,
      );
      state.updateChild(
        id: 'demo-child',
        name: 'Ayaan',
        supportLevel: 'Beginner',
      );
      expect(
        state.effectiveSupportFor('demo-child'),
        SupportLevel.advanced,
      );
    });
  });
}
