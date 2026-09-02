import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/theme/app_colors.dart';
import 'package:autimate/core/theme/app_theme.dart';
import 'package:autimate/features/communication/domain/aac_catalog.dart';
import 'package:autimate/features/emotion_recognition/domain/emotion_activity_engine.dart';
import 'package:autimate/shared/widgets/app_widgets.dart';

/// Pixel goldens for the design system.
///
/// The behavioural assertions in `design_system_test.dart` prove the tokens
/// are *correct* — contrast ratios, sensory-mode deltas, motion gating.
/// These prove the components still *look* the way they were signed off,
/// which is the failure mode a token test cannot catch: a padding change
/// that quietly halves the symbol on an AAC tile is valid Dart, passes every
/// other test, and ruins the screen for a child who reads pictures.
///
/// Regenerate deliberately, never reflexively:
///
///   flutter test --update-goldens test/golden_design_test.dart
///
/// and look at the diff before committing it. A golden that changes without
/// anyone intending it is the whole point of the file.
///
/// Note: goldens render with the test environment's fallback font, not the
/// bundled Lexend, so they capture layout and colour rather than type.
Widget _frame({
  required Widget child,
  required bool dark,
  required bool sensory,
  Size size = const Size(240, 240),
}) {
  final theme = dark
      ? AppTheme.dark(sensoryMode: sensory)
      : AppTheme.light(sensoryMode: sensory);
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    home: Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Padding(padding: const EdgeInsets.all(12), child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('EmotionFace', () {
    for (final emotion in EmotionLabel.values) {
      testWidgets('${emotion.name} reads distinctly', (tester) async {
        await tester.pumpWidget(
          _frame(
            dark: false,
            sensory: false,
            child: EmotionFace(emotion: emotion, size: 180, animate: false),
          ),
        );
        await expectLater(
          find.byType(EmotionFace),
          matchesGoldenFile('goldens/emotion_${emotion.name}.png'),
        );
      });
    }
  });

  group('SymbolTile', () {
    testWidgets('carries its word-class band and a dominant symbol',
        (tester) async {
      final card = cardById('apple')!;
      await tester.pumpWidget(
        _frame(
          dark: false,
          sensory: false,
          size: const Size(184, 190),
          child: SymbolTile(
            card: card,
            showUrdu: false,
            onTap: () {},
          ),
        ),
      );
      await expectLater(
        find.byType(SymbolTile),
        matchesGoldenFile('goldens/symbol_tile_noun.png'),
      );
    });

    testWidgets('a carrier phrase is coloured differently', (tester) async {
      await tester.pumpWidget(
        _frame(
          dark: false,
          sensory: false,
          size: const Size(184, 190),
          child: SymbolTile(
            card: cardById('i_want')!,
            showUrdu: false,
            onTap: () {},
          ),
        ),
      );
      await expectLater(
        find.byType(SymbolTile),
        matchesGoldenFile('goldens/symbol_tile_carrier.png'),
      );
    });

    testWidgets('sensory mode desaturates the band', (tester) async {
      await tester.pumpWidget(
        _frame(
          dark: false,
          sensory: true,
          size: const Size(184, 190),
          child: SymbolTile(
            card: cardById('apple')!,
            showUrdu: false,
            onTap: () {},
          ),
        ),
      );
      await expectLater(
        find.byType(SymbolTile),
        matchesGoldenFile('goldens/symbol_tile_sensory.png'),
      );
    });

    testWidgets('dark theme keeps the coding legible', (tester) async {
      await tester.pumpWidget(
        _frame(
          dark: true,
          sensory: false,
          size: const Size(184, 190),
          child: SymbolTile(
            card: cardById('apple')!,
            showUrdu: false,
            onTap: () {},
          ),
        ),
      );
      await expectLater(
        find.byType(SymbolTile),
        matchesGoldenFile('goldens/symbol_tile_dark.png'),
      );
    });
  });

  group('ProgressRing', () {
    for (final progress in [0.0, 0.45, 1.0]) {
      testWidgets('at ${(progress * 100).round()} percent', (tester) async {
        await tester.pumpWidget(
          _frame(
            dark: false,
            sensory: false,
            size: const Size(160, 160),
            child: ProgressRing(
              progress: progress,
              size: 140,
              strokeWidth: 12,
              animate: false,
            ),
          ),
        );
        await expectLater(
          find.byType(ProgressRing),
          matchesGoldenFile(
            'goldens/progress_ring_${(progress * 100).round()}.png',
          ),
        );
      });
    }
  });

  group('ChildActionCard', () {
    testWidgets('module accent carries the identity', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (_) => _frame(
            dark: false,
            sensory: false,
            size: const Size(190, 160),
            child: Builder(
              builder: (context) => ChildActionCard(
                title: 'Routine',
                subtitle: 'One step at a time',
                icon: Icons.today_outlined,
                accent: context.palette.routine,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(ChildActionCard),
        matchesGoldenFile('goldens/child_action_card.png'),
      );
    });
  });

  group('Mascot', () {
    testWidgets('rests without motion by default', (tester) async {
      await tester.pumpWidget(
        _frame(
          dark: false,
          sensory: false,
          size: const Size(160, 160),
          child: const Mascot(size: 140),
        ),
      );
      await expectLater(
        find.byType(Mascot),
        matchesGoldenFile('goldens/mascot.png'),
      );
    });
  });

  group('RewardStar', () {
    testWidgets('settles to its resting state', (tester) async {
      await tester.pumpWidget(
        _frame(
          dark: false,
          sensory: true, // sensory mode renders it without the scale-in
          size: const Size(120, 120),
          child: const RewardStar(sensoryMode: true, size: 80),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(
        find.byType(RewardStar),
        matchesGoldenFile('goldens/reward_star.png'),
      );
    });
  });
}
