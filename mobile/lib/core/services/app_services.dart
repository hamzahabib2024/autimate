import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/material.dart';

import 'connectivity_service.dart';
import 'tts_service.dart';
import '../data/local_store.dart';
import '../../features/communication/domain/card_ranker.dart';
import '../../features/ai/domain/ai_contracts.dart';
import '../../features/emotion_recognition/domain/emotion_activity_engine.dart';
import '../../features/learning/domain/interest_repository.dart';
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'supportLevel': supportLevel,
  };

  static ChildProfile fromJson(Map<String, dynamic> json) => ChildProfile(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    supportLevel: json['supportLevel'] as String? ?? 'Beginner',
  );
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

/// Caregiver-controlled adaptive-support preference for one child.
class SupportPreference {
  const SupportPreference({this.level, this.locked = false});

  final SupportLevel? level;
  final bool locked;

  Map<String, dynamic> toJson() => {
    'level': level?.name,
    'locked': locked,
  };

  static SupportPreference fromJson(Map<String, dynamic> json) =>
      SupportPreference(
        level: SupportLevel.values.where(
          (level) => level.name == json['level'],
        ).firstOrNull,
        locked: json['locked'] as bool? ?? false,
      );
}

class AppState extends ChangeNotifier {
  AppState(
    this.authRepository,
    this.ttsService, {
    ProgressRepository? progressRepository,
    RoutineRepository? routineRepository,
    InterestRepository? interestRepository,
    AmbientSoundService? ambientSoundService,
    KeyValueStore? settingsStore,
    ConnectivityService? connectivityService,
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
        interestRepository =
            interestRepository ?? _NoopInterestRepository(),
        ambientSoundService =
            ambientSoundService ?? SilentAmbientSoundService(),
        _settings = settingsStore,
        _connectivity = connectivityService;

  static RoutineRepository _defaultRoutineRepository() {
    // Overridden by composition root; keeps tests and previews working.
    return _NoopRoutineRepository();
  }

  final AuthRepository authRepository;
  final TtsService ttsService;
  final ProgressRepository progressRepository;
  final RoutineRepository routineRepository;
  final InterestRepository interestRepository;

  /// Gentle-sound boundary for the calm screen; silent by default until an
  /// OS-audio adapter is composed in on a real device.
  final AmbientSoundService ambientSoundService;
  final KeyValueStore? _settings;
  final ConnectivityService? _connectivity;
  List<ChildProfile> _children;
  String _selectedChildId = 'demo-child';
  Locale _locale = const Locale('en');
  bool _sensoryMode = false;
  bool _signedIn = true;
  bool _childMode = false;
  bool _onboarded = false;
  bool _offline = false;
  int _stars = 12;

  /// Lead time in minutes for transition countdown warnings.
  int _leadMinutes = 5;

  /// Per-child caregiver support preferences (override level and lock).
  final Map<String, SupportPreference> _supportPrefs = {};
  StreamSubscription<bool>? _connectivitySubscription;

  Locale get locale => _locale;
  bool get sensoryMode => _sensoryMode;
  bool get signedIn => _signedIn;
  bool get childMode => _childMode;
  bool get onboarded => _onboarded;
  bool get offline => _offline;
  bool get hasParentPin => _parentPinHash != null;
  int get stars => _stars;

  /// Transition-warning lead time in minutes (0 disables countdowns).
  int get transitionLeadMinutes => _leadMinutes;

  void setTransitionLeadMinutes(int minutes) {
    if (minutes == _leadMinutes || minutes < 0 || minutes > 60) return;
    _leadMinutes = minutes;
    unawaited(persistSettings());
    notifyListeners();
  }

  /// Caregiver-locked adaptive level for [childId]; null means the rules
  /// (and the profile's base level) decide.
  SupportLevel? supportOverrideFor(String childId) =>
      _supportPrefs[childId]?.level;

  bool isSupportLockedFor(String childId) =>
      _supportPrefs[childId]?.locked ?? false;

  /// The level a new session should start from: the caregiver override when
  /// present, otherwise the profile's assessed base level.
  SupportLevel effectiveSupportFor(String childId) {
    final override = supportOverrideFor(childId);
    if (override != null) return override;
    final child = children.where((child) => child.id == childId).firstOrNull;
    return switch (child?.supportLevel) {
      'Intermediate' => SupportLevel.intermediate,
      'Advanced' => SupportLevel.advanced,
      _ => SupportLevel.beginner,
    };
  }

  /// Persists the caregiver's picker choice. An unlocked null override
  /// returns the child fully to rule-based adaptation.
  void setSupportPreference({
    required String childId,
    required bool locked,
    SupportLevel? level,
  }) {
    if (!locked && level == null) {
      if (_supportPrefs.remove(childId) == null &&
          !isSupportLockedFor(childId)) {
        return;
      }
      unawaited(persistSettings());
      notifyListeners();
      return;
    }
    _supportPrefs[childId] = SupportPreference(level: level, locked: locked);
    unawaited(persistSettings());
    notifyListeners();
  }

  String? _parentPinHash;

  /// The child whose data every screen currently shows.
  ChildProfile get selectedChild => _children.firstWhere(
    (child) => child.id == _selectedChildId,
    orElse: () => _children.first,
  );

  void selectChild(String id) {
    if (!_children.any((child) => child.id == id)) return;
    _selectedChildId = id;
    unawaited(persistSettings());
    notifyListeners();
  }

  ChildProfile addChild({required String name, required String supportLevel}) {
    final child = ChildProfile(
      id: 'child-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      supportLevel: supportLevel,
    );
    _children = [..._children, child];
    _selectedChildId = child.id;
    unawaited(persistSettings());
    notifyListeners();
    return child;
  }

  /// Edits an existing profile in place; unknown ids are ignored so stale
  /// dialogs cannot resurrect deleted children.
  void updateChild({
    required String id,
    required String name,
    required String supportLevel,
  }) {
    if (!_children.any((child) => child.id == id)) return;
    _children = [
      for (final child in _children)
        if (child.id == id)
          ChildProfile(id: child.id, name: name, supportLevel: supportLevel)
        else
          child,
    ];
    unawaited(persistSettings());
    notifyListeners();
  }

  /// Sets up the first-run profile and enters the main app.
  Future<void> completeOnboarding({
    required String childName,
    required String supportLevel,
    required Locale locale,
    required String parentPin,
  }) async {
    _locale = locale;
    _children = [
      ChildProfile(
        id: 'demo-child',
        name: childName,
        supportLevel: supportLevel,
      ),
    ];
    _selectedChildId = 'demo-child';
    await setParentPin(parentPin);
    _onboarded = true;
    await persistSettings();
    notifyListeners();
  }

  Future<void> setParentPin(String pin) async {
    _parentPinHash = _hashPin(pin);
    await persistSettings();
    notifyListeners();
  }

  bool verifyParentPin(String pin) => _hashPin(pin) == _parentPinHash;

  static String _hashPin(String pin) =>
      crypto.sha256.convert(utf8.encode('autimate-parent-lock:$pin')).toString();

  void setChildMode(bool enabled) {
    _childMode = enabled;
    unawaited(persistSettings());
    notifyListeners();
  }

  /// Drives the offline banner until a platform adapter reports real state.
  void setOffline(bool offline) {
    if (_offline == offline) return;
    _offline = offline;
    notifyListeners();
  }

  void startListeningToConnectivity() {
    final service = _connectivity;
    if (service == null || _connectivitySubscription != null) return;
    _connectivitySubscription = service.onChanged().listen(
      (online) => setOffline(!online),
    );
    service.isOnline().then((online) => setOffline(!online));
  }
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
    final childMode = await store.read(_keyChildMode);
    if (childMode != null) _childMode = childMode == 'true';
    final onboarded = await store.read(_keyOnboarded);
    if (onboarded != null) _onboarded = onboarded == 'true';
    final lead = int.tryParse(await store.read(_keyLeadMinutes) ?? '');
    if (lead != null && lead >= 0 && lead <= 60) _leadMinutes = lead;
    final supportJson = await store.read(_keySupportPrefs);
    if (supportJson != null) {
      try {
        final decoded = jsonDecode(supportJson) as Map<String, dynamic>;
        _supportPrefs
          ..clear()
          ..addAll(
            decoded.map(
              (childId, value) => MapEntry(
                childId,
                SupportPreference.fromJson(value as Map<String, dynamic>),
              ),
            ),
          );
      } on FormatException {
        // Corrupt payload: fall back to rule-based adaptation.
      }
    }
    _parentPinHash = await store.read(_keyParentPinHash);
    final childrenJson = await store.read(_keyChildren);
    if (childrenJson != null) {
      try {
        final decoded = jsonDecode(childrenJson) as List<dynamic>;
        final stored = decoded
            .whereType<Map<String, dynamic>>()
            .map(ChildProfile.fromJson)
            .where((child) => child.id.isNotEmpty && child.name.isNotEmpty)
            .toList();
        if (stored.isNotEmpty) {
          _children = stored;
          final selected = await store.read(_keySelectedChild);
          if (selected != null &&
              stored.any((child) => child.id == selected)) {
            _selectedChildId = selected;
          } else {
            _selectedChildId = stored.first.id;
          }
        }
      } on FormatException {
        // Corrupt payload: keep the built-in demo profile.
      }
    }
    notifyListeners();
  }

  Future<void> persistSettings() async {
    final store = _settings;
    if (store == null) return;
    await store.write(_keyLanguage, _locale.languageCode);
    await store.write(_keySensoryMode, '$_sensoryMode');
    await store.write(_keyStars, '$_stars');
    await store.write(_keyChildMode, '$_childMode');
    await store.write(_keyOnboarded, '$_onboarded');
    await store.write(_keyLeadMinutes, '$_leadMinutes');
    await store.write(
      _keySupportPrefs,
      jsonEncode(
        _supportPrefs.map(
          (childId, pref) => MapEntry(childId, pref.toJson()),
        ),
      ),
    );
    final pinHash = _parentPinHash;
    if (pinHash == null) {
      await store.remove(_keyParentPinHash);
    } else {
      await store.write(_keyParentPinHash, pinHash);
    }
    await store.write(
      _keyChildren,
      jsonEncode(_children.map((child) => child.toJson()).toList()),
    );
    await store.write(_keySelectedChild, _selectedChildId);
  }

  static const String _keyLanguage = 'autimate.settings.language';
  static const String _keySensoryMode = 'autimate.settings.sensoryMode';
  static const String _keyStars = 'autimate.settings.stars';
  static const String _keyChildMode = 'autimate.settings.childMode';
  static const String _keyOnboarded = 'autimate.settings.onboarded';
  static const String _keyLeadMinutes = 'autimate.routine.leadMinutes';
  static const String _keySupportPrefs = 'autimate.support.v1';
  static const String _keyParentPinHash = 'autimate.settings.parentPinHash';
  static const String _keyChildren = 'autimate.children';
  static const String _keySelectedChild = 'autimate.selectedChild';

  @override
  void dispose() {
    unawaited(_connectivitySubscription?.cancel());
    super.dispose();
  }

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
class _NoopInterestRepository implements InterestRepository {
  @override
  Future<Set<String>> interestsFor(String childId) async => <String>{};

  @override
  Future<void> setInterests(String childId, Set<String> ids) async {}
}

class _NoopRoutineRepository implements RoutineRepository {
  @override
  Future<List<RoutineStep>> getSteps() async => const [];

  @override
  Future<void> saveSteps(List<RoutineStep> steps) async {}

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

  @override
  Future<FlexibilityChange?> flexibilityChangeFor(
    String childId,
    DateTime day,
  ) async =>
      null;

  @override
  Future<void> setFlexibilityChange(
    String childId,
    DateTime day,
    FlexibilityChange? change,
  ) async {}
}
