import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/features/communication/domain/card_ranker.dart';
import 'package:autimate/features/communication/domain/sentence_realiser.dart';
import 'package:autimate/features/emotion_recognition/domain/adaptive_level_controller.dart';
import 'package:autimate/features/emotion_recognition/domain/emotion_activity_engine.dart';

void main() {
  group('RuleBasedSentenceRealiser', () {
    final realiser = RuleBasedSentenceRealiser();
    const speaker = SpeakerProfile(gender: UrduGender.masculine);
    const feminine = SpeakerProfile(gender: UrduGender.feminine);
    const want = CardGrammar(
      id: 'i_want',
      labelEn: 'I want',
      labelUr: 'چاہتا ہوں',
      pos: PartOfSpeech.carrier,
      isCountable: false,
      startsWithVowelSound: false,
      urduGender: UrduGender.masculine,
      urduSubject: 'میں',
      urduVerbMasculine: 'چاہتا ہوں',
      urduVerbFeminine: 'چاہتی ہوں',
    );
    const feel = CardGrammar(
      id: 'i_feel',
      labelEn: 'I feel',
      labelUr: 'ہوں',
      pos: PartOfSpeech.carrier,
      isCountable: false,
      startsWithVowelSound: false,
      urduGender: UrduGender.masculine,
      urduSubject: 'میں',
      urduVerbMasculine: 'ہوں',
      urduVerbFeminine: 'ہوں',
    );
    const apple = CardGrammar(
      id: 'apple',
      labelEn: 'apple',
      labelUr: 'سیب',
      pos: PartOfSpeech.noun,
      isCountable: true,
      startsWithVowelSound: true,
      urduGender: UrduGender.masculine,
    );
    const water = CardGrammar(
      id: 'water',
      labelEn: 'water',
      labelUr: 'پانی',
      pos: PartOfSpeech.noun,
      isCountable: false,
      startsWithVowelSound: false,
      urduGender: UrduGender.masculine,
    );
    const happy = CardGrammar(
      id: 'happy',
      labelEn: 'happy',
      labelUr: 'خوش',
      pos: PartOfSpeech.adjective,
      isCountable: false,
      startsWithVowelSound: false,
      urduGender: UrduGender.masculine,
    );

    test('handles empty and single-card strips', () {
      expect(realiser.realise([], speaker, AppLanguage.en).text, '');
      expect(realiser.realise([apple], speaker, AppLanguage.en).text, 'Apple.');
      expect(realiser.realise([apple], speaker, AppLanguage.ur).text, 'سیب.');
    });

    test('uses English article rules', () {
      expect(
        realiser.realise([want, apple], speaker, AppLanguage.en).text,
        'I want an apple.',
      );
      expect(
        realiser.realise([want, water], speaker, AppLanguage.en).text,
        'I want some water.',
      );
    });

    test('renders Urdu in SOV order with gender agreement', () {
      expect(
        realiser.realise([want, apple], speaker, AppLanguage.ur).text,
        'میں سیب چاہتا ہوں.',
      );
      expect(
        realiser.realise([want, apple], feminine, AppLanguage.ur).text,
        'میں سیب چاہتی ہوں.',
      );
    });

    test('renders adjective predicates', () {
      expect(
        realiser.realise([feel, happy], speaker, AppLanguage.en).text,
        'I feel happy.',
      );
      expect(
        realiser.realise([feel, happy], speaker, AppLanguage.ur).text,
        'میں خوش ہوں.',
      );
    });
  });

  group('RecencyWeightedCardRanker', () {
    final ranker = RecencyWeightedCardRanker();
    final now = DateTime(2026, 8, 21);

    test('ranks repeated recent use and limits to eight', () {
      final history = [
        for (var index = 0; index < 5; index++)
          CardUsageEvent(cardId: 'water', usedAt: now),
        CardUsageEvent(
          cardId: 'apple',
          usedAt: now.subtract(const Duration(days: 1)),
        ),
        ...List.generate(
          10,
          (index) => CardUsageEvent(cardId: 'card-$index', usedAt: now),
        ),
      ];
      final result = ranker.rank(history);
      expect(result, contains('water'));
      expect(result.length, 8);
      expect(ranker.rank(const []), isEmpty);
    });

    test('decays old usage and remains deterministic for ties', () {
      final history = [
        CardUsageEvent(
          cardId: 'old',
          usedAt: now.subtract(const Duration(days: 14)),
        ),
        CardUsageEvent(cardId: 'new', usedAt: now),
      ];
      expect(ranker.rank(history), ['new', 'old']);
      expect(
        ranker.rank([
          CardUsageEvent(cardId: 'b', usedAt: now),
          CardUsageEvent(cardId: 'a', usedAt: now),
        ]),
        ['a', 'b'],
      );
    });
  });

  group('EmotionActivityEngine', () {
    test('generates level-specific choices and a session result', () {
      final engine = DeterministicEmotionActivityEngine(childId: 'child');
      var question = engine.start(
        level: SupportLevel.advanced,
        questionCount: 5,
      );
      expect(question.choices.length, 4);
      expect(question.choices, contains(question.answer));
      for (var index = 0; index < 5; index++) {
        engine.submit(question.answer);
        if (index < 4) {
          final next = engine.next();
          expect(next, isNotNull);
          question = next!;
        }
      }
      final result = engine.finish();
      expect(result.score, 5);
      expect(result.starsAwarded, 3);
      expect(result.levelAfter, SupportLevel.advanced);
    });

    test('uses two choices and hints for beginners', () {
      final engine = DeterministicEmotionActivityEngine(childId: 'child');
      final question = engine.start(
        level: SupportLevel.beginner,
        questionCount: 1,
      );
      expect(question.choices.length, 2);
      expect(question.hintVisible, isTrue);
    });

    test('session result honors parent lock and override', () {
      final locked = DeterministicEmotionActivityEngine(
        childId: 'child',
        parentLocked: true,
      );
      var question = locked.start(
        level: SupportLevel.beginner,
        questionCount: 3,
      );
      for (var index = 0; index < 3; index++) {
        locked.submit(question.answer);
        if (index < 2) question = locked.next()!;
      }
      expect(locked.finish().levelAfter, SupportLevel.beginner);

      final overridden = DeterministicEmotionActivityEngine(
        childId: 'child',
        parentOverride: SupportLevel.advanced,
      );
      question = overridden.start(
        level: SupportLevel.beginner,
        questionCount: 1,
      );
      overridden.submit(question.answer);
      expect(overridden.finish().levelAfter, SupportLevel.advanced);
    });
  });

  group('RuleBasedAdaptiveLevelController', () {
    final controller = RuleBasedAdaptiveLevelController();

    test('promotes after three correct and demotes after two wrong', () {
      expect(
        controller.evaluate(
          current: SupportLevel.beginner,
          recentOutcomes: [true, true, true],
          parentLocked: false,
        ),
        SupportLevel.intermediate,
      );
      expect(
        controller.evaluate(
          current: SupportLevel.advanced,
          recentOutcomes: [false, false],
          parentLocked: false,
        ),
        SupportLevel.intermediate,
      );
    });

    test('respects boundaries, lock, and override', () {
      expect(
        controller.evaluate(
          current: SupportLevel.beginner,
          recentOutcomes: [false, false],
          parentLocked: false,
        ),
        SupportLevel.beginner,
      );
      expect(
        controller.evaluate(
          current: SupportLevel.advanced,
          recentOutcomes: [true, true, true],
          parentLocked: false,
        ),
        SupportLevel.advanced,
      );
      expect(
        controller.evaluate(
          current: SupportLevel.beginner,
          recentOutcomes: [true, true, true],
          parentLocked: true,
        ),
        SupportLevel.beginner,
      );
      expect(
        controller.evaluate(
          current: SupportLevel.beginner,
          recentOutcomes: [],
          parentLocked: false,
          parentOverride: SupportLevel.advanced,
        ),
        SupportLevel.advanced,
      );
    });
  });
}
