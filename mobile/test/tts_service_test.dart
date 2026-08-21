import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/services/tts_service.dart';

void main() {
  test('queues utterances in order and resolves locales once', () async {
    final platform = FakeTtsPlatform(languages: const ['en-US', 'ur-PK']);
    final service = QueuedTtsService(platform: platform);

    await service.enqueue('first', const Locale('en'));
    await service.enqueue('second', const Locale('en'));
    await _waitFor(() => platform.spoken.length == 2);

    expect(platform.spoken, ['first', 'second']);
    expect(platform.languageCalls, ['en-US', 'en-US']);
    expect(platform.getLanguagesCalls, 2);
  });

  test(
    'speak stops current speech before starting the new utterance',
    () async {
      final platform = FakeTtsPlatform(languages: const ['en-US']);
      final service = QueuedTtsService(platform: platform);

      await service.speak('old', const Locale('en'));
      await _waitFor(() => platform.spoken.length == 1);
      await service.speak('new', const Locale('en'));
      await _waitFor(() => platform.spoken.length == 2);

      expect(platform.stopCalls, greaterThanOrEqualTo(1));
      expect(platform.spoken.last, 'new');
    },
  );

  test('reports unavailable language without throwing', () async {
    final platform = FakeTtsPlatform(languages: const ['en-US']);
    final service = QueuedTtsService(platform: platform);
    final states = <TtsState>[];
    final subscription = service.state.listen(states.add);

    await service.speak('السلام علیکم', const Locale('ur'));
    await _waitFor(() => states.contains(TtsState.unavailable));

    expect(platform.spoken, isEmpty);
    await subscription.cancel();
  });

  test('sensory mode lowers volume and speech rate', () async {
    final platform = FakeTtsPlatform(languages: const ['en-US']);
    final service = QueuedTtsService(platform: platform);

    await service.initialise();
    await service.setSensoryMode(true);

    expect(platform.lastRate, 0.38);
    expect(platform.lastVolume, 0.55);
  });
}

Future<void> _waitFor(bool Function() condition) async {
  for (var attempt = 0; attempt < 20 && !condition(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(condition(), isTrue);
}

class FakeTtsPlatform implements TtsPlatformClient {
  FakeTtsPlatform({required this.languages});

  final List<dynamic> languages;
  final List<String> spoken = [];
  final List<String> languageCalls = [];
  int stopCalls = 0;
  int getLanguagesCalls = 0;
  double? lastRate;
  double? lastVolume;

  @override
  Future<void> awaitSpeakCompletion(bool awaitCompletion) async {}

  @override
  Future<List<dynamic>> getLanguages() async {
    getLanguagesCalls++;
    return languages;
  }

  @override
  Future<dynamic> isLanguageAvailable(String language) async =>
      languages.contains(language);

  @override
  Future<dynamic> setLanguage(String language) async {
    languageCalls.add(language);
    return 1;
  }

  @override
  Future<dynamic> setSpeechRate(double rate) async {
    lastRate = rate;
    return 1;
  }

  @override
  Future<dynamic> setVolume(double volume) async {
    lastVolume = volume;
    return 1;
  }

  @override
  Future<dynamic> setPitch(double pitch) async => 1;

  @override
  Future<dynamic> speak(String text) async {
    spoken.add(text);
    return 1;
  }

  @override
  Future<dynamic> stop() async {
    stopCalls++;
    return 1;
  }
}
