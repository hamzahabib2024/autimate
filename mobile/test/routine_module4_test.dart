import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/routines/domain/routine_models.dart';
import 'package:autimate/features/routines/domain/routine_repository.dart';
import 'package:autimate/features/routines/presentation/routine_editor_screen.dart';
import 'package:autimate/features/routines/presentation/routines_screen.dart';

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

RoutineStep _step(
  String id, {
  String time = '10:00',
  String en = 'Snack',
  String ur = 'ناشتہ',
  IconData icon = Icons.restaurant,
  String cueEn = '',
  String cueUr = '',
}) =>
    RoutineStep(
      id: id,
      titleEn: en,
      titleUr: ur,
      timeOfDay: time,
      iconCode: icon,
      audioCueEn: cueEn,
      audioCueUr: cueUr,
    );

DateTime _at(int hour, int minute) => DateTime(2026, 8, 22, hour, minute);

void main() {
  group('RoutineStep model', () {
    test('map roundtrip preserves every field', () {
      final step = _step(
        'brush',
        time: '07:15',
        en: 'Brush teeth',
        ur: 'دانت صاف کرو',
        icon: Icons.bathtub_outlined,
        cueEn: 'Time to brush!',
        cueUr: 'دانت صاف کرنے کا وقت',
      );
      final restored = RoutineStep.fromMap(step.toMap());
      expect(restored.id, step.id);
      expect(restored.titleEn, step.titleEn);
      expect(restored.titleUr, step.titleUr);
      expect(restored.timeOfDay, step.timeOfDay);
      expect(restored.iconCode.codePoint, step.iconCode.codePoint);
      expect(restored.audioCueEn, step.audioCueEn);
      expect(restored.audioCueUr, step.audioCueUr);
    });

    test('unknown icon codes and missing cues fall back safely', () {
      final restored = RoutineStep.fromMap({
        'id': 'x',
        'titleEn': 'X',
        'titleUr': 'X',
        'timeOfDay': '08:00',
        'iconCode': 123456789,
      });
      expect(restored.iconCode, Icons.task_alt);
      expect(restored.audioCueEn, '');
    });

    test('cue and title helpers follow the locale', () {
      final step = _step(
        'a',
        en: 'Lunch',
        ur: 'دوپہر کا کھانا',
        cueEn: 'Yummy time',
        cueUr: 'کھانے کا وقت',
      );
      expect(step.titleFor(const Locale('ur')), 'دوپہر کا کھانا');
      expect(step.cueFor(const Locale('en')), 'Yummy time');
    });
  });

  group('repository persistence', () {
    late LocalRoutineRepository repo;
    late _MapStore store;

    setUp(() {
      store = _MapStore();
      repo = LocalRoutineRepository(store: store);
    });

    test('saveSteps persists edits and getSteps returns them', () async {
      await repo.saveSteps([
        _step('first', time: '06:30'),
        _step('second', time: '18:45'),
      ]);
      final steps = await repo.getSteps();
      expect(steps.map((s) => s.id), ['first', 'second']);
      expect(steps.first.timeOfDay, '06:30');
    });

    test('flexibility change roundtrips per child per day', () async {
      final today = DateTime(2026, 8, 22);
      expect(await repo.flexibilityChangeFor('c1', today), isNull);

      const change = FlexibilityChange(
        stepId: 'breakfast',
        newTitleEn: 'Picnic breakfast',
        newTitleUr: 'پکنک ناشتہ',
      );
      await repo.setFlexibilityChange('c1', today, change);
      final loaded = await repo.flexibilityChangeFor('c1', today);
      expect(loaded?.stepId, 'breakfast');
      expect(loaded?.newTitleUr, 'پکنک ناشتہ');

      // Other children and other days are untouched.
      expect(await repo.flexibilityChangeFor('c2', today), isNull);
      expect(
        await repo.flexibilityChangeFor('c1', DateTime(2026, 8, 23)),
        isNull,
      );

      await repo.setFlexibilityChange('c1', today, null);
      expect(await repo.flexibilityChangeFor('c1', today), isNull);
    });
  });

  group('reminder engine with countdown lead', () {
    const engine = RoutineReminderEngine();
    final steps = [
      _step('early', time: '09:00'),
      _step('middle', time: '09:05'),
      _step('far', time: '09:20'),
    ];

    List<String> warningsAt(
      DateTime now, {
      int lead = 5,
      Set<String> completed = const {},
      Set<String> announcedDue = const {},
      Set<String> announcedCountdown = const {},
    }) =>
        engine
            .pendingWarnings(
              steps: steps,
              completedIds: completed,
              announcedDueIds: announcedDue,
              announcedCountdownIds: announcedCountdown,
              leadMinutes: lead,
              now: now,
            )
            .map((w) => '${w.stepId}:${w.countdown}:${w.minutesUntil}')
            .toList();

    test('countdown fires only inside the lead window', () {
      // Five minutes before "early": it counts down; far steps stay quiet.
      expect(warningsAt(_at(8, 55)), ['early:true:5']);

      // At the scheduled time the step flips to its due announcement and
      // the next-in-window step starts counting down.
      expect(warningsAt(_at(9, 0)), ['early:false:0', 'middle:true:5']);

      // Outside any window nothing fires.
      expect(warningsAt(_at(8, 40)), isEmpty);

      // After every scheduled time each step is simply due.
      expect(warningsAt(_at(9, 26)), [
        'early:false:0',
        'middle:false:0',
        'far:false:0',
      ]);

      // Lead zero disables countdowns entirely.
      expect(warningsAt(_at(8, 55), lead: 0), isEmpty);
    });

    test('completed steps never warn again that day', () {
      expect(
        warningsAt(_at(9, 0), completed: {'early'}),
        ['middle:true:5'],
      );
      expect(
        warningsAt(_at(9, 6), completed: {'early', 'middle'}),
        isEmpty,
      );
    });

    test('announcement bookkeeping suppresses repeats', () {
      expect(
        warningsAt(_at(8, 55), announcedCountdown: {'early'}),
        isEmpty,
      );
      expect(
        warningsAt(_at(9, 0), announcedCountdown: {'early'}),
        ['early:false:0', 'middle:true:5'],
        reason: 'a counted-down step still announces when it becomes due',
      );
      expect(
        warningsAt(_at(9, 0), announcedDue: {'early'}, announcedCountdown: {'middle'}),
        isEmpty,
      );
    });
  });

  group('routine editor flows', () {
    late _MapStore store;
    late LocalRoutineRepository repo;
    late AppState appState;

    setUp(() {
      store = _MapStore();
      repo = LocalRoutineRepository(store: store);
      appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        routineRepository: repo,
      );
    });

    tearDown(() {
      appState.dispose();
    });

    Future<void> pumpEditor(WidgetTester tester) async {
      await tester.pumpWidget(testApp(RoutineEditorScreen(appState: appState)));
      await tester.pumpAndSettle();
    }

    testWidgets('add a bilingual step through the dialog', (tester) async {
      tester.view.physicalSize = const Size(900, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpEditor(tester);
      await tester.tap(find.byKey(const ValueKey('add-step')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('step-title-en')),
        'Water plants',
      );
      await tester.enterText(
        find.byKey(const ValueKey('step-title-ur')),
        'پودوں کو پانی دو',
      );
      // Rebuild so the validity gate picks up both titles.
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('step-save')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Water plants'), findsOneWidget);
      final stored = await repo.getSteps();
      expect(stored.last.titleEn, 'Water plants');
      expect(stored.last.titleUr, 'پودوں کو پانی دو');
    });

    testWidgets('lead-time slider updates the app setting', (tester) async {
      expect(appState.transitionLeadMinutes, 5);
      await pumpEditor(tester);

      final sliderCenter = tester.getCenter(find.byKey(const ValueKey('lead-slider')));
      await tester.tap(find.byKey(const ValueKey('lead-slider')), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Tapping the middle of a 0..30 slider selects 15.
      expect(sliderCenter, isNotNull);
      expect(appState.transitionLeadMinutes, 15);
    });

    testWidgets('plan and clear a friendly change for today',
        (tester) async {
      tester.view.physicalSize = const Size(900, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpEditor(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'New label (English, optional)'),
        'Picnic breakfast',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'New label (Urdu, optional)'),
        'پکنک ناشتہ',
      );
      await tester.tap(find.byKey(const ValueKey('flex-apply')));
      await tester.pumpAndSettle();

      expect(find.text('A friendly change is planned for today.'),
          findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('flex-clear')));
      await tester.pumpAndSettle();
      expect(find.text('A friendly change is planned for today.'),
          findsNothing);
    });

    testWidgets('delete removes a step and its planned change',
        (tester) async {
      tester.view.physicalSize = const Size(900, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await repo.saveSteps([
        _step('breakfast', time: '08:00'),
        _step('lunch', time: '12:00'),
      ]);
      await repo.setFlexibilityChange(
        appState.selectedChild.id,
        DateTime.now(),
        const FlexibilityChange(
          stepId: 'breakfast',
          newTitleEn: 'Picnic',
          newTitleUr: 'پکنک',
        ),
      );
      await pumpEditor(tester);

      await tester.tap(find.byKey(const ValueKey('delete-step-breakfast')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      final stored = await repo.getSteps();
      expect(stored.map((s) => s.id), ['lunch']);
      expect(
        await repo.flexibilityChangeFor(appState.selectedChild.id, DateTime.now()),
        isNull,
      );
    });
  });

  group('child routine screen with module 4 features', () {
    late _MapStore store;
    late LocalRoutineRepository repo;
    late AppState appState;

    setUp(() {
      store = _MapStore();
      repo = LocalRoutineRepository(store: store);
      appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        routineRepository: repo,
      );
    });

    tearDown(() {
      appState.dispose();
    });

    DateTime fixedNow() => DateTime(2026, 8, 22, 10, 0);

    Future<void> pumpScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        testApp(
          RoutinesScreen(appState: appState, clock: fixedNow),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('countdown banner shows minutes left inside the lead window',
        (tester) async {
      appState.setTransitionLeadMinutes(5);
      await repo.saveSteps([
        _step('snack', time: '10:03', en: 'Snack time'),
        _step('dinner', time: '19:00', en: 'Dinner'),
      ]);
      await pumpScreen(tester);

      expect(find.byKey(const ValueKey('countdown-snack')), findsOneWidget);
      expect(find.textContaining('3 minutes left'), findsOneWidget);
      expect(find.byKey(const ValueKey('countdown-dinner')), findsNothing);
    });

    testWidgets('planned change badges the step and pays a bonus star',
        (tester) async {
      final starsBefore = appState.stars;
      await repo.saveSteps([_step('breakfast', time: '08:00')]);
      await repo.setFlexibilityChange(
        appState.selectedChild.id,
        DateTime(2026, 8, 22),
        const FlexibilityChange(
          stepId: 'breakfast',
          newTitleEn: 'Picnic breakfast',
          newTitleUr: 'پکنک ناشتہ',
        ),
      );
      await pumpScreen(tester);

      // The override label renders and the change carries a badge plus an
      // affirmation banner.
      expect(find.text('Picnic breakfast'), findsOneWidget);
      expect(find.byKey(const ValueKey('flex-banner')), findsOneWidget);
      expect(find.text('Planned change'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('routine-check-breakfast')));
      await tester.pumpAndSettle();

      expect(appState.stars, starsBefore + 1);
      expect(find.textContaining('Changes can be fun'), findsOneWidget);
    });

    testWidgets('edit action opens the parent gate then the editor',
        (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey('routine-edit')));
      await tester.pumpAndSettle();

      // No PIN configured: the gate passes straight through.
      expect(find.text('Routine editor'), findsOneWidget);
    });
  });
}
