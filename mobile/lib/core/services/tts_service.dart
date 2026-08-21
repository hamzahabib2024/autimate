import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract interface class TtsService {
  Future<void> initialise();
  Future<void> speak(String text, Locale locale);
  Future<void> stop();
}

enum TtsState { idle, speaking, unavailable, error }

class VoiceAvailability {
  const VoiceAvailability({required this.locale, required this.available});

  final String? locale;
  final bool available;
}

abstract interface class TtsPlatformClient {
  Future<void> awaitSpeakCompletion(bool awaitCompletion);
  Future<List<dynamic>> getLanguages();
  Future<dynamic> isLanguageAvailable(String language);
  Future<dynamic> setLanguage(String language);
  Future<dynamic> setSpeechRate(double rate);
  Future<dynamic> setVolume(double volume);
  Future<dynamic> setPitch(double pitch);
  Future<dynamic> speak(String text);
  Future<dynamic> stop();
}

class FlutterTtsPlatformClient implements TtsPlatformClient {
  FlutterTtsPlatformClient([FlutterTts? engine])
    : _engine = engine ?? FlutterTts();

  final FlutterTts _engine;

  @override
  Future<void> awaitSpeakCompletion(bool awaitCompletion) =>
      _engine.awaitSpeakCompletion(awaitCompletion);

  @override
  Future<List<dynamic>> getLanguages() async =>
      (await _engine.getLanguages as List<dynamic>?) ?? const [];

  @override
  Future<dynamic> isLanguageAvailable(String language) =>
      _engine.isLanguageAvailable(language);

  @override
  Future<dynamic> setLanguage(String language) => _engine.setLanguage(language);

  @override
  Future<dynamic> setSpeechRate(double rate) => _engine.setSpeechRate(rate);

  @override
  Future<dynamic> setVolume(double volume) => _engine.setVolume(volume);

  @override
  Future<dynamic> setPitch(double pitch) => _engine.setPitch(pitch);

  @override
  Future<dynamic> speak(String text) => _engine.speak(text);

  @override
  Future<dynamic> stop() => _engine.stop();
}

class QueuedTtsService implements TtsService {
  QueuedTtsService({TtsPlatformClient? platform})
    : _platform = platform ?? FlutterTtsPlatformClient();

  final TtsPlatformClient _platform;
  final List<_Utterance> _queue = [];
  final StreamController<TtsState> _stateController =
      StreamController<TtsState>.broadcast();
  final Map<Locale, VoiceAvailability> _availability = {};
  bool _initialised = false;
  bool _draining = false;
  bool _sensoryMode = false;
  TtsState _state = TtsState.idle;

  Stream<TtsState> get state => _stateController.stream;
  TtsState get currentState => _state;
  Map<Locale, VoiceAvailability> get availability =>
      Map.unmodifiable(_availability);

  @override
  Future<void> initialise() async {
    if (_initialised) return;
    try {
      await _platform.awaitSpeakCompletion(true);
      await _resolveLocale(const Locale('en'));
      await _resolveLocale(const Locale('ur'));
      await _platform.setPitch(1.0);
      await _applyAudioSettings();
      _initialised = true;
      _setState(TtsState.idle);
    } catch (_) {
      _setState(TtsState.error);
    }
  }

  Future<VoiceAvailability> _resolveLocale(Locale locale) async {
    final cached = _availability[locale];
    if (cached != null) return cached;
    final candidates = locale.languageCode == 'ur'
        ? const ['ur-PK', 'ur-IN', 'ur']
        : const ['en-US', 'en-GB', 'en'];
    try {
      final reported = await _platform.getLanguages();
      for (final candidate in candidates) {
        final isReported = reported.any(
          (value) => value.toString().toLowerCase() == candidate.toLowerCase(),
        );
        final available =
            isReported ||
            _isAvailable(await _platform.isLanguageAvailable(candidate));
        if (available) {
          final result = VoiceAvailability(locale: candidate, available: true);
          _availability[locale] = result;
          return result;
        }
      }
    } catch (_) {
      // Availability is surfaced to the caller instead of crashing child UI.
    }
    final result = const VoiceAvailability(locale: null, available: false);
    _availability[locale] = result;
    return result;
  }

  bool _isAvailable(dynamic value) =>
      value == true || value == 1 || value.toString().toLowerCase() == 'true';

  @override
  Future<void> speak(String text, Locale locale) async {
    if (text.trim().isEmpty) return;
    await initialise();
    await stop();
    _queue.add(_Utterance(text: text, locale: locale));
    unawaited(_drain());
  }

  Future<void> enqueue(String text, Locale locale) async {
    if (text.trim().isEmpty) return;
    await initialise();
    _queue.add(_Utterance(text: text, locale: locale));
    unawaited(_drain());
  }

  @override
  Future<void> stop() async {
    _queue.clear();
    try {
      await _platform.stop();
    } catch (_) {
      _setState(TtsState.error);
    }
    if (_state == TtsState.speaking) _setState(TtsState.idle);
  }

  Future<void> setSensoryMode(bool enabled) async {
    _sensoryMode = enabled;
    if (_initialised) await _applyAudioSettings();
  }

  Future<void> _applyAudioSettings() async {
    await _platform.setSpeechRate(_sensoryMode ? 0.38 : 0.48);
    await _platform.setVolume(_sensoryMode ? 0.55 : 0.85);
  }

  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    try {
      while (_queue.isNotEmpty) {
        final utterance = _queue.removeAt(0);
        final availability = await _resolveLocale(utterance.locale);
        if (!availability.available || availability.locale == null) {
          _setState(TtsState.unavailable);
          continue;
        }
        try {
          await _platform.setLanguage(availability.locale!);
          await _applyAudioSettings();
          _setState(TtsState.speaking);
          await _platform.speak(utterance.text);
          _setState(TtsState.idle);
        } catch (_) {
          _setState(TtsState.error);
        }
      }
    } finally {
      _draining = false;
      if (_state == TtsState.speaking) _setState(TtsState.idle);
    }
  }

  void _setState(TtsState state) {
    _state = state;
    if (!_stateController.isClosed) _stateController.add(state);
  }

  Future<void> dispose() async {
    await stop();
    await _stateController.close();
  }
}

class _Utterance {
  const _Utterance({required this.text, required this.locale});

  final String text;
  final Locale locale;
}
