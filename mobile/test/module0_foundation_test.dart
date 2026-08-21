import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/core/services/connectivity_service.dart';
import 'package:autimate/features/home/presentation/app_shell.dart';
import 'package:autimate/features/settings/presentation/parent_gate_screen.dart';
import 'helpers/test_app.dart';

void main() {
  AppState stateWithStore(KeyValueStore store) =>
      AppState(MockAuthRepository(), MockTtsService(), settingsStore: store);

  group('multi-child profiles', () {
    test('adds a child, selects it, and persists across reload', () async {
      final store = InMemoryKeyValueStore();
      final state = stateWithStore(store);

      final added = state.addChild(name: 'Sara', supportLevel: 'Advanced');
      expect(state.selectedChild.id, added.id);
      expect(state.children.length, 2);

      await state.loadPersistedSettings();
      expect(state.selectedChild.name, 'Sara');
      expect(state.selectedChild.supportLevel, 'Advanced');

      state.selectChild('demo-child');
      expect(state.selectedChild.name, 'Ayaan');
      await state.loadPersistedSettings();
      expect(state.selectedChild.id, 'demo-child');
    });

    test('corrupt children payload falls back to the demo profile', () async {
      final store = InMemoryKeyValueStore();
      await store.write('autimate.children', '{not json');
      final state = stateWithStore(store);
      await state.loadPersistedSettings();

      expect(state.selectedChild.name, 'Ayaan');
    });
  });

  group('parent lock', () {
    test('pin hash verifies and persists without storing the pin', () async {
      final store = InMemoryKeyValueStore();
      final state = stateWithStore(store);
      await state.setParentPin('4321');

      expect(state.verifyParentPin('4321'), isTrue);
      expect(state.verifyParentPin('0000'), isFalse);
      expect(state.hasParentPin, isTrue);
      expect(
        (await store.read('autimate.settings.parentPinHash'))!
            .contains('4321'),
        isFalse,
      );

      final reloaded = stateWithStore(store);
      await reloaded.loadPersistedSettings();
      expect(reloaded.verifyParentPin('4321'), isTrue);
    });

    testWidgets('gate rejects a wrong pin and unlocks with the right one', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final state = AppState(MockAuthRepository(), MockTtsService());
      await state.setParentPin('2468');

      var result = <bool>[];
      await tester.pumpWidget(
        testApp(Builder(builder: (context) {
          return TextButton(
            onPressed: () async {
              final unlocked = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => ParentGateScreen(appState: state),
                ),
              );
              result = [unlocked ?? false];
            },
            child: const Text('open'),
          );
        })),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      for (final digit in ['1', '3', '5']) {
        await tester.tap(find.byKey(ValueKey('pin-digit-$digit')));
        await tester.pump();
      }
      // A wrong fourth digit triggers the failure path.
      await tester.tap(find.byKey(const ValueKey('pin-digit-7')));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
      expect(tester.any(find.text('Incorrect PIN. Try again.')), isTrue);
      expect(find.text('AutiMate'), findsNothing);

      for (final digit in ['2', '4', '6']) {
        await tester.tap(find.byKey(ValueKey('pin-digit-$digit')));
        await tester.pump();
      }
      await tester.tap(find.byKey(const ValueKey('pin-digit-8')));
      await tester.pumpAndSettle();

      expect(result, [true]);
    });

    testWidgets('gate opens immediately when no pin is configured', (
      tester,
    ) async {
      final state = AppState(MockAuthRepository(), MockTtsService());
      var result = false;
      await tester.pumpWidget(
        testApp(Builder(builder: (context) {
          return TextButton(
            onPressed: () async {
              final unlocked = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => ParentGateScreen(appState: state),
                ),
              );
              result = unlocked ?? false;
            },
            child: const Text('open'),
          );
        })),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });
  });

  group('child mode gating', () {
    testWidgets('settings and progress stay locked until the gate passes', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final state = AppState(MockAuthRepository(), MockTtsService());
      await state.setParentPin('1111');
      state.setChildMode(true);
      await tester.pumpWidget(testApp(AppShell(appState: state)));
      await tester.pumpAndSettle();

      // Locked: cancel keeps the caregiver area hidden.
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Enter caregiver PIN'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('gate-cancel')));
      await tester.pumpAndSettle();
      expect(find.text('Sensory-friendly mode'), findsNothing);

      // Unlocked: the correct PIN opens settings.
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pin-digit-1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('pin-digit-1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('pin-digit-1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('pin-digit-1')));
      await tester.pumpAndSettle();

      expect(find.text('Sensory-friendly mode'), findsOneWidget);
    });
  });

  group('connectivity', () {
    testWidgets('a static offline source drives the offline flag', (
      tester,
    ) async {
      final state = AppState(
        MockAuthRepository(),
        MockTtsService(),
        connectivityService: const StaticConnectivityService(online: false),
      );
      state.startListeningToConnectivity();
      await tester.pump();
      expect(state.offline, isTrue);
    });
  });

  testWidgets('offline banner renders above the shell when flagged', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final state = AppState(MockAuthRepository(), MockTtsService());
    await tester.pumpWidget(testApp(AppShell(appState: state)));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('offline-banner')), findsNothing);

    state.setOffline(true);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('offline-banner')), findsOneWidget);

    state.setOffline(false);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('offline-banner')), findsNothing);
  });
}

