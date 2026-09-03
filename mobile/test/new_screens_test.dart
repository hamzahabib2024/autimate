import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/backup/backup_service.dart';
import 'package:autimate/core/data/backup/profile_backup.dart';
import 'package:autimate/core/data/local_progress_repository.dart';
import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/communication/domain/custom_card_repository.dart';
import 'package:autimate/features/communication/domain/phrase_bank.dart';
import 'package:autimate/features/communication/domain/symbol_scale.dart';
import 'package:autimate/features/communication/presentation/board_options_screen.dart';
import 'package:autimate/features/emotion_recognition/domain/emotion_activity_engine.dart';
import 'package:autimate/features/parent_dashboard/presentation/achievements_screen.dart';
import 'package:autimate/features/progress/domain/progress_models.dart';
import 'package:autimate/features/routines/domain/routine_repository.dart';
import 'package:autimate/features/settings/presentation/backup_screen.dart';

import 'helpers/test_app.dart';

/// Brings a lazily-built widget into view on a long screen.
Future<void> _reveal(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  for (var attempt = 0; attempt < 14; attempt++) {
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

AppState _appState({
  KeyValueStore? store,
  PhraseBankRepository? phrases,
  CustomCardRepository? cards,
}) {
  final backing = store ?? InMemoryKeyValueStore();
  return AppState(
    MockAuthRepository(),
    MockTtsService(),
    progressRepository: LocalProgressRepository(store: backing),
    settingsStore: backing,
    phraseBankRepository: phrases,
    customCardRepository: cards,
  );
}

SavedPhrase _phrase(String id, {bool urgent = false}) => SavedPhrase(
  id: id,
  childId: 'demo-child',
  cardIds: const ['i_want', 'apple'],
  labelEn: 'I want an apple.',
  labelUr: 'مجھے سیب چاہیے۔',
  urgent: urgent,
);

ProgressRecord _record(DateTime at) => ProgressRecord(
  result: SessionResult(
    childId: 'demo-child',
    activityType: 'emotion',
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

void main() {
  // =========================================================================
  // Board options
  // =========================================================================
  group('board options screen', () {
    testWidgets('changing the layout takes effect and persists in state',
        (tester) async {
      final appState = _appState();
      await tester.pumpWidget(
        testApp(BoardOptionsScreen(appState: appState)),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('grid-shape-threeByThree')),
      );
      await tester.pumpAndSettle();
      expect(appState.gridShape, GridShape.threeByThree);
    });

    testWidgets('states the honest caveat about fixed layouts',
        (tester) async {
      // A fixed shape is groundwork for motor planning, not a delivery of
      // it, while the category filter still re-flows the grid. Saying
      // otherwise would be the easy thing to write and the wrong thing to
      // tell a caregiver.
      await tester.pumpWidget(
        testApp(BoardOptionsScreen(appState: _appState())),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('grid-shape-note')), findsOneWidget);
    });

    testWidgets('word prediction can be switched on', (tester) async {
      final appState = _appState();
      expect(appState.wordPredictionEnabled, isFalse);

      await tester.pumpWidget(
        testApp(BoardOptionsScreen(appState: appState)),
      );
      await tester.pumpAndSettle();
      await _reveal(tester, const ValueKey('prediction-toggle'));
      await tester.tap(find.byKey(const ValueKey('prediction-toggle')));
      await tester.pumpAndSettle();

      expect(appState.wordPredictionEnabled, isTrue);
    });

    testWidgets('the phrase-bank caution is on screen', (tester) async {
      await tester.pumpWidget(
        testApp(BoardOptionsScreen(appState: _appState())),
      );
      await tester.pumpAndSettle();
      await _reveal(tester, const ValueKey('phrase-caution'));
      expect(find.byKey(const ValueKey('phrase-caution')), findsOneWidget);
    });

    testWidgets('an empty phrase bank shows the empty state', (tester) async {
      await tester.pumpWidget(
        testApp(BoardOptionsScreen(appState: _appState())),
      );
      await tester.pumpAndSettle();
      await _reveal(tester, const ValueKey('print-board'));
      expect(find.textContaining('No saved phrases'), findsOneWidget);
    });

    testWidgets('a saved phrase can be marked urgent and removed',
        (tester) async {
      final bank = InMemoryPhraseBankRepository();
      await bank.save(_phrase('p1'));
      final appState = _appState(phrases: bank);
      await appState.loadPhrases(force: true);

      await tester.pumpWidget(
        testApp(BoardOptionsScreen(appState: appState)),
      );
      await tester.pumpAndSettle();

      await _reveal(tester, const ValueKey('phrase-urgent-p1'));
      await tester.tap(find.byKey(const ValueKey('phrase-urgent-p1')));
      await tester.pumpAndSettle();
      expect(appState.savedPhrases.single.urgent, isTrue);

      await _reveal(tester, const ValueKey('phrase-delete-p1'));
      await tester.tap(find.byKey(const ValueKey('phrase-delete-p1')));
      await tester.pumpAndSettle();
      expect(appState.savedPhrases, isEmpty);
    });

    testWidgets('the colour legend is reachable from here', (tester) async {
      await tester.pumpWidget(
        testApp(BoardOptionsScreen(appState: _appState())),
      );
      await tester.pumpAndSettle();
      await _reveal(tester, const ValueKey('word-class-legend'));
      expect(find.byKey(const ValueKey('word-class-legend')), findsOneWidget);
    });
  });

  // =========================================================================
  // Achievements timeline
  // =========================================================================
  group('achievements screen', () {
    testWidgets('shows the empty state before any activity', (tester) async {
      await tester.pumpWidget(
        testApp(AchievementsScreen(appState: _appState())),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Milestones will appear'), findsOneWidget);
    });

    testWidgets('lists milestones once sessions exist', (tester) async {
      final store = InMemoryKeyValueStore();
      final repository = LocalProgressRepository(store: store);
      for (var day = 1; day <= 12; day++) {
        await repository.recordSession(_record(DateTime(2026, 3, day)).result);
      }
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        progressRepository: repository,
        settingsStore: store,
      );

      await tester.pumpWidget(testApp(AchievementsScreen(appState: appState)));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('achievement-first-session')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('achievement-sessions-10')),
        findsOneWidget,
      );
    });

    testWidgets('does not render per-day counts', (tester) async {
      // A log of every session is not a story. Only firsts and milestones
      // belong on this screen.
      final store = InMemoryKeyValueStore();
      final repository = LocalProgressRepository(store: store);
      for (var day = 1; day <= 20; day++) {
        await repository.recordSession(_record(DateTime(2026, 3, day)).result);
      }
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        progressRepository: repository,
        settingsStore: store,
      );

      await tester.pumpWidget(testApp(AchievementsScreen(appState: appState)));
      await tester.pumpAndSettle();

      final rows = find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key as ValueKey<String>).value.startsWith('achievement-'),
      );
      expect(rows.evaluate().length, lessThan(20));
    });
  });

  // =========================================================================
  // Backup and restore
  // =========================================================================
  group('backup screen', () {
    BackupService serviceFor(AppState appState) => BackupService(
      appState: appState,
      customCards: InMemoryCustomCardRepository(),
      routines: LocalRoutineRepository(store: InMemoryKeyValueStore()),
    );

    testWidgets('the privacy warning sits where the decision is made',
        (tester) async {
      // A backup file holds a child's name and history in plain text. The
      // warning belongs on this screen, not in a policy nobody opens.
      final appState = _appState();
      await tester.pumpWidget(
        testApp(
          BackupScreen(appState: appState, service: serviceFor(appState)),
        ),
      );
      await tester.pumpAndSettle();
      await _reveal(tester, const ValueKey('backup-privacy'));
      expect(find.byKey(const ValueKey('backup-privacy')), findsOneWidget);
    });

    testWidgets('both actions are offered', (tester) async {
      final appState = _appState();
      await tester.pumpWidget(
        testApp(
          BackupScreen(appState: appState, service: serviceFor(appState)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('backup-export')), findsOneWidget);
      expect(find.byKey(const ValueKey('backup-import')), findsOneWidget);
    });

    testWidgets('a failed import reports it and changes nothing',
        (tester) async {
      final appState = _appState();
      final before = appState.children.length;
      await tester.pumpWidget(
        testApp(
          BackupScreen(
            appState: appState,
            service: _FailingBackupService(appState),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('backup-import')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('backup-status')), findsOneWidget);
      expect(appState.children, hasLength(before),
          reason: 'a failed import must leave the device untouched');
    });

    testWidgets('a cancelled import reports nothing at all', (tester) async {
      final appState = _appState();
      await tester.pumpWidget(
        testApp(
          BackupScreen(
            appState: appState,
            service: _CancellingBackupService(appState),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('backup-import')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('backup-status')), findsNothing);
    });
  });
}

/// Fails at the picker, standing in for an unreadable or wrong file.
class _FailingBackupService extends BackupService {
  _FailingBackupService(AppState appState)
    : super(
        appState: appState,
        customCards: InMemoryCustomCardRepository(),
        routines: LocalRoutineRepository(store: InMemoryKeyValueStore()),
      );

  @override
  Future<ProfileBackup?> pickAndDecode() async =>
      throw const BackupFormatException(BackupError.notAutiMate);
}

/// Stands in for a caregiver backing out of the picker.
class _CancellingBackupService extends BackupService {
  _CancellingBackupService(AppState appState)
    : super(
        appState: appState,
        customCards: InMemoryCustomCardRepository(),
        routines: LocalRoutineRepository(store: InMemoryKeyValueStore()),
      );

  @override
  Future<ProfileBackup?> pickAndDecode() async => null;
}
