import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/backup/backup_service.dart';
import 'package:autimate/core/data/backup/profile_backup.dart';
import 'package:autimate/core/data/local_progress_repository.dart';
import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/communication/domain/aac_catalog.dart';
import 'package:autimate/features/communication/domain/custom_card_repository.dart';
import 'package:autimate/features/communication/domain/literacy_support.dart';
import 'package:autimate/features/communication/domain/sentence_realiser.dart';
import 'package:autimate/features/communication/presentation/literacy_screen.dart';
import 'package:autimate/features/routines/domain/routine_repository.dart';
import 'package:autimate/features/routines/domain/visual_timer.dart';
import 'package:autimate/features/routines/presentation/waiting_screen.dart';
import 'package:autimate/shared/widgets/app_widgets.dart';

import 'helpers/test_app.dart';

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
  // 1. Transition to Literacy
  // =========================================================================
  group('T2L ladder', () {
    test('word weight rises monotonically along the ladder', () {
      final weights =
          LiteracyLevel.values.map((level) => level.wordWeight).toList();
      for (var i = 1; i < weights.length; i++) {
        expect(weights[i], greaterThan(weights[i - 1]));
      }
      expect(weights.first, 0.0);
      expect(weights.last, 1.0);
    });

    test('the symbol never vanishes before the final rung', () {
      // The fallback is withdrawn gradually on purpose: a symbol at 40% is
      // still usable on a hard day, and removing it early strands a child.
      for (final level in LiteracyLevel.values) {
        if (level == LiteracyLevel.textOnly) {
          expect(level.symbolOpacity, 0.0);
          expect(level.showsSymbol, isFalse);
        } else {
          expect(level.symbolOpacity, greaterThan(0.0));
          expect(level.showsSymbol, isTrue);
        }
      }
    });

    test('the word grows as the symbol recedes', () {
      final sizes =
          LiteracyLevel.values.map((level) => level.labelSize).toList();
      for (var i = 1; i < sizes.length; i++) {
        expect(sizes[i], greaterThanOrEqualTo(sizes[i - 1]));
      }
    });

    test('the ladder can always be climbed back down', () {
      // A level that stopped working needs an exit. Reading is not
      // monotonic and neither is a hard week.
      expect(LiteracyLevel.off.previous, isNull);
      expect(LiteracyLevel.textOnly.next, isNull);
      for (final level in LiteracyLevel.values) {
        if (level != LiteracyLevel.off) {
          expect(level.previous, isNotNull);
          expect(level.previous!.next, level);
        }
      }
    });

    test('only the early rungs flash on selection', () {
      expect(LiteracyLevel.flash.flashesOnSelect, isTrue);
      expect(LiteracyLevel.emphasis.flashesOnSelect, isTrue);
      expect(LiteracyLevel.textOnly.flashesOnSelect, isFalse);
    });

    test('the preference round-trips', () {
      const pref = LiteracyPreference(level: LiteracyLevel.fading);
      expect(
        LiteracyPreference.fromJson(pref.toJson()).level,
        LiteracyLevel.fading,
      );
      expect(
        LiteracyPreference.fromJson(const {'level': 'nonsense'}).level,
        LiteracyLevel.off,
      );
    });

    test('the level is per child, not per device', () async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      final first = appState.selectedChild.id;
      final second = appState.addChild(name: 'Sara', supportLevel: 'Beginner');

      appState.setLiteracyLevel(first, LiteracyLevel.fading);
      expect(appState.literacyFor(first), LiteracyLevel.fading);
      expect(appState.literacyFor(second.id), LiteracyLevel.off,
          reason: 'two children sharing a tablet are at different rungs');
    });

    test('levels survive a restart', () async {
      final store = InMemoryKeyValueStore();
      final first = AppState(
        MockAuthRepository(),
        MockTtsService(),
        settingsStore: store,
      );
      first.setLiteracyLevel('demo-child', LiteracyLevel.emphasis);
      await first.persistSettings();

      final restarted = AppState(
        MockAuthRepository(),
        MockTtsService(),
        settingsStore: store,
      );
      await restarted.loadPersistedSettings();
      expect(restarted.literacyFor('demo-child'), LiteracyLevel.emphasis);
    });

    testWidgets('the tile drops the symbol at the top rung', (tester) async {
      for (final level in [LiteracyLevel.off, LiteracyLevel.textOnly]) {
        await tester.pumpWidget(
          testApp(
            SizedBox(
              width: 200,
              height: 220,
              child: SymbolTile(
                card: cardById('apple')!,
                showUrdu: false,
                literacy: level,
                onTap: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byIcon(cardById('apple')!.icon),
          level == LiteracyLevel.textOnly ? findsNothing : findsOneWidget,
        );
        expect(find.text('apple'), findsOneWidget,
            reason: 'the word is present at every rung');
      }
    });

    testWidgets('the caregiver screen shows the caution', (tester) async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      await tester.pumpWidget(testApp(LiteracyScreen(appState: appState)));
      await tester.pumpAndSettle();
      await _reveal(tester, const ValueKey('literacy-caution'));
      expect(find.byKey(const ValueKey('literacy-caution')), findsOneWidget);
    });

    testWidgets('choosing a rung stores it', (tester) async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      await tester.pumpWidget(testApp(LiteracyScreen(appState: appState)));
      await tester.pumpAndSettle();

      await _reveal(tester, const ValueKey('literacy-emphasis'));
      await tester.tap(find.byKey(const ValueKey('literacy-emphasis')));
      await tester.pumpAndSettle();

      expect(
        appState.literacyFor(appState.selectedChild.id),
        LiteracyLevel.emphasis,
      );
    });
  });

  // =========================================================================
  // 2. Visual timer and waiting board
  // =========================================================================
  group('VisualTimer', () {
    late DateTime now;
    DateTime clock() => now;

    setUp(() => now = DateTime(2026, 3, 1, 10));

    VisualTimer build({
      Duration duration = const Duration(minutes: 2),
      TimerStyle style = TimerStyle.stepped,
    }) => VisualTimer(duration: duration, style: style, clock: clock);

    test('counts down rather than up', () {
      final timer = build()..start();
      expect(timer.remaining, const Duration(minutes: 2));
      now = now.add(const Duration(seconds: 30));
      expect(timer.remaining, const Duration(seconds: 90));
    });

    test('never reports negative time', () {
      final timer = build()..start();
      now = now.add(const Duration(minutes: 10));
      expect(timer.remaining, Duration.zero);
      expect(timer.progress, 1.0);
      expect(timer.isComplete, isTrue);
    });

    test('pause holds the clock, resume continues it', () {
      final timer = build()..start();
      now = now.add(const Duration(seconds: 30));
      timer.pause();
      now = now.add(const Duration(minutes: 5));
      expect(timer.remaining, const Duration(seconds: 90),
          reason: 'a paused wait must not drain while nobody is watching');
      timer.start();
      now = now.add(const Duration(seconds: 30));
      expect(timer.remaining, const Duration(seconds: 60));
    });

    test('reset returns it to the start', () {
      final timer = build()..start();
      now = now.add(const Duration(seconds: 45));
      timer.reset();
      expect(timer.remaining, const Duration(minutes: 2));
      expect(timer.isRunning, isFalse);
      expect(timer.isComplete, isFalse);
    });

    test('stepped display quantises, smooth does not', () {
      final smooth = build(style: TimerStyle.smooth)..start();
      final stepped = build(style: TimerStyle.stepped)..start();
      now = now.add(const Duration(seconds: 7));

      expect(smooth.displayProgress, smooth.progress);
      // 7s of 120s is 5.8%; with 12 steps that floors to 0.
      expect(stepped.displayProgress, 0.0);
      expect(stepped.progress, greaterThan(0));
    });

    test('a stepped timer rebuilds far less often than a smooth one', () {
      // This is the whole reason the enum exists: the same information with
      // a fraction of the motion.
      expect(
        build(style: TimerStyle.stepped).tickInterval,
        greaterThan(build(style: TimerStyle.smooth).tickInterval),
      );
      expect(
        build(style: TimerStyle.still).tickInterval,
        const Duration(seconds: 1),
      );
    });

    test('one more minute extends without losing elapsed time', () {
      final timer = build()..start();
      now = now.add(const Duration(seconds: 90));
      final extended = timer.extendedBy(const Duration(minutes: 1));
      expect(extended.duration, const Duration(minutes: 3));
      expect(extended.remaining, const Duration(seconds: 90));
      expect(extended.isRunning, isTrue);
    });

    test('a zero-length timer does not divide by zero', () {
      final timer = build(duration: Duration.zero)..start();
      expect(timer.progress, 1.0);
      expect(timer.displayProgress.isNaN, isFalse);
    });

    test('presets stay inside a wait a child can hold in mind', () {
      expect(TimerPresets.values, isNotEmpty);
      for (final preset in TimerPresets.values) {
        expect(preset.inMinutes, lessThanOrEqualTo(15));
        expect(preset.inMinutes, greaterThan(0));
      }
    });
  });

  group('waiting board', () {
    testWidgets('sensory mode picks the quietest timer style', (tester) async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      appState.toggleSensoryMode(true);

      await tester.pumpWidget(testApp(WaitingScreen(appState: appState)));
      await tester.pumpAndSettle();
      await _reveal(tester, const ValueKey('waiting-style-still'));

      // The still style is chosen for us; the smooth chip is offered but
      // not selected, so a caregiver can still opt in deliberately.
      final still = tester.widget<ChoiceChip>(
        find.byKey(const ValueKey('waiting-style-still')),
      );
      expect(still.selected, isTrue);
      final smooth = tester.widget<ChoiceChip>(
        find.byKey(const ValueKey('waiting-style-smooth')),
      );
      expect(smooth.selected, isFalse);
    });

    testWidgets('picking a preset changes the clock', (tester) async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      await tester.pumpWidget(testApp(WaitingScreen(appState: appState)));
      await tester.pumpAndSettle();

      await _reveal(tester, const ValueKey('waiting-preset-5'));
      await tester.tap(find.byKey(const ValueKey('waiting-preset-5')));
      await tester.pumpAndSettle();

      final clock = tester.widget<Text>(
        find.byKey(const ValueKey('waiting-clock')),
      );
      expect(clock.data, '5:00');
    });

    testWidgets('one more minute is always reachable', (tester) async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      await tester.pumpWidget(testApp(WaitingScreen(appState: appState)));
      await tester.pumpAndSettle();

      await _reveal(tester, const ValueKey('waiting-extend'));
      await tester.tap(find.byKey(const ValueKey('waiting-extend')));
      await tester.pumpAndSettle();

      final clock = tester.widget<Text>(
        find.byKey(const ValueKey('waiting-clock')),
      );
      expect(clock.data, '3:00');
    });

    testWidgets('leaves no timer running when closed', (tester) async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      await tester.pumpWidget(testApp(WaitingScreen(appState: appState)));
      await tester.pumpAndSettle();
      await _reveal(tester, const ValueKey('waiting-toggle'));
      await tester.tap(find.byKey(const ValueKey('waiting-toggle')));
      await tester.pump();

      await tester.pumpWidget(testApp(const SizedBox()));
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    });
  });

  // =========================================================================
  // 3. Recorded caregiver audio
  // =========================================================================
  group('recorded audio on cards', () {
    CustomCard card({String? en, String? ur}) => CustomCard(
      id: 'c1',
      childId: 'demo-child',
      labelEn: 'Ball',
      labelUr: 'گیند',
      category: AacCategory.objects,
      audioPathEn: en,
      audioPathUr: ur,
    );

    test('a clip is chosen per language', () {
      final both = card(en: '/a/en.m4a', ur: '/a/ur.m4a');
      expect(both.audioFor(AppLanguage.en), '/a/en.m4a');
      expect(both.audioFor(AppLanguage.ur), '/a/ur.m4a');
    });

    test('a missing clip falls back to null so TTS can take over', () {
      final onlyEnglish = card(en: '/a/en.m4a');
      expect(onlyEnglish.audioFor(AppLanguage.ur), isNull,
          reason: 'the board must fall through to synthesis, not go silent');
      expect(onlyEnglish.hasRecordedAudio, isTrue);
      expect(card().hasRecordedAudio, isFalse);
    });

    test('every stored clip is listed for cleanup', () {
      expect(card(en: '/a/en.m4a', ur: '/a/ur.m4a').audioPaths, hasLength(2));
      expect(card(en: '/a/en.m4a').audioPaths, ['/a/en.m4a']);
      expect(card().audioPaths, isEmpty);
    });

    test('clips survive the JSON round trip', () {
      final restored = CustomCard.fromJson(
        card(en: '/a/en.m4a', ur: '/a/ur.m4a').toJson(),
      );
      expect(restored.audioPathEn, '/a/en.m4a');
      expect(restored.audioPathUr, '/a/ur.m4a');
    });

    test('an older card with no audio still decodes', () {
      // Cards written before this feature existed must keep working.
      final legacy = CustomCard.fromJson(const {
        'id': 'old',
        'childId': 'demo-child',
        'labelEn': 'Cup',
        'labelUr': 'پیالی',
        'category': 'objects',
      });
      expect(legacy.audioPathEn, isNull);
      expect(legacy.hasRecordedAudio, isFalse);
    });
  });

  // =========================================================================
  // 4. Backup and restore
  // =========================================================================
  group('profile backup', () {
    Future<BackupService> service(AppState appState) async => BackupService(
      appState: appState,
      customCards: InMemoryCustomCardRepository(),
      routines: LocalRoutineRepository(store: InMemoryKeyValueStore()),
    );

    test('a snapshot round-trips through its file format', () async {
      final store = InMemoryKeyValueStore();
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        progressRepository: LocalProgressRepository(store: store),
        settingsStore: store,
      );
      final backup = await (await service(appState)).build();
      final restored = ProfileBackup.decode(backup.encode());

      expect(restored.children.map((c) => c.name),
          backup.children.map((c) => c.name));
      expect(restored.version, ProfileBackup.currentVersion);
    });

    test('the caregiver PIN is never in a backup', () async {
      final appState = AppState(MackAuthShim(), MockTtsService());
      final backup = await (await service(appState)).build();
      final encoded = backup.encode().toLowerCase();
      // A backup must not be a way around the parent lock.
      expect(encoded.contains('pin'), isFalse);
      expect(encoded.contains('parentpinhash'), isFalse);
    });

    test('a file that is not JSON is refused clearly', () {
      expect(
        () => ProfileBackup.decode('not json at all'),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.error,
            'error',
            BackupError.notJson,
          ),
        ),
      );
    });

    test('JSON from another app is refused', () {
      expect(
        () => ProfileBackup.decode('{"hello": "world"}'),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.error,
            'error',
            BackupError.notAutiMate,
          ),
        ),
      );
    });

    test('a newer file is refused rather than guessed at', () {
      // Importing a shape we do not understand risks silently dropping data.
      final future = '{"magic": "${ProfileBackup.magic}", "version": 99}';
      expect(
        () => ProfileBackup.decode(future),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.error,
            'error',
            BackupError.tooNew,
          ),
        ),
      );
    });

    test('merge keeps what is already on the device', () async {
      final store = InMemoryKeyValueStore();
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        progressRepository: LocalProgressRepository(store: store),
        settingsStore: store,
      );
      final existing = appState.children.length;

      final incoming = ProfileBackup(
        version: 1,
        exportedAt: DateTime(2026, 3, 1),
        children: const [
          ChildProfile(id: 'imported', name: 'Bilal', supportLevel: 'Beginner'),
        ],
        selectedChildId: 'imported',
        customCards: const [],
        routineSteps: const [],
        sessions: const [],
        cardUsage: const [],
        observations: const [],
        settings: const {},
      );
      await (await service(appState)).apply(incoming);

      expect(appState.children, hasLength(existing + 1));
      expect(appState.children.map((c) => c.name), contains('Bilal'));
    });

    test('imported children keep their ids so their data still points home',
        () async {
      final store = InMemoryKeyValueStore();
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        progressRepository: LocalProgressRepository(store: store),
        settingsStore: store,
      );
      final cards = InMemoryCustomCardRepository();
      final backupService = BackupService(
        appState: appState,
        customCards: cards,
        routines: LocalRoutineRepository(store: InMemoryKeyValueStore()),
      );

      const child = ChildProfile(
        id: 'child-abc',
        name: 'Zara',
        supportLevel: 'Beginner',
      );
      await backupService.apply(
        ProfileBackup(
          version: 1,
          exportedAt: DateTime(2026, 3, 1),
          children: const [child],
          selectedChildId: child.id,
          customCards: const [
            CustomCard(
              id: 'card-1',
              childId: 'child-abc',
              labelEn: 'Swing',
              labelUr: 'جھولا',
              category: AacCategory.activities,
            ),
          ],
          routineSteps: const [],
          sessions: const [],
          cardUsage: const [],
          observations: const [],
          settings: const {},
        ),
      );

      expect(appState.children.any((c) => c.id == 'child-abc'), isTrue);
      final restored = await cards.cardsFor('child-abc');
      expect(restored.single.labelEn, 'Swing',
          reason: 'a regenerated id would orphan every imported card');
    });

    test('the summary reports media that will not come back', () {
      final backup = ProfileBackup(
        version: 1,
        exportedAt: DateTime(2026, 3, 1),
        children: const [
          ChildProfile(id: 'c', name: 'Ayaan', supportLevel: 'Beginner'),
        ],
        selectedChildId: 'c',
        customCards: const [
          CustomCard(
            id: 'card-1',
            childId: 'c',
            labelEn: 'Ball',
            labelUr: 'گیند',
            category: AacCategory.objects,
            imagePath: '/photos/ball.png',
            audioPathEn: '/audio/ball.m4a',
          ),
        ],
        routineSteps: const [],
        sessions: const [],
        cardUsage: const [],
        observations: const [],
        settings: const {},
      );
      // Referenced, not embedded — the caregiver is told before importing.
      expect(backup.summary.mediaCount, 2);
      expect(backup.summary.childNames, ['Ayaan']);
    });
  });
}

/// Auth repository whose name would appear in a naive PIN scan; keeps the
/// "no PIN in the backup" assertion honest rather than accidentally passing.
class MackAuthShim extends MockAuthRepository {}
