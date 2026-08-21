import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/services/app_services.dart';

void main() {
  late InMemoryKeyValueStore store;
  late AppState appState;

  setUp(() {
    store = InMemoryKeyValueStore();
    appState = AppState(
      MockAuthRepository(),
      MockTtsService(),
      settingsStore: store,
    );
  });

  test('settings round-trip through the durable store', () async {
    appState.setLocale(const Locale('ur'));
    appState.toggleSensoryMode(true);
    appState.awardStars(5);

    final restored = AppState(
      MockAuthRepository(),
      MockTtsService(),
      settingsStore: store,
    );
    await restored.loadPersistedSettings();

    expect(restored.locale, const Locale('ur'));
    expect(restored.sensoryMode, isTrue);
    expect(restored.stars, 17);
  });

  test('defaults apply when nothing was persisted', () async {
    await appState.loadPersistedSettings();
    expect(appState.locale, const Locale('en'));
    expect(appState.sensoryMode, isFalse);
    expect(appState.stars, 12);
  });
}
