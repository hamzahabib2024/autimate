import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/theme/app_theme.dart';

double _channel(double value) => value <= 0.03928
    ? value / 12.92
    : math.pow((value + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color color) =>
    0.2126 * _channel(color.r) +
    0.7152 * _channel(color.g) +
    0.0722 * _channel(color.b);

/// WCAG 2.1 contrast ratio between two colors.
double contrastRatio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  // WCAG AA: 4.5:1 for normal text, 3:1 for large text/UI components.
  void expectAa(Color foreground, Color background,
      {bool largeText = false}) {
    final ratio = contrastRatio(foreground, background);
    expect(
      ratio,
      greaterThanOrEqualTo(largeText ? 3.0 : 4.5),
      reason:
          '#${foreground.toARGB32().toRadixString(16)} on '
          '#${background.toARGB32().toRadixString(16)} has ratio '
          '${ratio.toStringAsFixed(2)}',
    );
  }

  group('theme meets WCAG AA contrast', () {
    for (final sensoryMode in [false, true]) {
      test('sensoryMode=$sensoryMode core text pairs', () {
        final theme = AppTheme.light(sensoryMode: sensoryMode);
        final scheme = theme.colorScheme;

        expectAa(scheme.onSurface, scheme.surface);
        expectAa(scheme.onSurface, theme.scaffoldBackgroundColor);
        expectAa(scheme.onPrimary, scheme.primary);
        expectAa(scheme.onPrimaryContainer, scheme.primaryContainer);
        expectAa(scheme.onSecondaryContainer, scheme.secondaryContainer);

        // Progress indicators and icons are UI components: 3:1 minimum.
        expectAa(scheme.primary, scheme.surface, largeText: true);
      });
    }
  });

  test('contrastRatio sanity checks', () {
    expect(contrastRatio(const Color(0xFFFFFFFF), const Color(0xFF000000)),
        closeTo(21, 0.1));
    expect(contrastRatio(const Color(0xFF777777), const Color(0xFF777777)),
        closeTo(1, 0.001));
  });
}
