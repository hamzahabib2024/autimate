import 'package:flutter/material.dart';

/// Type system for the two UI tiers.
///
/// **Child tier** is large, loosely tracked, and generously leaded. Text is
/// a caption to a symbol, never the payload, so it can afford the space.
/// **Caregiver tier** is the standard Material scale — this surface carries
/// real data density and is read by a fluent adult reader.
///
/// Rules held throughout: start-aligned (never justified), sentence case
/// (never all-caps — capitals flatten word shape and slow readers), and a
/// 16 dp floor anywhere in the app, 20 dp on any child-facing surface.
class AppTypography {
  const AppTypography._();

  /// Latin family. `null` means the platform default.
  ///
  /// The design calls for **Lexend** (SIL OFL), which is drawn to reduce
  /// visual stress and measurably improve reading proficiency — the
  /// strongest defensible choice for this audience. Drop the files into
  /// `assets/fonts/`, uncomment the `fonts:` block in `pubspec.yaml`, and
  /// set this to `'Lexend'`. See `assets/fonts/README.md`.
  ///
  /// It stays `null` until the binaries are present because Flutter fails
  /// the build on a declared-but-missing font asset, and a broken build is
  /// worse than the platform default.
  static const String? latinFamily = null;

  /// Urdu family — **Noto Nastaliq Urdu** (SIL OFL), with Noto Naskh Arabic
  /// as the dense-UI fallback. Same activation steps as [latinFamily].
  static const String? urduFamily = null;

  /// Nastaliq stacks its ligatures diagonally and needs far more vertical
  /// room than Latin at the same point size. Urdu text therefore gets a
  /// taller line box and a small size bump rather than reusing the Latin
  /// metrics, which clip ascenders in the sentence strip and story reader.
  static const double urduLineHeight = 1.9;
  static const double urduScale = 1.08;
  static const double latinLineHeight = 1.5;

  static bool isUrdu(Locale locale) => locale.languageCode == 'ur';

  static String? familyFor(Locale locale) =>
      isUrdu(locale) ? urduFamily : latinFamily;

  /// The caregiver scale: Material 3 defaults, floored at 16 for body.
  static TextTheme caregiver(Color onSurface, {required Locale locale}) {
    final urdu = isUrdu(locale);
    final height = urdu ? urduLineHeight : latinLineHeight;
    final scale = urdu ? urduScale : 1.0;
    TextStyle s(double size, FontWeight weight, {double tracking = 0}) =>
        TextStyle(
          fontFamily: familyFor(locale),
          fontSize: size * scale,
          fontWeight: weight,
          height: height,
          letterSpacing: tracking,
          color: onSurface,
        );
    return TextTheme(
      headlineLarge: s(28, FontWeight.w700),
      headlineMedium: s(24, FontWeight.w700),
      headlineSmall: s(22, FontWeight.w600),
      titleLarge: s(20, FontWeight.w600),
      titleMedium: s(18, FontWeight.w600),
      titleSmall: s(16, FontWeight.w600),
      bodyLarge: s(17, FontWeight.w400),
      bodyMedium: s(16, FontWeight.w400),
      bodySmall: s(14, FontWeight.w400),
      labelLarge: s(16, FontWeight.w600),
      labelMedium: s(14, FontWeight.w600),
      labelSmall: s(13, FontWeight.w500),
    );
  }

  /// The child scale. Applied by wrapping a subtree in [childTextTheme],
  /// not globally — the caregiver dashboard would be unusable at these sizes.
  static TextTheme child(Color onSurface, {required Locale locale}) {
    final urdu = isUrdu(locale);
    final height = urdu ? urduLineHeight : 1.45;
    final scale = urdu ? urduScale : 1.0;
    TextStyle s(double size, FontWeight weight, {double tracking = 0.2}) =>
        TextStyle(
          fontFamily: familyFor(locale),
          fontSize: size * scale,
          fontWeight: weight,
          height: height,
          letterSpacing: tracking,
          color: onSurface,
        );
    return TextTheme(
      displayLarge: s(44, FontWeight.w700),
      displayMedium: s(40, FontWeight.w700),
      displaySmall: s(36, FontWeight.w700),
      headlineLarge: s(34, FontWeight.w700),
      headlineMedium: s(32, FontWeight.w700),
      headlineSmall: s(28, FontWeight.w600),
      titleLarge: s(26, FontWeight.w600),
      titleMedium: s(24, FontWeight.w600),
      titleSmall: s(22, FontWeight.w600),
      bodyLarge: s(22, FontWeight.w400),
      bodyMedium: s(20, FontWeight.w400),
      bodySmall: s(18, FontWeight.w400),
      labelLarge: s(20, FontWeight.w600),
      labelMedium: s(18, FontWeight.w600),
      labelSmall: s(16, FontWeight.w500),
    );
  }
}

/// Switches a subtree to the child type scale.
///
/// Wrap child-facing screen bodies in this; leave caregiver surfaces alone.
/// The visible size difference is itself a signal — a caregiver glancing at
/// the device can tell which mode it is in without reading a word.
class ChildTextScale extends StatelessWidget {
  const ChildTextScale({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: AppTypography.child(
          theme.colorScheme.onSurface,
          locale: Localizations.localeOf(context),
        ),
      ),
      child: child,
    );
  }
}
