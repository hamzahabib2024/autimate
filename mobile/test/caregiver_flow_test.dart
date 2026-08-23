import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/local_progress_repository.dart';
import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/emotion_recognition/domain/emotion_activity_engine.dart';
import 'package:autimate/features/parent_dashboard/presentation/dashboard_screen.dart';
import 'package:autimate/features/routines/domain/routine_repository.dart';
import 'package:autimate/features/routines/presentation/routines_screen.dart';

import 'helpers/test_app.dart';

void main() {
  late InMemoryKeyValueStore store;
  late AppState appState;

  setUp(() {
    store = InMemoryKeyValueStore();
    appState = AppState(
      MockAuthRepository(),
      MockTtsService(),
      progressRepository: LocalProgressRepository(store: store),
      routineRepository: LocalRoutineRepository(store: store),
    );
  });

  testWidgets('routine completion persists through the repository', (
    tester,
  ) async {
    await tester.pumpWidget(testApp(RoutinesScreen(appState: appState)));
    await tester.pumpAndSettle();

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('0 of 3 steps done'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.text('1 of 3 steps done'), findsOneWidget);

    final completed = await appState.routineRepository.completedStepIdsFor(
      'demo-child',
      DateTime.now(),
    );
    expect(completed, {'breakfast'});
  });

  testWidgets('dashboard reflects recorded activities instead of dummy data', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await appState.progressRepository.recordSession(
      SessionResult(
        childId: 'demo-child',
        activityType: 'emotion_identification',
        score: 4,
        total: 5,
        levelPlayed: SupportLevel.beginner,
        levelAfter: SupportLevel.beginner,
        duration: const Duration(minutes: 3),
        completedAt: DateTime.now(),
        starsAwarded: 2,
      ),
    );

    await tester.pumpWidget(testApp(DashboardScreen(appState: appState)));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('No observations logged yet.'), findsOneWidget);
  });

  testWidgets('caregiver can log an observation from the dashboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(testApp(DashboardScreen(appState: appState)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Observation'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Calm during breakfast');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Calm during breakfast'), findsOneWidget);
    final notes = await appState.progressRepository.getObservations(
      'demo-child',
    );
    expect(notes.single.note, 'Calm during breakfast');
  });
}
