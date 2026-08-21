import 'dart:async';

import 'package:flutter/material.dart';

import 'tts_service.dart';
import '../data/local_store.dart';
import '../../features/communication/domain/card_ranker.dart';
import '../../features/emotion_recognition/domain/emotion_activity_engine.dart';
import '../../features/progress/domain/progress_models.dart';
import '../../features/routines/domain/routine_models.dart';
import '../../features/routines/domain/routine_repository.dart';

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.supportLevel,
  });

  final String id;
  final String name;
  final String supportLevel;
}

abstract interface class AuthRepository {
  Future<bool> signIn(String email, String password);
  Future<void> signOut();
}

abstract interface class FeatureRepository {
  Future<List<ChildProfile>> loadChildren();
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<bool> signIn(String email, String password) async =>
      email.isNotEmpty && password.isNotEmpty;

  @override
  Future<void> signOut() async {}
}

class MockTtsService implements TtsService {
  @override
  Future<void> initialise() async {}

  @override
  Future<void> speak(String text, Locale locale) async {}

  @override
  Future<void> stop() async {}
}

class MockFeatureRepository implements FeatureRepository {
  @override
  Future<List<ChildProfile>> loadChildren() async => const [
    ChildProfile(id: 'demo-child', name: 'Ayaan', supportLevel: 'Beginner'),
  ];
}

class AppState extends ChangeNotifier {
  AppState(
    this.authRepository,
    this.ttsService, {
    ProgressRepository? progressRepository,
    RoutineRepository? routineRepository,
    KeyValueStore? settingsStore,
  }) : _children = const [
         ChildProfile(
           id: 'demo-child',
           name: 'Ayaan',
           supportLevel: 'Beginner',
         ),
       ],
       progressRepository =
           progressRepository ?? InMemoryProgressRepository(),
       routineRepository = routineRepository ?? _defaultRoutineRepository(),
       _settings = settingsStore;

  static RoutineRepository _defaultRoutineRepository() {
    // Overridden by composition root; keeps tests and previews working.
    return _NoopRoutineRepository();
  }

  final AuthRepository authRepository;
  final TtsService ttsService;
  final ProgressRepository progressRepository;
  final RoutineRepository routineRepository;
  final KeyValueStore? _settings;
  final List<ChildProfile> _children;
  Locale _locale = const Locale('en');
  bool _sensoryMode = false;
  bool _signedIn = true;
  int _stars = 12;

  Locale get locale => _locale;
  bool get sensoryMode => _sensoryMode;
  bool get signedIn => _signedIn;
  int get stars => _stars;
  List<ChildProfile> get children => List.unmodifiable(_children);

  /// Restores durable settings written by [persistSettings].
  Future<void> loadPersistedSettings() async {
    final store = _settings;
    if (store == null) return;
    final languageCode = await store.read(_keyLanguage);
    if (languageCode == 'ur') {
      _locale = const Locale('ur');
    } else if (languageCode == 'en') {
      _locale = const Locale('en');
    }
    final sensory = await store.read(_keySensoryMode);
    if (sensory != null) _sensoryMode = sensory == 'true';
    final stars = int.tryParse(await store.read(_keyStars) ?? '');
    if (stars != null && stars >= 0) _stars = stars;
    notifyListeners();
  }

  Future<void> persistSettings() async {
    final store = _settings;
    if (store == null) return;
    await store.write(_keyLanguage, _locale.languageCode);
    await store.write(_keySensoryMode, '$_sensoryMode');
    await store.write(_keyStars, '$_stars');
  }

  static const String _keyLanguage = 'autimate.settings.language';
  static const String _keySensoryMode = 'autimate.settings.sensoryMode';
  static const String _keyStars = 'autimate.settings.stars';

  void setLocale(Locale locale) {
    _locale = locale;
    unawaited(persistSettings());
    notifyListeners();
  }

  void toggleSensoryMode(bool value) {
    _sensoryMode = value;
    if (ttsService is QueuedTtsService) {
      (ttsService as QueuedTtsService).setSensoryMode(value);
    }
    unawaited(persistSettings());
    notifyListeners();
  }

  void awardStars(int amount) {
    _stars += amount;
    unawaited(persistSettings());
    notifyListeners();
  }

  Future<void> recordSession(SessionResult result) =>
      progressRepository.recordSession(result);

  Future<void> recordCardUsage(CardUsageEvent event) =>
      progressRepository.recordCardUsage(event);

  Future<void> signOut() async {
    await authRepository.signOut();
    _signedIn = false;
    notifyListeners();
  }
}

/// Fallback used only when no repository is supplied at the composition
/// root; keeps default constructors usable in widget previews.
class _NoopRoutineRepository implements RoutineRepository {
  @override
  Future<List<RoutineStep>> getSteps() async => const [];

  @override
  Future<Set<String>> completedStepIdsFor(String childId, DateTime day) async =>
      <String>{};

  @override
  Future<void> setStepCompleted(
    String childId,
    DateTime day,
    String stepId,
    bool completed,
  ) async {}
}
