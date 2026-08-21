import 'package:flutter/material.dart';

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
      home: child,
    );
