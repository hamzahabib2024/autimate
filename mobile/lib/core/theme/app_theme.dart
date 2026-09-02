import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_motion.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Assembles the Material theme from the token files.
///
/// The `ColorScheme` still comes from `ColorScheme.fromSeed` because that is
/// what guarantees the Material contrast relationships; [AppPalette] rides
/// alongside as a theme extension carrying the meanings Material has no role
/// for (module identity, AAC word class). See `app_colors.dart`.
///
/// [light] keeps its original signature — `test/theme_contrast_test.dart`
/// iterates it — and [locale] is optional so existing call sites are
/// unaffected.
class AppTheme {
  static const Color seed = Color(0xFF0F766E);

  static ThemeData light({
    required bool sensoryMode,
    Locale locale = const Locale('en'),
  }) => _build(
    brightness: Brightness.light,
    sensoryMode: sensoryMode,
    locale: locale,
  );

  static ThemeData dark({
    required bool sensoryMode,
    Locale locale = const Locale('en'),
  }) => _build(
    brightness: Brightness.dark,
    sensoryMode: sensoryMode,
    locale: locale,
  );

  static ThemeData _build({
    required Brightness brightness,
    required bool sensoryMode,
    required Locale locale,
  }) {
    final isLight = brightness == Brightness.light;
    final palette = isLight
        ? AppPalette.light(sensoryMode: sensoryMode)
        : AppPalette.dark(sensoryMode: sensoryMode);

    // Sensory mode lowers the contrast ceiling rather than raising it:
    // maximum contrast is its own kind of sensory load.
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      contrastLevel: sensoryMode ? 0.25 : 0.5,
    ).copyWith(surface: palette.card);

    final text = AppTypography.caregiver(scheme.onSurface, locale: locale);
    final cardElevation = AppElevation.resolve(
      AppElevation.raised,
      sensoryMode: sensoryMode,
    );

    return ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: palette.canvas,
      canvasColor: palette.canvas,
      useMaterial3: true,
      textTheme: text,
      fontFamily: AppTypography.familyFor(locale),
      visualDensity: VisualDensity.standard,
      splashFactory: sensoryMode
          ? NoSplash.splashFactory
          : InkSparkle.splashFactory,
      extensions: [palette],

      // Sensory mode replaces the shared-axis slide with a plain fade.
      pageTransitionsTheme: sensoryMode
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            )
          : const PageTransitionsTheme(),

      appBarTheme: AppBarTheme(
        backgroundColor: palette.canvas,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: sensoryMode ? 0 : 2,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),

      cardTheme: CardThemeData(
        color: palette.card,
        elevation: cardElevation,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          // Flat surfaces still need an edge, so sensory mode swaps the
          // shadow for a hairline rather than losing the boundary entirely.
          side: sensoryMode
              ? BorderSide(color: palette.outline)
              : BorderSide.none,
        ),
      ),

      // Minimum touch targets are a theme guarantee, not a per-call-site
      // ConstrainedBox, so a new screen cannot ship a small target.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppTouch.caregiver),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppTouch.caregiver),
          textStyle: text.labelLarge,
          side: BorderSide(color: palette.outline, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, AppTouch.caregiver),
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: palette.sunken,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: palette.outline),
        labelStyle: text.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: AppElevation.resolve(
          AppElevation.floating,
          sensoryMode: sensoryMode,
        ),
        height: 76,
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      ),

      listTileTheme: ListTileThemeData(
        minVerticalPadding: AppSpacing.sm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),

      dividerTheme: DividerThemeData(color: palette.outline, space: 1),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: palette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: palette.sunken,
        circularTrackColor: palette.sunken,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}

/// Named motion durations re-exported so screens import one theme file.
typedef AppThemeMotion = AppMotion;
