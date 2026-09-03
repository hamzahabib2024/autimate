import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/communication/data/board_printer.dart';
import 'package:autimate/features/communication/data/quick_phrase_widget_service.dart';
import 'package:autimate/features/communication/domain/aac_catalog.dart';
import 'package:autimate/features/communication/domain/card_ranker.dart';
import 'package:autimate/features/communication/domain/phrase_bank.dart';
import 'package:autimate/features/communication/domain/sentence_realiser.dart';
import 'package:autimate/features/communication/domain/symbol_scale.dart';
import 'package:autimate/features/communication/domain/word_prediction.dart';
import 'package:autimate/features/emotion_recognition/domain/emotion_activity_engine.dart';
import 'package:autimate/features/emotion_recognition/domain/emotion_intensity.dart';
import 'package:autimate/features/emotion_recognition/presentation/intensity_screen.dart';
import 'package:autimate/features/parent_dashboard/domain/achievements_timeline.dart';
import 'package:autimate/features/progress/domain/progress_models.dart';
import 'package:autimate/features/sensory_support/domain/breathing_pattern.dart';

import 'helpers/test_app.dart';

CardGrammar _grammar(String id) => cardById(id)!.grammar;

ProgressRecord _record(DateTime at, {String type = 'emotion'}) =>
    ProgressRecord(
      result: SessionResult(
        childId: 'demo-child',
        activityType: type,
        score: 4,
        total: 5,
        levelPlayed: SupportLevel.beginner,
        levelAfter: SupportLevel.beginner,
        duration: const Duration(seconds: 30),
        completedAt: at,
        starsAwarded: 1,
      ),
      recordedAt: at,
    );

/// Brings a lazily-built widget into view on a long screen.
Future<void> _reveal(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  for (var attempt = 0; attempt < 12; attempt++) {
    if (finder.evaluate().isNotEmpty) {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      return;
    }
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
  }
  fail('$key never came into view');
}

