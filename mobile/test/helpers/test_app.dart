import 'package:flutter/material.dart';

import 'package:autimate/core/theme/app_typography.dart';
import 'package:autimate/l10n/generated/app_localizations.dart';

/// Pumps [child] inside a MaterialApp wired for English by default.
///
/// Pass [locale] to exercise the Urdu/RTL surface.
Widget testApp(
  Widget child, {
  Locale locale = const Locale('en'),
}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      // Mirrors main.dart, so a widget test sees the same text scaling the
      // real app applies rather than an uncapped one.
      builder: (context, built) =>
          AppTypography.clampTextScale(child: built ?? const SizedBox()),
      home: child,
    );
