import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/material.dart';

import 'connectivity_service.dart';
import 'tts_service.dart';
import '../data/local_store.dart';
import '../../features/communication/domain/card_ranker.dart';
import '../../features/communication/domain/custom_card_repository.dart';
import '../../features/communication/domain/literacy_support.dart';
import '../../features/communication/domain/phrase_bank.dart';
import '../../features/sensory_support/domain/breathing_pattern.dart';
import '../../features/communication/domain/symbol_scale.dart';
import '../../features/ai/domain/ai_contracts.dart';
import '../../features/gamification/domain/reward_policy.dart';
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

  /// Whether a real credential is required before the app is usable.
  ///
  /// This is the boundary between the two ways the app can run. With no
  /// backend the answer is false and the app opens straight into the child
  /// experience, which is what keeps it working offline. With Firebase up
  /// the answer is true until a caregiver has signed in, because their uid
  /// is the ownership key every Firestore rule checks — without it the
  /// repositories drop writes silently.
  bool get requiresSignIn;
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

  /// Never. The offline app must not present a sign-in wall.
  @override
  bool get requiresSignIn => false;
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
    CustomCardRepository? customCardRepository,
    PhraseBankRepository? phraseBankRepository,
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
        customCardRepository =
            customCardRepository ?? InMemoryCustomCardRepository(),
        phraseBankRepository =
            phraseBankRepository ?? InMemoryPhraseBankRepository(),
        ambientSoundService =
            ambientSoundService ?? SilentAmbientSoundService(),
        _settings = settingsStore,
        _connectivity = connectivityService {
    // Signed-in defaults to true so the offline app opens straight into the
    // child experience; a backend that needs a real caregiver says so.
    _signedIn = !authRepository.requiresSignIn;
  }

  static RoutineRepository _defaultRoutineRepository() {
    // Overridden by composition root; keeps tests and previews working.
    return _NoopRoutineRepository();
  }

  final AuthRepository authRepository;
  final TtsService ttsService;
  final ProgressRepository progressRepository;
  final RoutineRepository routineRepository;
  final InterestRepository interestRepository;

  /// Caregiver-authored AAC cards, stored locally per child.
  final CustomCardRepository customCardRepository;

  /// Saved whole sentences, per child.
  final PhraseBankRepository phraseBankRepository;

  /// Gentle-sound boundary for the calm screen; silent by default until an
  /// OS-audio adapter is composed in on a real device.
  final AmbientSoundService ambientSoundService;
  final KeyValueStore? _settings;
  final ConnectivityService? _connectivity;
  List<ChildProfile> _children;
  String _selectedChildId = 'demo-child';
  Locale _locale = const Locale('en');
  bool _sensoryMode = false;
  ThemeMode _themeMode = ThemeMode.system;
  bool _signedIn = true;
  bool _childMode = false;
  bool _onboarded = false;
  bool _offline = false;
  int _stars = 12;

  /// Lead time in minutes for transition countdown warnings.
  int _leadMinutes = 5;

  /// Per-child caregiver support preferences (override level and lock).
  final Map<String, SupportPreference> _supportPrefs = {};

  /// Completed-session ledger per child driving reward frequency.
  final Map<String, int> _rewardCounters = {};
  StreamSubscription<bool>? _connectivitySubscription;

  Locale get locale => _locale;
  bool get sensoryMode => _sensoryMode;

  /// Light, dark, or follow the device. Dark is a comfort setting here, not
  /// a style one — a bright screen in a dim room is a common sensory
  /// complaint, so it is surfaced beside the other sensory controls.
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    unawaited(persistSettings());
    notifyListeners();
  }
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

  /// Counts a finished session and pays the level's reward when due
  /// (beginner: every session, intermediate: every second, advanced: every
  /// third). Returns true when a star was awarded.
  bool recordSessionCompleted({
    required String childId,
    required SupportLevel level,
  }) {
    final completed = (_rewardCounters[childId] ?? 0) + 1;
    _rewardCounters[childId] = completed;
    final due = const RewardPolicy().shouldReward(
      level: level,
      completedSessions: completed,
    );
    if (due) awardStars(1);
    unawaited(persistSettings());
    notifyListeners();
    return due;
  }

  int completedSessionsFor(String childId) => _rewardCounters[childId] ?? 0;

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

  /// Adds a profile that already has an id — used by backup import, where
  /// the id must survive so the imported cards and history still point at
  /// the right child.
  void addChildProfile(ChildProfile child) {
    if (_children.any((existing) => existing.id == child.id)) return;
    _children = [..._children, child];
    unawaited(persistSettings());
    notifyListeners();
  }

  /// Replaces every profile. Only used by a destructive restore, which the
  /// UI confirms separately.
  void replaceChildren(List<ChildProfile> children) {
    if (children.isEmpty) return;
    _children = List.unmodifiable(children);
    if (!_children.any((child) => child.id == _selectedChildId)) {
      _selectedChildId = _children.first.id;
    }
    unawaited(persistSettings());
    notifyListeners();
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
    if (sensory != null) {
      _sensoryMode = sensory == 'true';
      await ambientSoundService.setSensoryMode(_sensoryMode);
    }
    final ambientTrack = await store.read(_keyAmbientTrack);
    if (ambientTrack != null) {
      await ambientSoundService.selectTrack(
        AmbientTrack.values.firstWhere(
          (value) => value.name == ambientTrack,
          orElse: () => AmbientTrack.softRain,
        ),
      );
    }
    final ambientVolume =
        double.tryParse(await store.read(_keyAmbientVolume) ?? '');
    if (ambientVolume != null) {
      await ambientSoundService.setVolumePreference(ambientVolume);
    }
    final literacyRaw = await store.read(_keyLiteracy);
    if (literacyRaw != null && literacyRaw.isNotEmpty) {
      final decoded = jsonDecode(literacyRaw);
      if (decoded is Map) {
        _literacy
          ..clear()
          ..addAll(
            decoded.map(
              (childId, value) => MapEntry(
                childId as String,
                LiteracyPreference.fromJson(
                  (value as Map).cast<String, dynamic>(),
                ),
              ),
            ),
          );
      }
    }
    final prediction = await store.read(_keyWordPrediction);
    if (prediction != null) _wordPrediction = prediction == 'true';
    final gridShape = await store.read(_keyGridShape);
    if (gridShape != null) {
      _gridShape = GridShape.values.firstWhere(
        (value) => value.name == gridShape,
        orElse: () => GridShape.flowing,
      );
    }
    final breathing = await store.read(_keyBreathingPattern);
    if (breathing != null) _breathingPatternId = breathing;
    final symbolScale = await store.read(_keySymbolScale);
    if (symbolScale != null) {
      _symbolScale = SymbolScale.values.firstWhere(
        (value) => value.name == symbolScale,
        orElse: () => SymbolScale.comfortable,
      );
    }
    final themeMode = await store.read(_keyThemeMode);
    if (themeMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == themeMode,
        orElse: () => ThemeMode.system,
      );
    }
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
    final rewardJson = await store.read(_keyRewardCounters);
    if (rewardJson != null) {
      try {
        final decoded = jsonDecode(rewardJson) as Map<String, dynamic>;
        _rewardCounters
          ..clear()
          ..addAll(
            decoded.map(
              (childId, value) => MapEntry(childId, value as int? ?? 0),
            ),
          );
      } on FormatException {
        // Corrupt payload: restart the ledger at zero.
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
    await store.write(_keyThemeMode, _themeMode.name);
    await store.write(_keySymbolScale, _symbolScale.name);
    await store.write(_keyWordPrediction, '$_wordPrediction');
    await store.write(_keyGridShape, _gridShape.name);
    await store.write(_keyBreathingPattern, _breathingPatternId);
    await store.write(
      _keyLiteracy,
      jsonEncode(
        _literacy.map((childId, pref) => MapEntry(childId, pref.toJson())),
      ),
    );
    await store.write(_keyAmbientTrack, ambientSoundService.track.name);
    await store.write(
      _keyAmbientVolume,
      ambientSoundService.volumePreference.toStringAsFixed(3),
    );
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
    await store.write(
      _keyRewardCounters,
      jsonEncode(_rewardCounters),
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
  static const String _keyThemeMode = 'autimate.settings.themeMode';
  static const String _keySymbolScale = 'autimate.aac.symbolScale';
  static const String _keyLiteracy = 'autimate.aac.literacy.v1';
  static const String _keyWordPrediction = 'autimate.aac.prediction';
  static const String _keyGridShape = 'autimate.aac.gridShape';
  static const String _keyBreathingPattern = 'autimate.calm.breathing';
  static const String _keyAmbientTrack = 'autimate.sensory.ambientTrack';
  static const String _keyAmbientVolume = 'autimate.sensory.ambientVolume';
  static const String _keyStars = 'autimate.settings.stars';
  static const String _keyChildMode = 'autimate.settings.childMode';
  static const String _keyOnboarded = 'autimate.settings.onboarded';
  static const String _keyLeadMinutes = 'autimate.routine.leadMinutes';
  static const String _keySupportPrefs = 'autimate.support.v1';
  static const String _keyRewardCounters = 'autimate.reward.v1';
  static const String _keyParentPinHash = 'autimate.settings.parentPinHash';
  static const String _keyChildren = 'autimate.children';
  static const String _keySelectedChild = 'autimate.selectedChild';

  @override
  void dispose() {
    unawaited(_connectivitySubscription?.cancel());
    // Without this the ambient bed keeps playing and its AudioPlayer and
    // fade timer outlive the state that owned them.
    unawaited(ambientSoundService.dispose());
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
    // Sensory mode lowers the ambient ceiling too, and must take effect on
    // a bed that is already playing rather than only on the next start.
    unawaited(ambientSoundService.setSensoryMode(value));
    unawaited(persistSettings());
    notifyListeners();
  }

  /// Transition-to-Literacy rung per child.
  ///
  /// Per child rather than per device: this is a ladder a child climbs over
  /// months as their reading develops, not a display preference. Two
  /// children sharing a tablet will be at different rungs.
  final Map<String, LiteracyPreference> _literacy = {};

  LiteracyLevel literacyFor(String childId) =>
      _literacy[childId]?.level ?? LiteracyLevel.off;

  void setLiteracyLevel(String childId, LiteracyLevel level) {
    _literacy[childId] = LiteracyPreference(level: level);
    unawaited(persistSettings());
    notifyListeners();
  }

  // --- Tier-3 preferences -------------------------------------------------

  /// Word prediction. Off by default: it helps a reader and distracts a
  /// symbol-only user, who is the primary audience here.
  bool _wordPrediction = false;
  bool get wordPredictionEnabled => _wordPrediction;

  void setWordPrediction(bool value) {
    if (value == _wordPrediction) return;
    _wordPrediction = value;
    unawaited(persistSettings());
    notifyListeners();
  }

  /// Board layout. Flowing is the default, matching the current behaviour.
  GridShape _gridShape = GridShape.flowing;
  GridShape get gridShape => _gridShape;

  void setGridShape(GridShape shape) {
    if (shape == _gridShape) return;
    _gridShape = shape;
    unawaited(persistSettings());
    notifyListeners();
  }

  /// Guided breathing rhythm.
  String _breathingPatternId = BreathingPattern.gentle.id;
  BreathingPattern get breathingPattern =>
      BreathingPattern.byId(_breathingPatternId);

  void setBreathingPattern(BreathingPattern pattern) {
    if (pattern.id == _breathingPatternId) return;
    _breathingPatternId = pattern.id;
    unawaited(persistSettings());
    notifyListeners();
  }

  // --- Saved phrases ------------------------------------------------------

  List<SavedPhrase> _phrases = const [];
  String? _phrasesChildId;

  List<SavedPhrase> get savedPhrases => _phrases;

  Future<void> loadPhrases({bool force = false}) async {
    final childId = selectedChild.id;
    if (!force && _phrasesChildId == childId) return;
    _phrasesChildId = childId;
    final loaded = await phraseBankRepository.phrasesFor(childId);
    if (_phrasesChildId != childId) return;
    _phrases = loaded;
    notifyListeners();
  }

  Future<void> savePhrase(SavedPhrase phrase) async {
    await phraseBankRepository.save(phrase);
    await loadPhrases(force: true);
  }

  Future<void> deletePhrase(String phraseId) async {
    await phraseBankRepository.delete(phraseId);
    await loadPhrases(force: true);
  }

  /// How large the AAC symbols are drawn. Persisted per device rather than
  /// per child: it usually tracks the device and who is holding it.
  SymbolScale _symbolScale = SymbolScale.comfortable;

  SymbolScale get symbolScale => _symbolScale;

  void setSymbolScale(SymbolScale scale) {
    if (scale == _symbolScale) return;
    _symbolScale = scale;
    unawaited(persistSettings());
    notifyListeners();
  }

  // --- Ambient sound ------------------------------------------------------

  /// Caregiver's chosen loop and level. The service applies the ceiling;
  /// these are the raw preferences, persisted per device.
  AmbientTrack get ambientTrack => ambientSoundService.track;

  double get ambientVolume => ambientSoundService.volumePreference;

  Future<void> setAmbientTrack(AmbientTrack track) async {
    await ambientSoundService.selectTrack(track);
    unawaited(persistSettings());
    notifyListeners();
  }

  Future<void> setAmbientVolume(double value) async {
    await ambientSoundService.setVolumePreference(value);
    unawaited(persistSettings());
    notifyListeners();
  }

  Future<void> toggleAmbientSound() async {
    if (ambientSoundService.isPlaying) {
      await ambientSoundService.stop();
    } else {
      await ambientSoundService.play();
    }
    notifyListeners();
  }

  void awardStars(int amount) {
    _stars += amount;
    unawaited(persistSettings());
    notifyListeners();
  }

  Future<void> recordSession(SessionResult result) =>
      progressRepository.recordSession(result);

  // --- Custom AAC cards ---------------------------------------------------

  List<CustomCard> _customCards = const [];
  String? _customCardsChildId;

  /// Caregiver-created cards for the active child. Empty until
  /// [loadCustomCards] resolves, so callers must tolerate a first frame
  /// with only the built-in deck.
  List<CustomCard> get customCards => _customCards;

  /// Reloads the custom deck, and does so again whenever the active child
  /// changes — cards belong to one child, never to the device.
  Future<void> loadCustomCards({bool force = false}) async {
    final childId = selectedChild.id;
    if (!force && _customCardsChildId == childId) return;
    _customCardsChildId = childId;
    final cards = await customCardRepository.cardsFor(childId);
    if (_customCardsChildId != childId) return;
    _customCards = cards;
    notifyListeners();
  }

  Future<CustomCard> saveCustomCard(CustomCard card) async {
    await customCardRepository.save(card);
    await loadCustomCards(force: true);
    return card;
  }

  Future<void> deleteCustomCard(String cardId) async {
    await customCardRepository.delete(cardId);
    await loadCustomCards(force: true);
  }

  Future<void> recordCardUsage(CardUsageEvent event) =>
      progressRepository.recordCardUsage(event);

  /// Records that the caregiver authenticated.
  ///
  /// Called by the sign-in screen. Without it a correct password left the
  /// caregiver on the form forever, because nothing else flips this flag.
  void markSignedIn() {
    if (_signedIn) return;
    _signedIn = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    await authRepository.signOut();
    // Only meaningful where a credential is actually required; with no
    // backend this would lock the child out of an app that has no way back.
    _signedIn = !authRepository.requiresSignIn;
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