void main() {
  // =========================================================================
  // Word prediction
  // =========================================================================
  group('word prediction', () {
    const predictor = WordPredictor();

    test('an empty strip is offered the openers', () {
      final suggestions = predictor.suggest(
        strip: const [],
        deck: aacDeck,
        history: const [],
      );
      expect(suggestions, isNotEmpty);
      // The deck holds only two carriers, and the row is filled out rather
      // than left short — an empty suggestion row is worse than an
      // imperfect one. So only the leading entries are guaranteed openers.
      expect(
        suggestions.first.grammar.pos,
        anyOf(PartOfSpeech.carrier, PartOfSpeech.pronoun),
        reason: 'a sentence starts with a carrier, not a noun',
      );
      final carriers = suggestions.where(
        (card) =>
            card.grammar.pos == PartOfSpeech.carrier ||
            card.grammar.pos == PartOfSpeech.pronoun,
      );
      expect(carriers.length, greaterThanOrEqualTo(2));
    });

    test('after a want-carrier it offers nouns', () {
      final suggestions = predictor.suggest(
        strip: [_grammar('i_want')],
        deck: aacDeck,
        history: const [],
      );
      expect(suggestions, isNotEmpty);
      expect(suggestions.first.grammar.pos, PartOfSpeech.noun);
    });

    test('after a feel-carrier it offers descriptors', () {
      final suggestions = predictor.suggest(
        strip: [_grammar('i_feel')],
        deck: aacDeck,
        history: const [],
      );
      expect(suggestions.first.grammar.pos, PartOfSpeech.adjective);
    });

    test('never suggests a word already in the strip', () {
      final suggestions = predictor.suggest(
        strip: [_grammar('i_want'), _grammar('apple')],
        deck: aacDeck,
        history: const [],
      );
      expect(suggestions.map((card) => card.id), isNot(contains('apple')));
      expect(suggestions.map((card) => card.id), isNot(contains('i_want')));
    });

    test('grammar outranks frequency', () {
      // "milk" is hammered in the history, but after "I feel" a descriptor
      // still wins — offering "I feel milk" would teach the wrong thing.
      final history = [
        for (var i = 0; i < 50; i++)
          CardUsageEvent(cardId: 'milk', usedAt: DateTime(2026, 3, 1)),
      ];
      final suggestions = predictor.suggest(
        strip: [_grammar('i_feel')],
        deck: aacDeck,
        history: history,
      );
      expect(suggestions.first.grammar.pos, PartOfSpeech.adjective);
    });

    test('frequency breaks ties within a grammatical class', () {
      final history = [
        for (var i = 0; i < 20; i++)
          CardUsageEvent(cardId: 'rice', usedAt: DateTime(2026, 3, 1)),
      ];
      final suggestions = predictor.suggest(
        strip: [_grammar('i_want')],
        deck: aacDeck,
        history: history,
      );
      expect(suggestions.first.id, 'rice');
    });

    test('the suggestion row stays short', () {
      final suggestions = predictor.suggest(
        strip: const [],
        deck: aacDeck,
        history: const [],
      );
      expect(suggestions.length, lessThanOrEqualTo(4),
          reason: 'a long suggestion row is a second board to scan');
    });

    test('every suggestion can be explained in plain language', () {
      for (final card in predictor.suggest(
        strip: [_grammar('i_want')],
        deck: aacDeck,
        history: const [],
      )) {
        expect(predictor.explain([_grammar('i_want')], card), isNotEmpty);
      }
    });

    test('an exhausted deck yields nothing rather than throwing', () {
      final all = [for (final card in aacDeck) card.grammar];
      expect(
        predictor.suggest(strip: all, deck: aacDeck, history: const []),
        isEmpty,
      );
    });

    test('prediction is off by default', () {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      expect(appState.wordPredictionEnabled, isFalse,
          reason: 'it distracts a symbol-only user, the primary audience');
    });
  });

  // =========================================================================
  // Phrase bank
  // =========================================================================
  group('phrase bank', () {
    SavedPhrase phrase(String id, {bool urgent = false}) => SavedPhrase(
      id: id,
      childId: 'demo-child',
      cardIds: const ['i_want', 'apple'],
      labelEn: 'I want an apple.',
      labelUr: 'مجھے سیب چاہیے۔',
      urgent: urgent,
    );

    test('a phrase keeps its component cards, not only its text', () {
      // This is what keeps it a shortcut rather than a substitute for
      // building the sentence.
      expect(phrase('p1').cardIds, ['i_want', 'apple']);
    });

    test('speaking straight away is off by default', () {
      expect(phrase('p1').speakImmediately, isFalse);
    });

    test('urgent phrases sort first', () async {
      final repo = InMemoryPhraseBankRepository();
      await repo.save(phrase('calm'));
      await repo.save(phrase('urgent', urgent: true));
      final phrases = await repo.phrasesFor('demo-child');
      expect(phrases.first.id, 'urgent');
    });

    test('the bank is capped so it cannot become a second board', () async {
      final repo = InMemoryPhraseBankRepository();
      for (var i = 0; i < 30; i++) {
        await repo.save(phrase('p$i'));
      }
      expect(
        await repo.phrasesFor('demo-child'),
        hasLength(LocalPhraseBankRepository.maxPerChild),
      );
    });

    test('phrases belong to one child', () async {
      final repo = InMemoryPhraseBankRepository();
      await repo.save(phrase('p1'));
      expect(await repo.phrasesFor('other-child'), isEmpty);
    });

    test('durable storage round-trips', () async {
      final store = InMemoryKeyValueStore();
      await LocalPhraseBankRepository(store).save(phrase('p1', urgent: true));
      final reloaded =
          await LocalPhraseBankRepository(store).phrasesFor('demo-child');
      expect(reloaded.single.labelEn, 'I want an apple.');
      expect(reloaded.single.urgent, isTrue);
      expect(reloaded.single.cardIds, ['i_want', 'apple']);
    });

    test('saving an existing id edits rather than duplicating', () async {
      final repo = InMemoryPhraseBankRepository();
      await repo.save(phrase('p1'));
      await repo.save(phrase('p1', urgent: true));
      final phrases = await repo.phrasesFor('demo-child');
      expect(phrases, hasLength(1));
      expect(phrases.single.urgent, isTrue);
    });
  });

  // =========================================================================
  // Home-screen widget (Dart side only — native is unverified)
  // =========================================================================
  group('quick-phrase widget', () {
    const service = QuickPhraseWidgetService();

    SavedPhrase phrase(String id, {bool urgent = false}) => SavedPhrase(
      id: id,
      childId: 'demo-child',
      cardIds: const ['help'],
      labelEn: 'Help',
      labelUr: 'مدد',
      urgent: urgent,
    );

    test('urgent phrases are chosen first', () {
      final selected = service.select([
        phrase('a'),
        phrase('b', urgent: true),
        phrase('c'),
        phrase('d', urgent: true),
      ]);
      expect(selected.take(2).every((p) => p.urgent), isTrue);
    });

    test('the widget stays small', () {
      final many = [for (var i = 0; i < 20; i++) phrase('p$i')];
      expect(service.select(many).length, service.maxPhrases);
      expect(service.maxPhrases, lessThanOrEqualTo(4),
          reason: 'more buttons than this is slower than opening the app');
    });

    test('a launch URI is parsed, not trusted', () {
      expect(
        service.phraseIdFromLaunch(Uri.parse('autimate://phrase?id=p1')),
        'p1',
      );
      expect(
        service.phraseIdFromLaunch(Uri.parse('https://evil.test/phrase?id=p1')),
        isNull,
      );
      expect(
        service.phraseIdFromLaunch(Uri.parse('autimate://other?id=p1')),
        isNull,
      );
      expect(service.phraseIdFromLaunch(null), isNull);
      expect(
        service.phraseIdFromLaunch(Uri.parse('autimate://phrase')),
        isNull,
      );
    });

    test('the inert implementation publishes nothing', () async {
      const inert = UnavailableQuickPhraseWidgetService();
      expect(inert.isSupported, isFalse);
      expect(
        await inert.publish(const [], language: AppLanguage.en),
        isFalse,
      );
    });
  });

  // =========================================================================
  // Grid shapes
  // =========================================================================
  group('grid shapes', () {
    test('capacity matches the shape', () {
      expect(GridShape.twoByTwo.capacity, 4);
      expect(GridShape.threeByThree.capacity, 9);
      expect(GridShape.sixByEight.capacity, 48);
      expect(GridShape.flowing.isFixed, isFalse);
    });

    test('denser grids get shorter tiles', () {
      expect(
        GridShape.sixByEight.childAspectRatio,
        lessThan(GridShape.twoByTwo.childAspectRatio),
      );
    });

    test('the shape survives a restart', () async {
      final store = InMemoryKeyValueStore();
      final first = AppState(
        MockAuthRepository(),
        MockTtsService(),
        settingsStore: store,
      );
      first.setGridShape(GridShape.threeByThree);
      await first.persistSettings();

      final restarted = AppState(
        MockAuthRepository(),
        MockTtsService(),
        settingsStore: store,
      );
      await restarted.loadPersistedSettings();
      expect(restarted.gridShape, GridShape.threeByThree);
    });

    test('flowing is the default, so nothing changes unasked', () {
      expect(
        AppState(MockAuthRepository(), MockTtsService()).gridShape,
        GridShape.flowing,
      );
    });
  });

  // =========================================================================
  // Printable board
  // =========================================================================
  group('printable board', () {
    const printer = BoardPrinter();

    test('word classes match the on-screen coding', () {
      // A printed board whose colours disagreed with the screen would be
      // worse than no printed board.
      expect(BoardPrinter.wordClassOf(cardById('i_want')!), 'carrier');
      expect(BoardPrinter.wordClassOf(cardById('apple')!), 'noun');
      expect(BoardPrinter.wordClassOf(cardById('mama')!), 'people');
      expect(BoardPrinter.wordClassOf(cardById('play')!), 'verb');
      expect(BoardPrinter.wordClassOf(cardById('happy')!), 'descriptor');
    });

    test('builds a non-empty PDF', () async {
      final bytes = await printer.build(
        deck: aacDeck.take(12).toList(),
        customCards: const {},
        language: AppLanguage.en,
        shape: GridShape.fourByThree,
        childName: 'Ayaan',
      );
      expect(bytes.length, greaterThan(1000));
      // %PDF- magic.
      expect(bytes.take(5).toList(), [0x25, 0x50, 0x44, 0x46, 0x2D]);
    });

    test('an empty deck still produces a valid document', () async {
      final bytes = await printer.build(
        deck: const [],
        customCards: const {},
        language: AppLanguage.en,
      );
      expect(bytes.take(5).toList(), [0x25, 0x50, 0x44, 0x46, 0x2D]);
    });
  });

  // =========================================================================
  // Breathing patterns
  // =========================================================================
  group('breathing patterns', () {
    test('every pattern has a positive cycle', () {
      for (final pattern in BreathingPattern.all) {
        expect(pattern.cycle.inMilliseconds, greaterThan(0));
      }
    });

    test('the calming patterns favour the exhale', () {
      // A longer out-breath than in-breath is the part that actually calms.
      expect(BreathingPattern.gentle.favoursExhale, isTrue);
      expect(BreathingPattern.fourSevenEight.favoursExhale, isTrue);
      expect(BreathingPattern.box.favoursExhale, isFalse,
          reason: 'box is equal-sided by definition');
    });

    test('phases run in order across a cycle', () {
      const pattern = BreathingPattern.box;
      expect(pattern.phaseAt(const Duration(seconds: 1)).id, 'inhale');
      expect(pattern.phaseAt(const Duration(seconds: 5)).id, 'holdIn');
      expect(pattern.phaseAt(const Duration(seconds: 9)).id, 'exhale');
      expect(pattern.phaseAt(const Duration(seconds: 13)).id, 'holdOut');
    });

    test('the cycle repeats', () {
      const pattern = BreathingPattern.box;
      expect(
        pattern.phaseAt(const Duration(seconds: 17)).id,
        pattern.phaseAt(const Duration(seconds: 1)).id,
      );
    });

    test('a hold keeps the circle still', () {
      const pattern = BreathingPattern.box;
      final early = pattern.phaseAt(const Duration(seconds: 5));
      final late = pattern.phaseAt(const Duration(seconds: 7));
      expect(early.isHold, isTrue);
      expect(early.openness, late.openness,
          reason: 'a circle drifting during a hold teaches the wrong timing');
    });

    test('openness runs 0 to 1 and back', () {
      const pattern = BreathingPattern.box;
      expect(pattern.phaseAt(Duration.zero).openness, closeTo(0, 0.01));
      expect(
        pattern.phaseAt(const Duration(seconds: 4)).openness,
        closeTo(1, 0.01),
      );
      expect(
        pattern.phaseAt(const Duration(seconds: 15, milliseconds: 900))
            .openness,
        closeTo(0, 0.05),
      );
    });

    test('scaling slows the pattern but keeps its ratios', () {
      final slow = BreathingPattern.gentle.scaled(2);
      expect(slow.cycle, BreathingPattern.gentle.cycle * 2);
      expect(
        slow.exhale.inMilliseconds / slow.inhale.inMilliseconds,
        closeTo(
          BreathingPattern.gentle.exhale.inMilliseconds /
              BreathingPattern.gentle.inhale.inMilliseconds,
          0.001,
        ),
        reason: 'the ratio is what the pattern is',
      );
    });

    test('an unknown id falls back rather than throwing', () {
      expect(BreathingPattern.byId('nonsense').id, BreathingPattern.gentle.id);
    });

    test('the choice survives a restart', () async {
      final store = InMemoryKeyValueStore();
      final first = AppState(
        MockAuthRepository(),
        MockTtsService(),
        settingsStore: store,
      );
      first.setBreathingPattern(BreathingPattern.box);
      await first.persistSettings();

      final restarted = AppState(
        MockAuthRepository(),
        MockTtsService(),
        settingsStore: store,
      );
      await restarted.loadPersistedSettings();
      expect(restarted.breathingPattern.id, 'box');
    });
  });

  // =========================================================================
  // Emotion intensity
  // =========================================================================
  group('emotion intensity', () {
    test('the scale runs 1 to 5 in order', () {
      final values =
          IntensityLevel.values.map((level) => level.value).toList();
      expect(values, [1, 2, 3, 4, 5]);
    });

    test('only the top two levels offer support', () {
      // Offering a breathing exercise for "a little happy" would be absurd,
      // and offering one for everything teaches that all feelings are
      // problems to be managed.
      expect(IntensityLevel.aLittle.suggestsSupport, isFalse);
      expect(IntensityLevel.quite.suggestsSupport, isFalse);
      expect(IntensityLevel.very.suggestsSupport, isTrue);
      expect(IntensityLevel.tooMuch.suggestsSupport, isTrue);
    });

    test('a strong pleasant feeling is not regulated down', () {
      final report = IntensityReport(
        emotion: EmotionLabel.happy,
        level: IntensityLevel.tooMuch,
        reportedAt: DateTime(2026, 3, 1),
      );
      expect(IntensityGuidance.suggest(report), isNull,
          reason: 'being very happy is not a state to be calmed');
    });

    test('anger and fear are offered breathing', () {
      for (final emotion in [EmotionLabel.angry, EmotionLabel.scared]) {
        expect(
          IntensityGuidance.suggest(
            IntensityReport(
              emotion: emotion,
              level: IntensityLevel.very,
              reportedAt: DateTime(2026, 3, 1),
            ),
          ),
          SupportSuggestion.breathing,
        );
      }
    });

    test('sadness is offered a person, not a technique', () {
      expect(
        IntensityGuidance.suggest(
          IntensityReport(
            emotion: EmotionLabel.sad,
            level: IntensityLevel.tooMuch,
            reportedAt: DateTime(2026, 3, 1),
          ),
        ),
        SupportSuggestion.tellSomeone,
        reason: 'an app that only offers self-regulation teaches a child to '
            'handle everything alone',
      );
    });

    test('the scale can be stepped in both directions', () {
      expect(IntensityLevel.aLittle.gentler, isNull);
      expect(IntensityLevel.tooMuch.stronger, isNull);
      expect(IntensityLevel.quite.stronger, IntensityLevel.very);
      expect(IntensityLevel.quite.gentler, IntensityLevel.someWhat);
    });

    test('a report round-trips', () {
      final report = IntensityReport(
        emotion: EmotionLabel.angry,
        level: IntensityLevel.very,
        reportedAt: DateTime(2026, 3, 1, 9, 30),
      );
      final restored = IntensityReport.fromJson(report.toJson());
      expect(restored.emotion, EmotionLabel.angry);
      expect(restored.level, IntensityLevel.very);
      expect(restored.reportedAt, report.reportedAt);
    });

    testWidgets('choosing a level reports it and shows the caution',
        (tester) async {
      IntensityReport? reported;
      final appState = AppState(MockAuthRepository(), MockTtsService());
      await tester.pumpWidget(
        testApp(
          IntensityScreen(
            appState: appState,
            emotion: EmotionLabel.angry,
            onReported: (report) => reported = report,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _reveal(tester, const ValueKey('intensity-very'));
      await tester.tap(find.byKey(const ValueKey('intensity-very')));
      await tester.pumpAndSettle();

      expect(reported?.level, IntensityLevel.very);
      await _reveal(tester, const ValueKey('intensity-support'));
      expect(find.byKey(const ValueKey('intensity-support')), findsOneWidget);
      expect(find.byKey(const ValueKey('intensity-caution')), findsOneWidget);
    });

    testWidgets('a support suggestion can always be declined', (tester) async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      await tester.pumpWidget(
        testApp(
          IntensityScreen(appState: appState, emotion: EmotionLabel.scared),
        ),
      );
      await tester.pumpAndSettle();

      await _reveal(tester, const ValueKey('intensity-tooMuch'));
      await tester.tap(find.byKey(const ValueKey('intensity-tooMuch')));
      await tester.pumpAndSettle();
      await _reveal(tester, const ValueKey('intensity-not-now'));
      await tester.tap(find.byKey(const ValueKey('intensity-not-now')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('intensity-support')), findsNothing,
          reason: 'a suggestion a child cannot refuse is an instruction');
    });
  });

  // =========================================================================
  // Achievements timeline
  // =========================================================================
  group('achievements timeline', () {
    const builder = AchievementsBuilder();

    test('no sessions means no timeline', () {
      expect(builder.build(sessions: const [], stars: 0), isEmpty);
    });

    test('the first session is always the earliest entry', () {
      final achievements = builder.build(
        sessions: [
          _record(DateTime(2026, 3, 5)),
          _record(DateTime(2026, 3, 1)),
        ],
        stars: 0,
      );
      final first = achievements.firstWhere(
        (a) => a.kind == AchievementKind.firstSession,
      );
      expect(first.achievedAt, DateTime(2026, 3, 1));
    });

    test('entries are newest first', () {
      final achievements = builder.build(
        sessions: [
          for (var day = 1; day <= 12; day++) _record(DateTime(2026, 3, day)),
        ],
        stars: 30,
      );
      for (var i = 1; i < achievements.length; i++) {
        expect(
          achievements[i - 1].achievedAt.isAfter(achievements[i].achievedAt) ||
              achievements[i - 1].achievedAt == achievements[i].achievedAt,
          isTrue,
        );
      }
    });

    test('a milestone is dated to the session that crossed it', () {
      final sessions = [
        for (var day = 1; day <= 12; day++) _record(DateTime(2026, 3, day)),
      ];
      final achievements = builder.build(sessions: sessions, stars: 0);
      final ten = achievements.firstWhere((a) => a.id == 'sessions-10');
      expect(ten.achievedAt, DateTime(2026, 3, 10));
    });

    test('a milestone not reached does not appear', () {
      final achievements = builder.build(
        sessions: [_record(DateTime(2026, 3, 1))],
        stars: 0,
      );
      expect(achievements.any((a) => a.id == 'sessions-10'), isFalse);
    });

    test('each activity type gets its own first', () {
      final achievements = builder.build(
        sessions: [
          _record(DateTime(2026, 3, 1), type: 'emotion'),
          _record(DateTime(2026, 3, 2), type: 'expression'),
        ],
        stars: 0,
      );
      expect(
        achievements.any((a) => a.id == 'first-expression'),
        isTrue,
      );
    });

    test('longest streak counts the best run, not only the live one', () {
      // Three consecutive days, a gap, then two. The best is three even
      // though nothing is running now.
      expect(
        longestStreak(const [
          '2026-03-01',
          '2026-03-02',
          '2026-03-03',
          '2026-03-08',
          '2026-03-09',
        ]),
        3,
      );
      expect(longestStreak(const []), 0);
      expect(longestStreak(const ['2026-03-01']), 1);
    });

    test('a short streak is not celebrated', () {
      final achievements = builder.build(
        sessions: [
          _record(DateTime(2026, 3, 1)),
          _record(DateTime(2026, 3, 5)),
        ],
        stars: 0,
      );
      expect(
        achievements.any((a) => a.kind == AchievementKind.streakRecord),
        isFalse,
      );
    });

    test('the timeline holds no per-day counts', () {
      // A log of every session is not a story. Only firsts and milestones
      // belong here.
      final achievements = builder.build(
        sessions: [
          for (var day = 1; day <= 20; day++) _record(DateTime(2026, 3, day)),
        ],
        stars: 0,
      );
      expect(achievements.length, lessThan(20));
    });
  });
}
