import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light({required bool sensoryMode}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F766E),
      brightness: Brightness.light,
      contrastLevel: sensoryMode ? 0.25 : 0.5,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: sensoryMode
          ? const Color(0xFFF2F5F2)
          : const Color(0xFFF7FAF9),
      useMaterial3: true,
      fontFamily: 'sans',
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: sensoryMode
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            )
          : const PageTransitionsTheme(),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      cardTheme: CardThemeData(
        elevation: sensoryMode ? 0 : 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
