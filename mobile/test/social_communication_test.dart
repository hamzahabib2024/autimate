import 'package:autimate/features/social_communication/domain/conversation_engine.dart';
import 'package:autimate/features/social_communication/domain/social_content.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/social_communication/presentation/social_stories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('content library integrity', () {
    test('stories are bilingual, complete, and answerable', () {
      expect(socialStories.length, 4);
      final ids = socialStories.map((s) => s.id).toSet();
      expect(ids.length, 4);

      for (final story in socialStories) {
        expect(story.titleEn, isNotEmpty);
        expect(story.titleUr, isNotEmpty);
        expect(story.pages.length, greaterThanOrEqualTo(3));
        expect(story.questions, isNotEmpty);
        for (final page in story.pages) {
          expect(page.textEn, isNotEmpty);
          expect(page.textUr, isNotEmpty);
        }
        for (final question in story.questions) {
          expect(
            question.correctIndex,
            lessThan(question.optionsEn.length),
          );
          expect(
            question.optionsUr.length,
            question.optionsEn.length,
          );
        }
      }
    });

    test('every conversation branch resolves to a step or the end', () {
      expect(conversationScripts.length, 4);
      for (final script in conversationScripts) {
        expect(script.stepById(script.startStepId), isNotNull,
            reason: '${script.id} start step missing');
        for (final step in script.steps) {
          for (final option in step.options) {
            if (option.nextStepId != 'end') {
              expect(
                script.stepById(option.nextStepId),
                isNotNull,
                reason:
                    '${script.id}/${step.id} dangling branch ${option.nextStepId}',
              );
            }
          }
        }
      }
    });
  });

  group('ConversationEngine', () {
    test('fitting replies advance to completion', () {
      final script =
          conversationScripts.firstWhere((s) => s.id == 'greetings');
      final engine = ConversationEngine(script: script)..reset();
      expect(engine.completed, isFalse);

      var outcome = engine.choose(script.stepById('g1')!.options.first);
      expect(outcome.advanced, isTrue);
      expect(outcome.completed, isFalse);

      outcome = engine.choose(script.stepById('g2')!.options.first);
      expect(outcome.completed, isTrue);
      expect(engine.completed, isTrue);
    });

    test('unexpected replies stay on the same step and stay gentle', () {
      final script =
          conversationScripts.firstWhere((s) => s.id == 'greetings');
      final engine = ConversationEngine(script: script)..reset();
      final stepOne = script.stepById('g1')!;
      final disengaged = stepOne.options.last;
      expect(disengaged.encouraging, isFalse);

      engine.choose(disengaged);
      expect(engine.completed, isFalse);
      expect(engine.current!.id, 'g1');
      expect(engine.triesOnCurrentStep, 1);

      engine.choose(stepOne.options.first);
      expect(engine.current!.id, 'g2');
      expect(engine.triesOnCurrentStep, 0);
    });

    test('reset restores the start state', () {
      final script =
          conversationScripts.firstWhere((s) => s.id == 'requesting');
      final engine = ConversationEngine(script: script)..reset();
      engine.choose(script.stepById('r1')!.options.first);
      expect(engine.current!.id, 'r2');

      engine.reset();
      expect(engine.current!.id, 'r1');
      expect(engine.triesOnCurrentStep, 0);
    });
  });

  group('story reader flow', () {
    late AppState appState;

    setUp(() {
      appState = AppState(MockAuthRepository(), MockTtsService());
    });

    tearDown(() {
      appState.dispose();
    });

    Future<void> openFirstStory(WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        testApp(SocialStoriesScreen(appState: appState)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('story-meeting-someone')));
      await tester.pumpAndSettle();
    }

    testWidgets('pages narrate, then comprehension awards a star',
        (tester) async {
      final starsBefore = appState.stars;
      await openFirstStory(tester);

      // Page one of "Meeting Someone New" is visible.
      expect(find.textContaining('meet new people'), findsOneWidget);

      // Walk all four pages.
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.byKey(const ValueKey('reader-next')));
        await tester.pumpAndSettle();
      }

      // First comprehension question.
      expect(find.byKey(const ValueKey('quiz-page')), findsOneWidget);

      // The child can step back to re-read the last page.
      await tester.tap(find.byKey(const ValueKey('quiz-back')));
      await tester.pumpAndSettle();
      expect(find.textContaining('calm and safe'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('reader-next')));
      await tester.pumpAndSettle();

      // Back at the first question.
      expect(find.byKey(const ValueKey('quiz-page')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('quiz-option-0')));
      await tester.pumpAndSettle();

      // A correct answer advances; no stale praise lingers on question 2.
      expect(
        find.textContaining('Is it okay to take time'),
        findsOneWidget,
      );
      expect(find.text('That is right.'), findsNothing);

      // Second question completes the session and awards a star.
      await tester.tap(find.byKey(const ValueKey('quiz-option-0')));
      await tester.pumpAndSettle();
      expect(find.text('Session complete'), findsOneWidget);
      expect(appState.stars, starsBefore + 1);
    });

    testWidgets('a wrong comprehension answer asks to try again',
        (tester) async {
      await openFirstStory(tester);
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.byKey(const ValueKey('reader-next')));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.byKey(const ValueKey('quiz-option-1')));
      await tester.pumpAndSettle();
      expect(find.text('Let us try the next one.'), findsOneWidget);
      // Still on the same question.
      expect(find.byKey(const ValueKey('quiz-option-1')), findsOneWidget);
      expect(find.text('Session complete'), findsNothing);
    });
  });

  group('conversation practice flow', () {
    late AppState appState;

    setUp(() {
      appState = AppState(MockAuthRepository(), MockTtsService());
    });

    tearDown(() {
      appState.dispose();
    });

    Future<void> openScript(WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        testApp(SocialStoriesScreen(appState: appState)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('tab-conversations')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('script-greetings')));
      await tester.pumpAndSettle();
    }

    testWidgets('gentle retry then fitting replies complete the script',
        (tester) async {
      final starsBefore = appState.stars;
      await openScript(tester);

      expect(find.byKey(const ValueKey('conversation-run')), findsOneWidget);
      expect(find.textContaining('How are you?'), findsOneWidget);

      // Safe-but-unexpected reply: stays on step g1 with gentle feedback.
      await tester.tap(find.byKey(const ValueKey('reply-1')));
      await tester.pumpAndSettle();
      expect(find.text("That is okay. Let's try another way."), findsOneWidget);
      expect(find.textContaining('How are you?'), findsOneWidget);
      expect(appState.stars, starsBefore);

      // Fitting reply advances to g2.
      await tester.tap(find.byKey(const ValueKey('reply-0')));
      await tester.pumpAndSettle();
      expect(find.textContaining('my drawing'), findsOneWidget);

      // Any reply here ends the script and awards a star.
      await tester.tap(find.byKey(const ValueKey('reply-1')));
      await tester.pumpAndSettle();
      expect(find.textContaining('finished the conversation'),
          findsOneWidget);
      expect(appState.stars, starsBefore + 1);

      // Practise again resets cleanly.
      await tester.tap(find.text('Practise again'));
      await tester.pumpAndSettle();
      expect(find.textContaining('How are you?'), findsOneWidget);
    });
  });
}
