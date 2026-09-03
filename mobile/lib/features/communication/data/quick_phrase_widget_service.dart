import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../domain/phrase_bank.dart';
import '../domain/sentence_realiser.dart';

/// Publishes urgent phrases to the Android home-screen widget.
///
/// **What this is for.** When a child needs the toilet, is in pain, or is
/// distressed, three taps to unlock, find the app, and open the board is
/// three taps too many. A home-screen button that speaks one phrase is a
/// meaningful difference in exactly the moments that matter most.
///
/// **What it deliberately does not do.** Only phrases the caregiver marked
/// urgent are published, and only their labels — no history, no card data,
/// no child name. A home-screen widget is visible to anyone holding the
/// device, including on a lock screen, so the less it carries the better.
///
/// **Verification status, stated plainly.** The Dart side here is complete
/// and unit-tested. The Android side needs a Kotlin `AppWidgetProvider`, a
/// layout, and a manifest receiver, and **none of it has run on a device** —
/// this machine has no Android SDK. Treat it as ready for device work, not
/// as working. See `android/app/src/main/res/xml/quick_phrase_widget.xml`.
class QuickPhraseWidgetService {
  const QuickPhraseWidgetService({
    this.maxPhrases = 4,
    this.appGroupId = 'com.example.autimate.widget',
  });

  /// A home-screen widget with more than a handful of buttons stops being
  /// faster than opening the app.
  final int maxPhrases;

  /// iOS app-group id. Android ignores it.
  final String appGroupId;

  static const String widgetName = 'QuickPhraseWidgetProvider';
  static const String androidWidgetName = 'QuickPhraseWidgetProvider';
  static const String iOSWidgetName = 'QuickPhraseWidget';

  bool get isSupported => Platform.isAndroid || Platform.isIOS;

  /// Chooses which phrases reach the home screen.
  ///
  /// Urgent first — that is the whole point of the widget — then whatever
  /// else fits. Pure, so the selection is testable without a platform.
  List<SavedPhrase> select(List<SavedPhrase> phrases) {
    final urgent = phrases.where((phrase) => phrase.urgent).toList();
    if (urgent.length >= maxPhrases) return urgent.take(maxPhrases).toList();
    final rest = phrases.where((phrase) => !phrase.urgent);
    return [...urgent, ...rest].take(maxPhrases).toList();
  }

  /// Pushes the current phrase set to the widget.
  ///
  /// Every failure is swallowed: a widget that will not update must never
  /// take down the app it belongs to.
  Future<bool> publish(
    List<SavedPhrase> phrases, {
    required AppLanguage language,
  }) async {
    if (!isSupported) return false;
    final selected = select(phrases);
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      await HomeWidget.saveWidgetData<int>('phrase_count', selected.length);
      for (var i = 0; i < maxPhrases; i++) {
        final phrase = i < selected.length ? selected[i] : null;
        await HomeWidget.saveWidgetData<String>(
          'phrase_${i}_label',
          phrase?.labelFor(language) ?? '',
        );
        await HomeWidget.saveWidgetData<String>(
          'phrase_${i}_id',
          phrase?.id ?? '',
        );
      }
      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
      );
      return true;
    } catch (error) {
      debugPrint('Quick-phrase widget update skipped: $error');
      return false;
    }
  }

  /// Clears the widget — used when the active child changes, so one child's
  /// phrases never sit on the home screen while another is using the app.
  Future<void> clear() async {
    if (!isSupported) return;
    try {
      await HomeWidget.saveWidgetData<int>('phrase_count', 0);
      for (var i = 0; i < maxPhrases; i++) {
        await HomeWidget.saveWidgetData<String>('phrase_${i}_label', '');
        await HomeWidget.saveWidgetData<String>('phrase_${i}_id', '');
      }
      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (error) {
      debugPrint('Quick-phrase widget clear skipped: $error');
    }
  }

  /// The phrase id a widget tap carried, or null.
  ///
  /// Parsed rather than trusted: the URI comes from outside the app.
  String? phraseIdFromLaunch(Uri? uri) {
    if (uri == null) return null;
    if (uri.scheme != 'autimate') return null;
    if (uri.host != 'phrase') return null;
    final id = uri.queryParameters['id'];
    return (id == null || id.isEmpty) ? null : id;
  }
}

/// Inert implementation for tests and desktop runs.
class UnavailableQuickPhraseWidgetService
    implements QuickPhraseWidgetService {
  const UnavailableQuickPhraseWidgetService();

  @override
  int get maxPhrases => 4;

  @override
  String get appGroupId => '';

  @override
  bool get isSupported => false;

  @override
  List<SavedPhrase> select(List<SavedPhrase> phrases) =>
      phrases.take(maxPhrases).toList();

  @override
  Future<bool> publish(
    List<SavedPhrase> phrases, {
    required AppLanguage language,
  }) async => false;

  @override
  Future<void> clear() async {}

  @override
  String? phraseIdFromLaunch(Uri? uri) => null;
}
