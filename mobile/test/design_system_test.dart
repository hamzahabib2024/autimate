import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/theme/app_colors.dart';
import 'package:autimate/core/theme/app_motion.dart';
import 'package:autimate/core/theme/app_spacing.dart';
import 'package:autimate/core/theme/app_theme.dart';
import 'package:autimate/features/emotion_recognition/domain/emotion_activity_engine.dart';
import 'package:autimate/shared/widgets/app_widgets.dart';

double _channel(double value) => value <= 0.03928
    ? value / 12.92
    : math.pow((value + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color color) =>
    0.2126 * _channel(color.r) +
    0.7152 * _channel(color.g) +
    0.0722 * _channel(color.b);

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('semantic palette clears WCAG AA', () {
    // Module accents and word-class colours are UI components rather than
    // body copy, so the bar is 3:1 — but they are also drawn as icon fills
    // and label text on card grounds, so this asserts the stricter 4.5:1.
    for (final brightness in Brightness.values) {
      for (final sensoryMode in [false, true]) {
        test('$brightness sensory=$sensoryMode accents on card', () {
          final palette = brightness == Brightness.light
              ? AppPalette.light(sensoryMode: sensoryMode)
              : AppPalette.dark(sensoryMode: sensoryMode);

          for (final accent in [
            ...palette.moduleAccents,
            ...palette.wordClasses,
            palette.success,
            palette.attention,
          ]) {
            for (final ground in [palette.card, palette.canvas]) {
              expect(
                _contrast(accent, ground),
                greaterThanOrEqualTo(4.5),
                reason:
                    '#${accent.toARGB32().toRadixString(16)} on '
                    '#${ground.toARGB32().toRadixString(16)} is '
                    '${_contrast(accent, ground).toStringAsFixed(2)}:1',
              );
            }
          }
        });

        test('$brightness sensory=$sensoryMode tinted wells stay readable',
            () {
          final theme = brightness == Brightness.light
              ? AppTheme.light(sensoryMode: sensoryMode)
              : AppTheme.dark(sensoryMode: sensoryMode);
          final palette = theme.extension<AppPalette>()!;
          // Accent-tinted containers carry body copy on the home tiles.
          for (final accent in palette.moduleAccents) {
            expect(
              _contrast(
                theme.colorScheme.onSurface,
                palette.accentTint(accent, 0.86),
              ),
              greaterThanOrEqualTo(4.5),
            );
          }
        });
      }
    }
  });

  test('both themes expose the palette extension', () {
    for (final sensoryMode in [false, true]) {
      expect(
        AppTheme.light(sensoryMode: sensoryMode).extension<AppPalette>(),
        isNotNull,
      );
      expect(
        AppTheme.dark(sensoryMode: sensoryMode).extension<AppPalette>(),
        isNotNull,
      );
    }
  });

  test('sensory mode measurably desaturates every accent', () {
    final normal = AppPalette.light(sensoryMode: false);
    final calm = AppPalette.light(sensoryMode: true);
    for (var i = 0; i < normal.moduleAccents.length; i++) {
      final before = HSLColor.fromColor(normal.moduleAccents[i]).saturation;
      final after = HSLColor.fromColor(calm.moduleAccents[i]).saturation;
      expect(after, lessThan(before));
    }
  });

  test('sensory mode flattens elevation', () {
    expect(
      AppTheme.light(sensoryMode: true).cardTheme.elevation,
      AppElevation.flat,
    );
    expect(
      AppTheme.light(sensoryMode: false).cardTheme.elevation,
      greaterThan(0),
    );
    // A flat card still needs an edge, so the outline replaces the shadow.
    expect(
      (AppTheme.light(sensoryMode: true).cardTheme.shape
              as RoundedRectangleBorder)
          .side
          .style,
      BorderStyle.solid,
    );
  });

  test('theme guarantees a caregiver-sized minimum touch target', () {
    final style = AppTheme.light(sensoryMode: false).filledButtonTheme.style;
    expect(
      style?.minimumSize?.resolve({})?.height,
      greaterThanOrEqualTo(AppTouch.caregiver),
    );
  });

  group('AppMotion honours both reduced-motion signals', () {
    testWidgets('sensory mode collapses transform motion', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(
        AppMotion.resolve(ctx, sensoryMode: true),
        Duration.zero,
      );
      expect(
        AppMotion.resolve(ctx, sensoryMode: false),
        AppMotion.base,
      );
      // A cross-fade may survive so a state change never reads as a cut.
      expect(
        AppMotion.resolve(ctx, sensoryMode: true, keepFade: true),
        isNot(Duration.zero),
      );
    });

    testWidgets('the OS disableAnimations setting also suppresses motion',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(AppMotion.resolve(ctx, sensoryMode: false), Duration.zero);
      expect(AppMotion.reduced(ctx, sensoryMode: false), isTrue);
    });
  });

  group('EmotionFace', () {
    test('every target emotion has a distinct expression', () {
      expect(emotionExpressions.length, EmotionLabel.values.length);
      for (final label in EmotionLabel.values) {
        expect(emotionExpressions[label], isNotNull);
      }
      final unique = emotionExpressions.values.toSet();
      expect(unique.length, EmotionLabel.values.length);
    });

    test('expressions read the way the labels claim', () {
      final happy = emotionExpressions[EmotionLabel.happy]!;
      final sad = emotionExpressions[EmotionLabel.sad]!;
      final angry = emotionExpressions[EmotionLabel.angry]!;
      final surprised = emotionExpressions[EmotionLabel.surprised]!;
      final neutral = emotionExpressions[EmotionLabel.neutral]!;

      expect(happy.mouthCurve, greaterThan(0));
      expect(sad.mouthCurve, lessThan(0));
      // Anger pulls the inner brows down; sadness lifts them.
      expect(angry.browAngle, greaterThan(0));
      expect(sad.browAngle, lessThan(0));
      expect(surprised.eyeOpenness, greaterThan(neutral.eyeOpenness));
      expect(surprised.mouthOpenness, greaterThan(happy.mouthOpenness));
      expect(neutral.mouthCurve, 0);
    });

    test('expressions tween rather than cut', () {
      final mid = FaceExpression.lerp(
        emotionExpressions[EmotionLabel.sad]!,
        emotionExpressions[EmotionLabel.happy]!,
        0.5,
      );
      expect(mid.mouthCurve, closeTo(0.05, 0.001));
    });

    testWidgets('renders every emotion without overflowing', (tester) async {
      for (final label in EmotionLabel.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(sensoryMode: false),
            home: Scaffold(
              body: Center(
                child: EmotionFace(emotion: label, size: 120, animate: false),
              ),
            ),
          ),
        );
        expect(find.byType(EmotionFace), findsOneWidget);
      }
    });
  });

  testWidgets('ProgressRing clamps out-of-range progress', (tester) async {
    for (final value in [-1.0, 0.5, 2.0]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(sensoryMode: false),
          home: Scaffold(
            body: ProgressRing(progress: value, animate: false),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });

  test('English and Urdu ARB files declare identical keys', () {
    Set<String> keysOf(String path) {
      final json = jsonDecode(File(path).readAsStringSync())
          as Map<String, dynamic>;
      return json.keys.where((key) => !key.startsWith('@')).toSet();
    }

    final en = keysOf('lib/l10n/app_en.arb');
    final ur = keysOf('lib/l10n/app_ur.arb');
    expect(ur.difference(en), isEmpty, reason: 'keys only in Urdu');
    expect(en.difference(ur), isEmpty, reason: 'keys missing from Urdu');
    expect(en, isNotEmpty);
  });

  test('no Urdu string was left as its English placeholder', () {
    Map<String, dynamic> load(String path) =>
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

    final en = load('lib/l10n/app_en.arb');
    final ur = load('lib/l10n/app_ur.arb');
    // A handful of strings are legitimately identical across languages
    // (proper nouns, the app name); everything else must differ.
    const sharedByDesign = {'languageEnglish', 'languageUrdu'};

    final untranslated = <String>[];
    for (final entry in en.entries) {
      if (entry.key.startsWith('@')) continue;
      if (sharedByDesign.contains(entry.key)) continue;
      final urdu = ur[entry.key];
      if (urdu is String && urdu == entry.value) untranslated.add(entry.key);
    }
    expect(untranslated, isEmpty);
  });
}
