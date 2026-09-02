import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/sensory_support/domain/ambient_sound.dart';
import 'package:autimate/features/sensory_support/presentation/calm_activities_screen.dart';

import 'helpers/test_app.dart';

class _FakeAmbient implements AmbientSoundService {
  bool playing = false;
  bool sensory = false;
  AmbientTrack selected = AmbientTrack.softRain;
  double preference = AmbientVolumePolicy.defaultPreference;
  int disposeCalls = 0;

  @override
  bool get isPlaying => playing;

  @override
  AmbientTrack get track => selected;

  @override
  double get volumePreference => preference;

  @override
  Future<void> play() async => playing = true;

  @override
  Future<void> stop() async => playing = false;

  @override
  Future<void> selectTrack(AmbientTrack track) async => selected = track;

  @override
  Future<void> setVolumePreference(double value) async =>
      preference = value.clamp(0.0, 1.0);

  @override
  Future<void> setSensoryMode(bool value) async => sensory = value;

  @override
  Future<void> dispose() async => disposeCalls++;
}

void main() {
  group('volume ceiling', () {
    const policy = AmbientVolumePolicy();

    test('a maximum preference still lands well under full output', () {
      final loudest = policy.resolve(preference: 1.0, sensoryMode: false);
      expect(loudest, AmbientVolumePolicy.ceiling);
      expect(loudest, lessThan(0.6));
    });

    test('sensory mode lowers the ceiling further', () {
      final normal = policy.resolve(preference: 1.0, sensoryMode: false);
      final calm = policy.resolve(preference: 1.0, sensoryMode: true);
      expect(calm, lessThan(normal));
      expect(calm, AmbientVolumePolicy.sensoryCeiling);
    });

    test('the ceiling binds at every preference, not just the top', () {
      for (final preference in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        for (final sensory in [false, true]) {
          final resolved =
              policy.resolve(preference: preference, sensoryMode: sensory);
          expect(resolved, lessThanOrEqualTo(AmbientVolumePolicy.ceiling));
          expect(resolved, greaterThanOrEqualTo(0.0));
        }
      }
    });

    test('out-of-range preferences are clamped, never amplified', () {
      expect(policy.resolve(preference: 5.0, sensoryMode: false),
          AmbientVolumePolicy.ceiling);
      expect(policy.resolve(preference: -3.0, sensoryMode: false), 0.0);
    });
  });

  group('silent fallback', () {
    test('behaves like the real service but makes no sound', () async {
      final service = SilentAmbientSoundService();
      expect(service.isPlaying, isFalse);
      await service.play();
      expect(service.isPlaying, isTrue);
      await service.selectTrack(AmbientTrack.warmHum);
      expect(service.track, AmbientTrack.warmHum);
      await service.setVolumePreference(2.0);
      expect(service.volumePreference, 1.0);
      await service.stop();
      expect(service.isPlaying, isFalse);
    });

    test('never starts on its own', () {
      expect(SilentAmbientSoundService().isPlaying, isFalse);
    });
  });

  group('tracks', () {
    test('every track points at a bundled asset', () {
      for (final track in AmbientTrack.values) {
        expect(track.asset, startsWith('assets/audio/'));
        expect(track.asset, endsWith('.wav'));
      }
      expect(AmbientTrack.values, hasLength(3));
    });
  });

  group('app state integration', () {
    test('sensory mode reaches an already-playing bed', () async {
      final ambient = _FakeAmbient();
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        ambientSoundService: ambient,
      );
      await appState.toggleAmbientSound();
      expect(ambient.playing, isTrue);

      appState.toggleSensoryMode(true);
      await Future<void>.delayed(Duration.zero);
      expect(ambient.sensory, isTrue,
          reason: 'the ceiling must drop on a bed that is already playing');
    });

    test('track and volume survive a restart', () async {
      final store = InMemoryKeyValueStore();
      final first = _FakeAmbient();
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        ambientSoundService: first,
        settingsStore: store,
      );
      await appState.setAmbientTrack(AmbientTrack.slowOcean);
      await appState.setAmbientVolume(0.4);
      await appState.persistSettings();

      final second = _FakeAmbient();
      final restarted = AppState(
        MockAuthRepository(),
        MockTtsService(),
        ambientSoundService: second,
        settingsStore: store,
      );
      await restarted.loadPersistedSettings();

      expect(second.selected, AmbientTrack.slowOcean);
      expect(second.preference, closeTo(0.4, 0.001));
    });

    test('toggle flips play and stop', () async {
      final ambient = _FakeAmbient();
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        ambientSoundService: ambient,
      );
      await appState.toggleAmbientSound();
      expect(ambient.playing, isTrue);
      await appState.toggleAmbientSound();
      expect(ambient.playing, isFalse);
    });
  });

  group('calm screen controls', () {
    testWidgets('track and volume controls appear only while playing',
        (tester) async {
      final ambient = _FakeAmbient();
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        ambientSoundService: ambient,
      );

      await tester.pumpWidget(testApp(CalmingScreen(appState: appState)));
      await tester.pump();

      // The resting screen stays bare.
      expect(find.byKey(const ValueKey('ambient-volume')), findsNothing);
      expect(
        find.byKey(const ValueKey('ambient-track-slowOcean')),
        findsNothing,
      );

      await tester.tap(find.byKey(const ValueKey('calm-sound')));
      await tester.pump();

      expect(find.byKey(const ValueKey('ambient-volume')), findsOneWidget);
      for (final track in AmbientTrack.values) {
        expect(
          find.byKey(ValueKey('ambient-track-${track.name}')),
          findsOneWidget,
        );
      }
    });

    testWidgets('choosing a track switches the bed', (tester) async {
      final ambient = _FakeAmbient();
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        ambientSoundService: ambient,
      );

      await tester.pumpWidget(testApp(CalmingScreen(appState: appState)));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('calm-sound')));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('ambient-track-warmHum')));
      await tester.pump();

      expect(ambient.selected, AmbientTrack.warmHum);
    });
  });
}
