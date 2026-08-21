import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/features/routines/domain/routine_models.dart';
import 'package:autimate/features/routines/domain/routine_repository.dart';

void main() {
  late InMemoryKeyValueStore store;
  late LocalRoutineRepository repository;

  setUp(() {
    store = InMemoryKeyValueStore();
    repository = LocalRoutineRepository(store: store);
  });

  group('LocalRoutineRepository', () {
    test('seeds the default routine when nothing is stored', () async {
      final steps = await repository.getSteps();
      expect(steps.map((step) => step.id), [
        'breakfast',
        'get_dressed',
        'school_time',
      ]);
    });

    test('completion is tracked per day and per child', () async {
      final today = DateTime(2026, 8, 21);
      final tomorrow = DateTime(2026, 8, 22);

      await repository.setStepCompleted(
        'demo-child',
        today,
        'breakfast',
        true,
      );

      expect(
        await repository.completedStepIdsFor('demo-child', today),
        {'breakfast'},
      );
      expect(
        await repository.completedStepIdsFor('demo-child', tomorrow),
        isEmpty,
      );
      expect(
        await repository.completedStepIdsFor('other-child', today),
        isEmpty,
      );
    });

    test('uncompleting removes the step from the day', () async {
      final today = DateTime(2026, 8, 21);
      await repository.setStepCompleted(
        'demo-child',
        today,
        'breakfast',
        true,
      );
      await repository.setStepCompleted(
        'demo-child',
        today,
        'breakfast',
        false,
      );
      expect(
        await repository.completedStepIdsFor('demo-child', today),
        isEmpty,
      );
    });
  });

  group('RoutineReminderEngine', () {
    const engine = RoutineReminderEngine();
    const steps = defaultRoutineSteps;

    test('announces steps whose time has arrived and are not done', () async {
      final due = engine.dueStepIds(
        steps: steps,
        completedIds: const {},
        announcedIds: const {},
        now: DateTime(2026, 8, 21, 8, 30),
      );
      expect(due, ['breakfast', 'get_dressed']);
    });

    test('never re-announces a completed or already-announced step', () async {
      final due = engine.dueStepIds(
        steps: steps,
        completedIds: const {'breakfast'},
        announcedIds: const {'get_dressed'},
        now: DateTime(2026, 8, 21, 9, 0),
      );
      expect(due, ['school_time']);
    });

    test('stays silent before any scheduled time', () async {
      final due = engine.dueStepIds(
        steps: steps,
        completedIds: const {},
        announcedIds: const {},
        now: DateTime(2026, 8, 21, 7, 59),
      );
      expect(due, isEmpty);
    });
  });
}
