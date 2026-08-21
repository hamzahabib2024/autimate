import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/l10n/generated/app_localizations.dart';

void main() {
  test('English localizations expose the core child-facing strings', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(l10n.communicateTitle, 'Communicate');
    expect(l10n.sentenceHeader, 'Sentence');
    expect(l10n.coreWords, 'Core words');
    expect(l10n.starsEarned(3), '3 stars earned');
    expect(l10n.questionProgress(2, 5), 'Question 2 of 5');
  });

  test('Urdu localizations translate the core strings', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ur'));
    expect(l10n.communicateTitle, 'بات کریں');
    expect(l10n.navRoutine, 'روٹین');
    expect(l10n.starsEarned(3), '3 ستارے ملے');
  });

  test('both supported locales are declared', () {
    expect(AppLocalizations.supportedLocales, [
      const Locale('en'),
      const Locale('ur'),
    ]);
  });
}
