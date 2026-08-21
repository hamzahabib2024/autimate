import 'package:flutter/material.dart';

import 'tts_service.dart';
import '../../features/communication/domain/card_ranker.dart';
import '../../features/emotion_recognition/domain/emotion_activity_engine.dart';
import '../../features/progress/domain/progress_models.dart';

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
  }) : _children = const [
         ChildProfile(
           id: 'demo-child',
           name: 'Ayaan',
           supportLevel: 'Beginner',
         ),
       ],
       progressRepository = progressRepository ?? InMemoryProgressRepository();

  final AuthRepository authRepository;
  final TtsService ttsService;
  final ProgressRepository progressRepository;
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

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void toggleSensoryMode(bool value) {
    _sensoryMode = value;
    if (ttsService is QueuedTtsService) {
      (ttsService as QueuedTtsService).setSensoryMode(value);
    }
    notifyListeners();
  }

  void awardStars(int amount) {
    _stars += amount;
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
