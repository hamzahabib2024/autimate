import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Depth, light, and surface treatment.
///
/// The research on this audience is consistent: calm palettes, muted colour,
/// stable layouts, and clutter-free surfaces. That rules out the usual
/// routes to "eye-catching" — saturated gradients, heavy drop shadows, glass
/// blur, neon glow — because every one of them raises visual load.
///
/// So depth here is built the way a good print designer builds it: with
/// *many very soft layers* rather than one hard one, and with light that
/// falls consistently from above. The result reads as crafted and tactile up
/// close while staying quiet from arm's length, which is the actual goal.
///
/// Every value is deliberately below the threshold where it becomes a
/// separate thing the eye has to process.
class AppDepth {
  const AppDepth._();

  /// Resting card. Two layers: a tight contact shadow and a wide ambient
  /// one. A single shadow at this softness looks like a smudge; two at
  /// different radii read as a real object sitting on a surface.
  static List<BoxShadow> card(
    BuildContext context, {
    bool sensoryMode = false,
  }) {
    if (sensoryMode) return const [];
    final ink = _ink(context);
    return [
      BoxShadow(
        color: ink.withValues(alpha: 0.045),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
      BoxShadow(
        color: ink.withValues(alpha: 0.055),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ];
  }

  /// A surface the child is touching. Lifts and softens rather than
  /// brightening — a colour change under the finger is hidden by the finger.
  static List<BoxShadow> lifted(
    BuildContext context, {
    bool sensoryMode = false,
  }) {
    if (sensoryMode) return const [];
    final ink = _ink(context);
    return [
      BoxShadow(
        color: ink.withValues(alpha: 0.06),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: ink.withValues(alpha: 0.09),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ];
  }

  /// Accent-tinted shadow for a coloured surface. A neutral grey shadow
  /// under a coloured card reads as dirty; borrowing the accent's hue keeps
  /// it clean without adding saturation to the page.
  static List<BoxShadow> tinted(
    Color accent, {
    bool sensoryMode = false,
  }) {
    if (sensoryMode) return const [];
    return [
      BoxShadow(
        color: accent.withValues(alpha: 0.10),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
      BoxShadow(
        color: accent.withValues(alpha: 0.14),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];
  }

  /// A barely-there vertical wash, as if lit from above.
  ///
  /// The stops are within a few percent of each other on purpose. It is not
  /// meant to be seen as a gradient; it is meant to stop a large flat fill
  /// from looking dead. Sensory mode returns a flat fill instead, because
  /// even this much variation is worth removing when the point is to reduce
  /// everything.
  static Gradient? sheen(
    Color base, {
    bool sensoryMode = false,
    double strength = 1.0,
  }) {
    if (sensoryMode) return null;
    final hsl = HSLColor.fromColor(base);
    final top = hsl
        .withLightness((hsl.lightness + 0.030 * strength).clamp(0.0, 1.0))
        .toColor();
    final bottom = hsl
        .withLightness((hsl.lightness - 0.018 * strength).clamp(0.0, 1.0))
        .toColor();
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [top, base, bottom],
      stops: const [0.0, 0.55, 1.0],
    );
  }

  /// A soft radial glow behind a focal element — the reward star, the
  /// splash mascot. Never animated as a pulse: a repeating brightness
  /// change is the exact pattern to avoid.
  static Gradient halo(Color accent) => RadialGradient(
    colors: [
      accent.withValues(alpha: 0.16),
      accent.withValues(alpha: 0.06),
      accent.withValues(alpha: 0.0),
    ],
    stops: const [0.0, 0.55, 1.0],
  );

  /// Hairline that replaces shadow in sensory mode, and sits under it
  /// otherwise. A border and a shadow together is what makes a surface feel
  /// drawn rather than floating.
  static BorderSide hairline(BuildContext context) =>
      BorderSide(color: context.palette.outline.withValues(alpha: 0.7));

  static Color _ink(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF000000)
          : const Color(0xFF1B2A28);
}
