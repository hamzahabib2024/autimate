import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/local_progress_repository.dart';
import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/emotion_recognition/domain/emotion_activity_engine.dart';
import 'package:autimate/features/parent_dashboard/domain/emotion_trend.dart';
import 'package:autimate/features/parent_dashboard/presentation/dashboard_screen.dart';
import 'package:autimate/features/progress/domain/progress_models.dart';
import 'package:autimate/features/settings/presentation/settings_screen.dart';

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

ProgressRecord _session({
  required String type,
  required int score,
  required int total,
  required DateTime at,
}) {
  return ProgressRecord(
    recordedAt: at,
    result: SessionResult(
      childId: 'demo-child',
      activityType: type,
      score: score,
      total: total,
      levelPlayed: SupportLevel.beginner,
      levelAfter: SupportLevel.beginner,
      duration: const Duration(minutes: 2),
      completedAt: at,
      starsAwarded: 0,
    ),
  );
}

void main() {
  late AppState appState;

  setUp(() {
    appState = AppState(MockAuthRepository(), MockTtsService());
  });

  tearDown(() {
    appState.dispose();
  });

  group('emotion trend series', () {
    test('pools accuracy per day and leaves gap days null', () {
      final now = DateTime(2026, 8, 20, 12); // Thursday midday.
      final trend = const EmotionTrendSeries().build([
        // Today: one perfect and one half session → pooled 3/5.
        _session(
          type: 'emotion_identification',
          score: 1,
          total: 1,
          at: now.subtract(const Duration(hours: 1)),
        ),
        _session(
          type: 'emotion_identification',
          score: 2,
          total: 4,
          at: now.subtract(const Duration(hours: 2)),
        ),
        // Two days ago only.
        _session(
          type: 'emotion_identification',
          score: 2,
          total: 2,
          at: now.subtract(const Duration(days: 2)),
        ),
        // Yesterday has a non-emotion session only → stays a gap.
        _session(
          type: 'aac_practice',
          score: 5,
          total: 5,
          at: now.subtract(const Duration(days: 1)),
        ),
      ], now);

      expect(trend, hasLength(7));
      expect(trend.last.accuracy, closeTo(0.6, 0.0001));
      expect(trend.last.sessions, 5);
      expect(trend[4].accuracy, 1.0); // Two days ago (index 7-1-2).
      expect(trend[5].accuracy, isNull); // Yesterday gap.
      // Older days are empty too.
      expect(trend.first.accuracy, isNull);
    });

    test('non-emotion activity never leaks into the series', () {
      final now = DateTime(2026, 8, 20);
      final trend = const EmotionTrendSeries().build([
        _session(
          type: 'story_comprehension',
          score: 9,
          total: 10,
          at: now,
        ),
      ], now);
      expect(trend.every((point) => point.accuracy == null), isTrue);
    });
  });

  group('dashboard', () {
    testWidgets('trend card shows latest pooled accuracy', (tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final now = DateTime.now();
      await appState.progressRepository.recordSession(
        _session(
          type: 'emotion_identification',
          score: 3,
          total: 4,
          at: now.subtract(const Duration(hours: 1)),
        ).result,
      );
      await tester.pumpWidget(testApp(DashboardScreen(appState: appState)));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('emotion-trend')), findsOneWidget);
      expect(find.text('75% latest'), findsOneWidget);
    });

    testWidgets('empty history renders the gentle hint instead of a line',
        (tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(testApp(DashboardScreen(appState: appState)));
      await tester.pumpAndSettle();

      expect(
        find.text('No emotion sessions in the last 7 days yet.'),
        findsOneWidget,
      );
    });

    testWidgets('observations accept an optional category tag',
        (tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(testApp(DashboardScreen(appState: appState)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_note));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('observation-text')),
        'Needed a break after noise',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('observation-tag')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sensory').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('observation-save')));
      await tester.pumpAndSettle();

      expect(find.text('Needed a break after noise'), findsOneWidget);
      expect(find.byKey(const ValueKey('note-tag-sensory')), findsOneWidget);

      final stored =
          await appState.progressRepository.getObservations('demo-child');
      expect(stored.single.tag, 'sensory');
    });

    testWidgets('notes without a chosen category default to general',
        (tester) async {
      final repo = InMemoryProgressRepository();
      await repo.recordObservation(
        ObservationNote(
          childId: 'demo-child',
          note: 'Great morning routine',
          authorRole: 'parent',
          createdAt: DateTime.now(),
        ),
      );
      final notes = await repo.getObservations('demo-child');
      expect(notes.single.tag, 'general');
    });

    testWidgets('tagged note survives repository roundtrip with local store',
        (tester) async {
      final store = _MapStore();
      final repo = LocalProgressRepository(store: store);
      await repo.recordObservation(
        ObservationNote(
          childId: 'demo-child',
          note: 'Calmer with headphones',
          authorRole: 'teacher',
          createdAt: DateTime(2026, 8, 21),
          tag: 'sensory',
        ),
      );
      final reloaded = LocalProgressRepository(store: store);
      final notes = await reloaded.getObservations('demo-child');
      expect(notes.single.tag, 'sensory');
      expect(notes.single.note, 'Calmer with headphones');
    });
  });

  group('profile management', () {
    testWidgets('existing profiles can be renamed and re-levelled',
        (tester) async {
      tester.view.physicalSize = const Size(900, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(testApp(SettingsScreen(appState: appState)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('edit-child-demo-child')));
      await tester.pumpAndSettle();
      expect(find.text('Ayaan'), findsWidgets);

      await tester.enterText(
        find.byKey(const ValueKey('edit-child-name')),
        'Ayaan Jr.',
      );
      await tester.pump();
      await tester.tap(find.text('Intermediate support level'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('edit-child-save')));
      await tester.pumpAndSettle();

      expect(appState.selectedChild.name, 'Ayaan Jr.');
      expect(appState.selectedChild.supportLevel, 'Intermediate');
      expect(find.text('Ayaan Jr.'), findsOneWidget);
    });

    testWidgets('edits persist through the settings store', (tester) async {
      final store = _MapStore();
      final state = AppState(
        MockAuthRepository(),
        MockTtsService(),
        settingsStore: store,
      );
      addTearDown(state.dispose);

      state.updateChild(
        id: state.selectedChild.id,
        name: 'Zoya',
        supportLevel: 'Advanced',
      );

      final reloaded = AppState(
        MockAuthRepository(),
        MockTtsService(),
        settingsStore: store,
      );
      addTearDown(reloaded.dispose);
      await reloaded.loadPersistedSettings();

      expect(reloaded.children.single.name, 'Zoya');
      expect(reloaded.children.single.supportLevel, 'Advanced');
    });

    test('unknown profile ids are ignored safely', () {
      appState.updateChild(id: 'ghost', name: 'X', supportLevel: 'Beginner');
      expect(appState.children, hasLength(1));
      expect(appState.selectedChild.name, 'Ayaan');
    });
  });
}
