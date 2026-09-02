import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/emotion_recognition/domain/emotion_activity_engine.dart';
import 'package:autimate/features/gamification/domain/badges.dart';
import 'package:autimate/features/gamification/domain/reward_policy.dart';
import 'package:autimate/features/gamification/presentation/gamification_screen.dart';
import 'package:autimate/features/learning/domain/interest_repository.dart';
import 'package:autimate/features/learning/presentation/learning_path_screen.dart';
import 'package:autimate/features/settings/presentation/support_level_screen.dart';

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

void main() {
  late AppState appState;

  setUp(() {
    appState = AppState(MockAuthRepository(), MockTtsService());
  });

  tearDown(() {
    appState.dispose();
  });

  group('reward frequency per level', () {
    test('cadence is one, two, then three sessions per star', () {
      const policy = RewardPolicy();
      expect(policy.sessionsPerStar(SupportLevel.beginner), 1);
      expect(policy.sessionsPerStar(SupportLevel.intermediate), 2);
      expect(policy.sessionsPerStar(SupportLevel.advanced), 3);
      expect(policy.shouldReward(level: SupportLevel.beginner,
          completedSessions: 0), isFalse);
    });

    test('intermediate pays on every second completed session', () {
      appState.setSupportPreference(
        childId: 'demo-child',
        locked: false,
        level: SupportLevel.intermediate,
      );
      final first = appState.recordSessionCompleted(
        childId: 'demo-child',
        level: SupportLevel.intermediate,
      );
      final starsAfterFirst = appState.stars;
      final second = appState.recordSessionCompleted(
        childId: 'demo-child',
        level: SupportLevel.intermediate,
      );
      expect(first, isFalse);
      expect(starsAfterFirst, appState.stars - (second ? 1 : 0));
      expect(second, isTrue);
    });

    test('reward ledger persists across reloads', () async {
      final store = _MapStore();
      final state = AppState(
        MockAuthRepository(),
        MockTtsService(),
        settingsStore: store,
      );
      addTearDown(state.dispose);
      state.recordSessionCompleted(
        childId: 'demo-child',
        level: SupportLevel.intermediate,
      );

      final reloaded = AppState(
        MockAuthRepository(),
        MockTtsService(),
        settingsStore: store,
      );
      addTearDown(reloaded.dispose);
      await reloaded.loadPersistedSettings();

      // The pending count survived, so this second session pays out.
      final due = reloaded.recordSessionCompleted(
        childId: 'demo-child',
        level: SupportLevel.intermediate,
      );
      expect(due, isTrue);
    });
  });

  group('live level-change restart prompt', () {
    testWidgets('changing support mid-activity prompts instead of switching',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final seeded = _MapStore();
      await LocalInterestRepository(store: seeded).setInterests(
        'demo-child',
        {'cars'},
      );
      final state = AppState(
        MockAuthRepository(),
        MockTtsService(),
        interestRepository: LocalInterestRepository(store: seeded),
      );
      addTearDown(state.dispose);

      await tester.pumpWidget(testApp(LearningPathScreen(appState: state)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('path-wheels-count')));
      await tester.pumpAndSettle();

      // Caregiver raises the level while the child is mid-question.
      state.setSupportPreference(
        childId: 'demo-child',
        locked: false,
        level: SupportLevel.advanced,
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('level-change-prompt')),
        findsOneWidget,
      );
      // The question did not silently change under the child.
      expect(find.text('Question 1 of 2'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('level-restart')));
      await tester.pumpAndSettle();
      expect(find.text('Question 1 of 2'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('level-change-prompt')),
        findsNothing,
      );
    });
  });

  group('streak calculation', () {
    test('counts consecutive days ending today', () {
      final today = DateTime(2026, 8, 22);
      final streak = currentStreak([
        '2026-08-20',
        '2026-08-21',
        '2026-08-22',
      ], today);
      expect(streak, 3);
    });

    test('an inactive today keeps yesterday-based streak alive', () {
      final today = DateTime(2026, 8, 22);
      final streak = currentStreak([
        '2026-08-20',
        '2026-08-21',
      ], today);
      expect(streak, 2);
    });

    test('a real gap breaks the streak', () {
      final today = DateTime(2026, 8, 22);
      expect(currentStreak(['2026-08-19', '2026-08-21'], today), 1);
      expect(currentStreak(<String>[], today), 0);
    });
  });

  group('badge evaluation', () {
    test('thresholds map counters to earned badges in catalog order', () {
      final badges = evaluateBadges(
        sessionCount: 12,
        streakDays: 4,
        stars: 30,
      );
      expect(badges.every((badge) => badge.earned), isTrue);

      final none = evaluateBadges(
        sessionCount: 0,
        streakDays: 0,
        stars: 0,
      );
      expect(none.every((badge) => !badge.earned), isTrue);
      expect(none.first.current, 0);
    });

    test('partial progress stays clamped below one', () {
      final badges = evaluateBadges(
        sessionCount: 3,
        streakDays: 1,
        stars: 5,
      );
      final tenTogether =
          badges.firstWhere((b) => b.definition.id == 'ten-sessions');
      expect(tenTogether.earned, isFalse);
      expect(tenTogether.progress, closeTo(0.3, 0.0001));
    });
  });

  group('gamification screen', () {
    testWidgets('shows cooperative framing, ring, and earned vs locked badges',
        (tester) async {
      tester.view.physicalSize = const Size(900, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      for (var i = 1; i <= 2; i++) {
        await appState.progressRepository.recordSession(
          SessionResult(
            childId: 'demo-child',
            activityType: 'emotion_identification',
            score: 2,
            total: 2,
            levelPlayed: SupportLevel.beginner,
            levelAfter: SupportLevel.beginner,
            duration: const Duration(minutes: 1),
            completedAt: DateTime.now().subtract(Duration(days: 2 - i)),
            starsAwarded: 1,
          ),
        );
      }

      await tester.pumpWidget(testApp(GamificationScreen(appState: appState)));
      await tester.pumpAndSettle();

      expect(find.text('We are a team'), findsOneWidget);
      expect(find.byKey(const ValueKey('progress-ring')), findsOneWidget);
      expect(find.text('2 days in a row'), findsOneWidget);

      // Two sessions: first-step earned, ten-together still locked.
      expect(
        tester
            .widgetList(find.byKey(const ValueKey('badge-first-session')))
            .isNotEmpty,
        isTrue,
      );
      expect(find.text('2 of 10'), findsWidgets);
      expect(find.text('25 of 25'), findsNothing);
    });
  });

  group('picker cadence copy', () {
    testWidgets('each level explains its reward frequency', (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(testApp(SupportLevelScreen(appState: appState)));
      await tester.pumpAndSettle();

      expect(
        find.text('A star after every completed session.'),
        findsOneWidget,
      );
      expect(find.textContaining('A star every 3 completed'),
          findsOneWidget);
    });
  });
}
