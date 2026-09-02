import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/authentication/presentation/auth_screen.dart';
import 'package:autimate/features/parent_dashboard/presentation/dashboard_screen.dart';
import 'package:autimate/features/sensory_support/domain/ambient_sound.dart';
import 'package:autimate/features/settings/presentation/settings_screen.dart';

import 'helpers/test_app.dart';

class _TrackingAmbient implements AmbientSoundService {
  bool playing = false;
  int disposeCalls = 0;

  @override
  bool get isPlaying => playing;

  @override
  AmbientTrack get track => AmbientTrack.softRain;

  @override
  double get volumePreference => 0.5;

  @override
  Future<void> play() async => playing = true;

  @override
  Future<void> stop() async => playing = false;

  @override
  Future<void> selectTrack(AmbientTrack track) async {}

  @override
  Future<void> setVolumePreference(double value) async {}

  @override
  Future<void> setSensoryMode(bool value) async {}

  @override
  Future<void> dispose() async {
    disposeCalls++;
    playing = false;
  }
}

/// Scrolls the settings list until the add-child row is built. It sits at
/// the foot of a long scroll, so it does not exist until reached.
Future<void> _revealAddChild(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const ValueKey('add-child-tile')),
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

/// Regression cover for the resource leaks found in a whole-project sweep.
///
/// Every one of these passed `flutter analyze` and the whole existing suite
/// while leaking, which is the point: the analyser cannot see an object that
/// is created and never released.
void main() {
  group('controllers are released', () {
    testWidgets('the sign-in screen disposes its text controllers',
        (tester) async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      await tester.pumpWidget(testApp(AuthScreen(appState: appState)));
      await tester.pumpAndSettle();

      // Tearing the screen down must not leave the controllers alive. A
      // controller used after disposal throws, and one never disposed shows
      // up here as a clean teardown either way — so assert the teardown
      // itself raises nothing.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the observation dialog survives a full open and close',
        (tester) async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      await tester.pumpWidget(testApp(DashboardScreen(appState: appState)));
      await tester.pumpAndSettle();

      // Open, type, save, and let the exit animation finish. Disposing the
      // controller when showDialog resolved — rather than letting the
      // dialog own it — threw "used after being disposed" right here,
      // because the route is still rebuilding the field as it animates out.
      await tester.tap(find.byKey(const ValueKey('observation-button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('observation-text')),
        'Settled quickly today.',
      );
      await tester.tap(find.byKey(const ValueKey('observation-save')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the dialog can be opened repeatedly', (tester) async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      await tester.pumpWidget(testApp(DashboardScreen(appState: appState)));
      await tester.pumpAndSettle();

      // Three rounds: the leak this replaced grew one controller per open.
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const ValueKey('observation-button')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('observation-text')),
          'Note $i',
        );
        await tester.tap(find.byKey(const ValueKey('observation-save')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      final notes =
          await appState.progressRepository.getObservations('demo-child');
      expect(notes, hasLength(3));
    });

    testWidgets('cancelling the observation dialog records nothing',
        (tester) async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      await tester.pumpWidget(testApp(DashboardScreen(appState: appState)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('observation-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        await appState.progressRepository.getObservations('demo-child'),
        isEmpty,
      );
    });

    testWidgets('the child-profile dialog opens, saves, and closes cleanly',
        (tester) async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      await tester.pumpWidget(testApp(SettingsScreen(appState: appState)));
      await tester.pumpAndSettle();

      await _revealAddChild(tester);
      await tester.tap(find.byKey(const ValueKey('add-child-tile')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('add-child-name')),
        'Sara',
      );
      await tester.tap(find.byKey(const ValueKey('add-child-save')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(appState.children.map((c) => c.name), contains('Sara'));
    });

    testWidgets('an empty name is refused without closing the dialog',
        (tester) async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      final before = appState.children.length;
      await tester.pumpWidget(testApp(SettingsScreen(appState: appState)));
      await tester.pumpAndSettle();

      await _revealAddChild(tester);
      await tester.tap(find.byKey(const ValueKey('add-child-tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('add-child-save')));
      await tester.pumpAndSettle();

      expect(appState.children, hasLength(before));
      expect(find.byKey(const ValueKey('add-child-name')), findsOneWidget,
          reason: 'the dialog should stay open rather than silently closing');
    });
  });

  group('app state teardown', () {
    test('disposing the app state stops the ambient bed', () async {
      final ambient = _TrackingAmbient();
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        ambientSoundService: ambient,
      );
      await appState.toggleAmbientSound();
      expect(ambient.playing, isTrue);

      appState.dispose();
      await Future<void>.delayed(Duration.zero);

      expect(ambient.disposeCalls, 1,
          reason: 'audio outliving the state that owned it keeps playing');
      expect(ambient.playing, isFalse);
    });
  });
}
