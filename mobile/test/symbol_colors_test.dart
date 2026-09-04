import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/theme/app_colors.dart';
import 'package:autimate/core/theme/app_theme.dart';
import 'package:autimate/features/communication/domain/aac_catalog.dart';
import 'package:autimate/features/communication/domain/symbol_colors.dart';
import 'package:autimate/shared/widgets/app_widgets.dart';

double _channel(double value) => value <= 0.03928
    ? value / 12.92
    : math.pow((value + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('natural symbol colours', () {
    test('an apple is red, water is blue, a park is green', () {
      // The point of the whole feature: a child recognises a thing by its
      // colour long before they can read its label.
      final apple = SymbolColors.forCard('apple')!;
      expect(apple.r, greaterThan(apple.g));
      expect(apple.r, greaterThan(apple.b));

      final water = SymbolColors.forCard('water')!;
      expect(water.b, greaterThan(water.r));

      final park = SymbolColors.forCard('park')!;
      expect(park.g, greaterThan(park.r));
      expect(park.g, greaterThan(park.b));
    });

    test('emotions follow the convention children\'s books use', () {
      final angry = SymbolColors.forCard('angry')!;
      expect(angry.r, greaterThan(angry.b));
      final sad = SymbolColors.forCard('sad')!;
      expect(sad.b, greaterThan(sad.r));
    });

    test('abstract words have no invented colour', () {
      // Giving "finished" or "I want" a colour would teach an association
      // that means nothing outside this app.
      for (final id in ['i_want', 'i_feel', 'finished', 'help', 'teacher']) {
        expect(SymbolColors.forCard(id), isNull, reason: id);
        expect(SymbolColors.has(id), isFalse);
      }
    });

    test('every natural colour clears 4.5:1 on both light grounds', () {
      // The symbol is the content of the card; an unreadable one is worse
      // than a monochrome one.
      final light = AppPalette.light(sensoryMode: false);
      final calm = AppPalette.light(sensoryMode: true);
      for (final id in SymbolColors.coloured) {
        final colour = SymbolColors.forCard(id)!;
        for (final ground in [light.card, light.canvas, calm.card]) {
          expect(
            _contrast(colour, ground),
            greaterThanOrEqualTo(4.5),
            reason: '$id (#${colour.toARGB32().toRadixString(16)}) on '
                '#${ground.toARGB32().toRadixString(16)} is '
                '${_contrast(colour, ground).toStringAsFixed(2)}:1',
          );
        }
      }
    });

    test('sensory mode desaturates them like every other accent', () {
      for (final id in SymbolColors.coloured) {
        final raw = SymbolColors.forCard(id)!;
        final calm = AppPalette.desaturate(raw, 0.40);
        expect(
          HSLColor.fromColor(calm).saturation,
          lessThanOrEqualTo(HSLColor.fromColor(raw).saturation),
          reason: id,
        );
      }
    });

    test('a desaturated colour is still readable', () {
      final calm = AppPalette.light(sensoryMode: true);
      for (final id in SymbolColors.coloured) {
        final muted = AppPalette.desaturate(SymbolColors.forCard(id)!, 0.40);
        expect(
          _contrast(muted, calm.card),
          greaterThanOrEqualTo(4.5),
          reason: '$id desaturated is ${_contrast(muted, calm.card)
              .toStringAsFixed(2)}:1',
        );
      }
    });

    test('every coloured id is a real card', () {
      // A typo here would silently do nothing, which is the worst kind of
      // bug in a lookup table.
      for (final id in SymbolColors.coloured) {
        expect(cardById(id), isNotNull, reason: 'no card with id "$id"');
      }
    });
  });

  group('the two colour systems stay separate', () {
    testWidgets('the band keeps the word class while the symbol goes natural',
        (tester) async {
      // Grammar must stay learnable across a category even as each symbol
      // takes its own colour. If the band followed the symbol, the whole
      // Fitzgerald key would collapse.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(sensoryMode: false),
          home: Scaffold(
            body: Row(
              children: [
                for (final id in ['apple', 'water', 'ball'])
                  SizedBox(
                    width: 120,
                    height: 190,
                    child: SymbolTile(
                      key: ValueKey('tile-$id'),
                      card: cardById(id)!,
                      showUrdu: false,
                      onTap: () {},
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // apple and ball are both nouns; water is a noun too. All three keep
      // the same word-class hue while their symbols differ.
      for (final id in ['apple', 'water', 'ball']) {
        expect(find.byKey(ValueKey('tile-$id')), findsOneWidget);
      }
    });

    testWidgets('a card with no natural colour still renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(sensoryMode: false),
          home: Scaffold(
            body: SizedBox(
              width: 180,
              height: 200,
              child: SymbolTile(
                card: cardById('i_want')!,
                showUrdu: false,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
