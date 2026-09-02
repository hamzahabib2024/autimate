/// Layout constants for the design system.
///
/// Everything spatial in the app resolves through these so spacing stays
/// rhythmic and touch targets stay honest. Numbers are dp.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
}

/// Corner radii. Child-facing surfaces use the larger end of the scale;
/// rounded geometry reads as softer and less clinical.
class AppRadius {
  const AppRadius._();

  static const double sm = 12;
  static const double md = 20;

  /// Child-tier cards and symbol tiles.
  static const double lg = 28;

  /// Fully rounded (pills, avatars).
  static const double pill = 999;
}

/// Minimum interactive sizes.
///
/// These are theme guarantees rather than per-call-site `ConstrainedBox`
/// wrappers, so a new screen cannot accidentally ship a small target.
class AppTouch {
  const AppTouch._();

  /// Anything a child taps.
  static const double child = 64;

  /// Caregiver-tier controls, still comfortably above the 48 dp floor.
  static const double caregiver = 56;
}

/// Elevation steps. Sensory mode flattens every surface to zero and
/// substitutes a hairline outline, so hierarchy survives without shadow.
class AppElevation {
  const AppElevation._();

  static const double flat = 0;
  static const double raised = 1;
  static const double floating = 3;

  static double resolve(double value, {required bool sensoryMode}) =>
      sensoryMode ? flat : value;
}
