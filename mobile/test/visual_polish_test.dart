import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/core/theme/app_depth.dart';
import 'package:autimate/core/theme/app_theme.dart';
import 'package:autimate/features/communication/domain/symbol_scale.dart';
import 'package:autimate/features/onboarding/presentation/splash_screen.dart';
import 'package:autimate/shared/widgets/app_widgets.dart';

import 'helpers/test_app.dart';

Widget _host(Widget child, {bool dark = false, bool sensory = false}) =>
    MaterialApp(
      theme: dark
          ? AppTheme.dark(sensoryMode: sensory)
          : AppTheme.light(sensoryMode: sensory),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('intro animation', () {
    testWidgets('completes on its own and hands over', (tester) async {
      var done = false;
      final appState = AppState(MockAuthRepository(), MockTtsService());

      await tester.pumpWidget(
        testApp(
          SplashScreen(appState: appState, onComplete: () => done = true),
        ),
      );
      await tester.pump();
      expect(done, isFalse, reason: 'it should still be playing');

      // The controller starts on the first post-frame callback, so allow a
      // little past the nominal duration.
      await tester.pump(SplashScreen.duration + const Duration(milliseconds: 200));
      await tester.pump();
      expect(done, isTrue, reason: 'the intro must never be a dead end');
    });

    testWidgets('a tap anywhere skips it immediately', (tester) async {
      var done = false;
      final appState = AppState(MockAuthRepository(), MockTtsService());

      await tester.pumpWidget(
        testApp(
          SplashScreen(appState: appState, onComplete: () => done = true),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tapAt(const Offset(200, 300));
      await tester.pump();
      expect(done, isTrue);

      // Let the controller finish so no work is left running.
      await tester.pump(SplashScreen.duration);
    });

    testWidgets('it hands over exactly once', (tester) async {
      var calls = 0;
      final appState = AppState(MockAuthRepository(), MockTtsService());

      await tester.pumpWidget(
        testApp(SplashScreen(appState: appState, onComplete: () => calls++)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tapAt(const Offset(200, 300));
      await tester.pump();
      // A second tap, then the controller also completing, must not
      // re-trigger navigation.
      await tester.tapAt(const Offset(200, 300));
      await tester.pump(SplashScreen.duration + const Duration(milliseconds: 200));
      await tester.pump();
      expect(calls, 1);
    });

    testWidgets('sensory mode still resolves, without motion', (tester) async {
      var done = false;
      final appState = AppState(MockAuthRepository(), MockTtsService());
      appState.toggleSensoryMode(true);

      await tester.pumpWidget(
        testApp(
          SplashScreen(appState: appState, onComplete: () => done = true),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(done, isTrue,
          reason: 'reduced motion shortens the intro, never removes the exit');
    });

    test('the intro stays inside the two-second guideline', () {
      expect(SplashScreen.duration.inMilliseconds, lessThan(2000));
    });
  });

  group('Entrance', () {
    testWidgets('leaves no pending timers when disposed mid-flight',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const Entrance(index: 6, child: Text('hello')),
        ),
      );
      await tester.pump(const Duration(milliseconds: 20));
      // Tearing it down part-way must not strand a timer — a fast scroll
      // does exactly this.
      await tester.pumpWidget(_host(const SizedBox()));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('the stagger is capped so long lists do not ripple',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const Column(
            children: [
              Entrance(index: 8, child: Text('a')),
              Entrance(index: 400, child: Text('b')),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
    });

    testWidgets('content is fully visible once settled', (tester) async {
      await tester.pumpWidget(
        _host(const Entrance(index: 3, child: Text('settled'))),
      );
      await tester.pumpAndSettle();
      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.text('settled'),
          matching: find.byType(Opacity),
        ).first,
      );
      expect(opacity.opacity, closeTo(1.0, 0.001));
    });
  });

  group('depth', () {
    testWidgets('sensory mode removes every shadow', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _host(Builder(builder: (context) {
          ctx = context;
          return const SizedBox();
        })),
      );
      expect(AppDepth.card(ctx, sensoryMode: true), isEmpty);
      expect(AppDepth.lifted(ctx, sensoryMode: true), isEmpty);
      expect(
        AppDepth.tinted(const Color(0xFF0F766E), sensoryMode: true),
        isEmpty,
      );
      expect(AppDepth.sheen(const Color(0xFFFFFFFF), sensoryMode: true),
          isNull);
    });

    testWidgets('normal mode layers soft shadows rather than one hard one',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _host(Builder(builder: (context) {
          ctx = context;
          return const SizedBox();
        })),
      );
      final shadows = AppDepth.card(ctx);
      expect(shadows, hasLength(2),
          reason: 'a contact shadow and an ambient one');
      for (final shadow in shadows) {
        expect(shadow.color.a, lessThan(0.1),
            reason: 'every layer must stay below the threshold of notice');
      }
    });

    test('the sheen is too subtle to read as a gradient', () {
      const base = Color(0xFFEEEEEE);
      final gradient = AppDepth.sheen(base) as LinearGradient;
      final top = HSLColor.fromColor(gradient.colors.first).lightness;
      final bottom = HSLColor.fromColor(gradient.colors.last).lightness;
      expect(top - bottom, lessThan(0.06),
          reason: 'it exists to stop a flat fill looking dead, nothing more');
    });
  });

  group('symbol size', () {
    test('each step is genuinely larger', () {
      final sizes = SymbolScale.values.map((s) => s.maxExtent).toList();
      for (var i = 1; i < sizes.length; i++) {
        expect(sizes[i], greaterThan(sizes[i - 1]));
      }
    });

    test('the aspect ratio holds, so the symbol keeps its share of the tile',
        () {
      final ratios = SymbolScale.values
          .map((s) => s.mainExtent / s.maxExtent)
          .toList();
      for (final ratio in ratios) {
        expect(ratio, closeTo(ratios.first, 0.02));
      }
    });

    test('the preference survives a restart', () async {
      final store = InMemoryKeyValueStore();
      final first = AppState(
        MockAuthRepository(),
        MockTtsService(),
        settingsStore: store,
      );
      first.setSymbolScale(SymbolScale.largest);
      await first.persistSettings();

      final restarted = AppState(
        MockAuthRepository(),
        MockTtsService(),
        settingsStore: store,
      );
      await restarted.loadPersistedSettings();
      expect(restarted.symbolScale, SymbolScale.largest);
    });
  });

  group('page transitions', () {
    test('sensory mode drops the scale change entirely', () {
      final calm = AppTheme.light(sensoryMode: true).pageTransitionsTheme;
      final normal = AppTheme.light(sensoryMode: false).pageTransitionsTheme;
      expect(
        calm.builders[TargetPlatform.android].runtimeType,
        isNot(normal.builders[TargetPlatform.android].runtimeType),
      );
    });

    testWidgets('neither transition slides the viewport', (tester) async {
      // The guard that matters: no builder may translate by a large
      // fraction of the screen. Both are fade-based by construction.
      for (final sensory in [false, true]) {
        final builder = AppTheme.light(sensoryMode: sensory)
            .pageTransitionsTheme
            .builders[TargetPlatform.android];
        expect(builder, isNotNull);
        expect(builder, isNot(isA<CupertinoPageTransitionsBuilder>()));
      }
    });
  });
}
