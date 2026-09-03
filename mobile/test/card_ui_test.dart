import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/theme/app_theme.dart';
import 'package:autimate/features/communication/domain/aac_catalog.dart';
import 'package:autimate/features/communication/domain/literacy_support.dart';
import 'package:autimate/shared/widgets/app_widgets.dart';

import 'helpers/test_app.dart';

Widget _tile({
  String cardId = 'apple',
  bool isCustom = false,
  bool hasVoice = false,
  LiteracyLevel literacy = LiteracyLevel.off,
  bool sensory = false,
  VoidCallback? onLongPress,
  VoidCallback? onTap,
}) => MaterialApp(
  theme: AppTheme.light(sensoryMode: sensory),
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 200,
        height: 220,
        child: SymbolTile(
          card: cardById(cardId)!,
          showUrdu: false,
          literacy: literacy,
          sensoryMode: sensory,
          isCustom: isCustom,
          hasRecordedVoice: hasVoice,
          onLongPress: onLongPress,
          onTap: onTap ?? () {},
        ),
      ),
    ),
  ),
);

void main() {
  group('symbol tile affordances', () {
    testWidgets('a caregiver-made card says so', (tester) async {
      // Long-press to edit is invisible otherwise, and an affordance nobody
      // can see is an affordance nobody uses.
      await tester.pumpWidget(_tile());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.edit_outlined), findsNothing);

      await tester.pumpWidget(_tile(isCustom: true));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('a card with a recorded voice is marked', (tester) async {
      await tester.pumpWidget(_tile(hasVoice: true));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.mic), findsOneWidget,
          reason: 'a caregiver needs to see which cards still need recording');
    });

    testWidgets('both badges can appear together', (tester) async {
      await tester.pumpWidget(_tile(isCustom: true, hasVoice: true));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('a plain built-in card carries no badges', (tester) async {
      await tester.pumpWidget(_tile());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byIcon(Icons.mic), findsNothing);
    });

    testWidgets('tapping still speaks the card', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_tile(onTap: () => taps++));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SymbolTile));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('long-press reaches the editor for a custom card',
        (tester) async {
      var edits = 0;
      await tester.pumpWidget(
        _tile(isCustom: true, onLongPress: () => edits++),
      );
      await tester.pumpAndSettle();
      await tester.longPress(find.byType(SymbolTile));
      await tester.pumpAndSettle();
      expect(edits, 1);
    });

    testWidgets('renders at every literacy rung without overflowing',
        (tester) async {
      for (final level in LiteracyLevel.values) {
        await tester.pumpWidget(_tile(literacy: level));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: 'rung ${level.name} overflowed');
      }
    });

    testWidgets('renders in sensory mode and dark theme', (tester) async {
      await tester.pumpWidget(_tile(sensory: true, isCustom: true));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(sensoryMode: false),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 220,
                child: SymbolTile(
                  card: cardById('apple')!,
                  showUrdu: false,
                  hasRecordedVoice: true,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a very small cell', (tester) async {
      // A 2x2 grid on a small phone gives roughly this.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(sensoryMode: false),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 110,
                height: 130,
                child: SymbolTile(
                  card: cardById('apple')!,
                  showUrdu: false,
                  isCustom: true,
                  hasRecordedVoice: true,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('both labels are announced to a screen reader',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_tile());
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(RegExp('apple')),
        findsWidgets,
        reason: 'the tile is a button that names itself in both languages',
      );
      handle.dispose();
    });
  });

  group('word-class legend', () {
    testWidgets('starts collapsed and opens on tap', (tester) async {
      await tester.pumpWidget(testApp(const WordClassLegend()));
      await tester.pumpAndSettle();

      // On a child's own screen the legend would be noise, so it is shut
      // until an adult asks for it.
      expect(find.text('Things'), findsNothing);

      await tester.tap(find.text('What the colours mean'));
      await tester.pumpAndSettle();
      expect(find.text('Things'), findsOneWidget);
    });

    testWidgets('names every word class, never colour alone', (tester) async {
      await tester.pumpWidget(
        testApp(const WordClassLegend(initiallyExpanded: true)),
      );
      await tester.pumpAndSettle();
      for (final label in [
        'Starters',
        'People',
        'Doing words',
        'Describing words',
        'Things',
        'Needs',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    });
  });
}
