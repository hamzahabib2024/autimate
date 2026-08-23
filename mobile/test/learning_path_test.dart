import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/learning/domain/interest_repository.dart';
import 'package:autimate/features/learning/domain/learning_models.dart';
import 'package:autimate/features/learning/presentation/learning_path_screen.dart';

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
  group('deterministic learning path builder', () {
    test('path order follows the catalog, not selection order', () {
      final a = buildLearningPath(['space', 'cars']);
      final b = buildLearningPath(['cars', 'space']);
      expect(
        a.map((entry) => entry.activity.id).toList(),
        b.map((entry) => entry.activity.id).toList(),
      );
      // Cars precede space in the catalog.
      expect(a.first.viaInterestId, 'cars');
    });

    test('shared topics do not duplicate activities', () {
      final path = buildLearningPath(['cars', 'trains']);
      final ids = path.map((entry) => entry.activity.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(ids.contains('wheels-count'), isTrue);
      expect(ids.contains('train-stations'), isTrue);
    });

    test('empty selection yields an empty path', () {
      expect(buildLearningPath(const []), isEmpty);
    });

    test('every catalog interest maps to at least one topic with content',
        () {
      for (final interest in interestCatalog) {
        final topics = interestTopicMap[interest.id]!;
        expect(topics, isNotEmpty);
        for (final topicId in topics) {
          expect(learningTopics[topicId], isNotNull);
          expect(topicActivities[topicId], isNotEmpty);
        }
      }
      // Every authored activity is bilingual and answerable.
      for (final activities in topicActivities.values) {
        for (final activity in activities) {
          expect(activity.questions, isNotEmpty);
          for (final question in activity.questions) {
            expect(question.correctIndex,
                lessThan(question.optionsEn.length));
            expect(question.optionsUr.length, question.optionsEn.length);
            expect(question.promptUr, isNotEmpty);
          }
        }
      }
    });
  });

  group('interest repository', () {
    late _MapStore store;
    late LocalInterestRepository repo;

    setUp(() {
      store = _MapStore();
      repo = LocalInterestRepository(store: store);
    });

    test('roundtrips per child and stays isolated between children',
        () async {
      expect(await repo.interestsFor('c1'), isEmpty);

      await repo.setInterests('c1', {'cars', 'space'});
      await repo.setInterests('c2', {'animals'});

      expect(await repo.interestsFor('c1'), {'cars', 'space'});
      expect(await repo.interestsFor('c2'), {'animals'});

      await repo.setInterests('c1', {});
      expect(await repo.interestsFor('c1'), isEmpty);
      expect(await repo.interestsFor('c2'), {'animals'});
    });
  });

  group('screens', () {
    late _MapStore store;
    late LocalInterestRepository repo;
    late AppState appState;

    setUp(() {
      store = _MapStore();
      repo = LocalInterestRepository(store: store);
      appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        interestRepository: repo,
      );
    });

    tearDown(() {
      appState.dispose();
    });

    testWidgets('editor toggles interests and persists them',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(testApp(InterestEditorScreen(appState: appState)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('pick-trains')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('pick-space')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('save-interests')));
      await tester.pumpAndSettle();

      expect(await repo.interestsFor(appState.selectedChild.id),
          {'trains', 'space'});
    });

    testWidgets('path lists mapped activities with explainable reasons',
        (tester) async {
      tester.view.physicalSize = const Size(900, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await repo.setInterests(appState.selectedChild.id, {'cars'});
      await tester.pumpWidget(testApp(LearningPathScreen(appState: appState)));
      await tester.pumpAndSettle();

      // Both things-that-go activities appear, ordered deterministically.
      expect(find.byKey(const ValueKey('path-wheels-count')), findsOneWidget);
      expect(find.byKey(const ValueKey('path-go-and-stop')), findsOneWidget);
      expect(find.textContaining('Ayaan likes Cars'), findsNWidgets(2));
    });

    testWidgets('empty interests show a hint instead of activities',
        (tester) async {
      await tester.pumpWidget(testApp(LearningPathScreen(appState: appState)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Pick a few interests'), findsOneWidget);
      expect(find.byKey(const ValueKey('path-wheels-count')), findsNothing);
    });

    testWidgets('activity quiz awards one star and blocks wrong answers',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final starsBefore = appState.stars;
      await repo.setInterests(appState.selectedChild.id, {'cars'});
      await tester.pumpWidget(testApp(LearningPathScreen(appState: appState)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('path-wheels-count')));
      await tester.pumpAndSettle();
      expect(find.text('Question 1 of 2'), findsOneWidget);

      // Wrong answer keeps the question and shows gentle feedback.
      await tester.tap(find.byKey(const ValueKey('answer-2')));
      await tester.pumpAndSettle();
      expect(find.text('Let us try the next one.'), findsOneWidget);
      expect(find.text('Question 1 of 2'), findsOneWidget);
      expect(appState.stars, starsBefore);

      // Correct answers finish both questions and pay one star.
      await tester.tap(find.byKey(const ValueKey('answer-0')));
      await tester.pumpAndSettle();
      expect(find.text('Question 2 of 2'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('answer-1')));
      await tester.pumpAndSettle();

      expect(find.text('Session complete'), findsOneWidget);
      expect(appState.stars, starsBefore + 1);
    });

    testWidgets('edit action passes through the gate into the editor',
        (tester) async {
      await tester.pumpWidget(testApp(LearningPathScreen(appState: appState)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('learning-edit')));
      await tester.pumpAndSettle();

      // No PIN configured: the gate auto-passes.
      expect(find.text('Interests'), findsOneWidget);
    });
  });
}
