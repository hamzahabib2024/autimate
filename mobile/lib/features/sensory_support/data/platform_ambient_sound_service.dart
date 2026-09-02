import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../domain/ambient_sound.dart';

/// Plays the bundled ambient loops through the platform audio output.
///
/// Three behaviours here exist specifically for this audience:
///
/// * **Nothing ever starts on its own.** [play] is only reachable from an
///   explicit tap on the calm screen.
/// * **Every start and stop is faded**, never snapped. A hard cut is a
///   transient, which is the thing the loops themselves are built to avoid.
/// * **Volume is capped by [AmbientVolumePolicy]**, not by whoever last
///   moved the slider, and the cap drops again in sensory mode.
///
/// Any platform failure degrades to silence rather than throwing: a broken
/// audio device must not take down the calm screen, which is where a
/// distressed child is most likely to be.
class PlatformAmbientSoundService implements AmbientSoundService {
  PlatformAmbientSoundService({
    AudioPlayer? player,
    AmbientTrack track = AmbientTrack.softRain,
    double volumePreference = AmbientVolumePolicy.defaultPreference,
    bool sensoryMode = false,
    this.fadeDuration = const Duration(milliseconds: 900),
  }) : _player = player ?? AudioPlayer(),
       _track = track,
       _volume = volumePreference,
       _sensoryMode = sensoryMode;

  static const AmbientVolumePolicy _policy = AmbientVolumePolicy();
  static const int _fadeSteps = 18;

  final AudioPlayer _player;

  /// How long a start or stop takes to reach full level or silence.
  final Duration fadeDuration;

  bool _playing = false;
  bool _configured = false;
  bool _disposed = false;
  AmbientTrack _track;
  double _volume;
  bool _sensoryMode;
  Timer? _fade;

  @override
  bool get isPlaying => _playing;

  @override
  AmbientTrack get track => _track;

  @override
  double get volumePreference => _volume;

  /// The level actually sent to the platform, after the ceiling.
  double get effectiveVolume =>
      _policy.resolve(preference: _volume, sensoryMode: _sensoryMode);

  Future<void> _configure() async {
    if (_configured) return;
    await _player.setReleaseMode(ReleaseMode.loop);
    // Ambient beds should duck under, not silence, anything else playing,
    // and must never steal focus from the TTS the child relies on.
    await _player.setPlayerMode(PlayerMode.mediaPlayer);
    _configured = true;
  }

  @override
  Future<void> play() async {
    if (_disposed || _playing) return;
    _playing = true;
    await _guard(() async {
      await _configure();
      await _setVolume(0);
      await _player.play(AssetSource(_assetKey(_track)));
      await _rampTo(effectiveVolume);
    });
  }

  @override
  Future<void> stop() async {
    if (_disposed || !_playing) return;
    _playing = false;
    await _guard(() async {
      await _rampTo(0);
      await _player.stop();
    });
  }

  @override
  Future<void> selectTrack(AmbientTrack track) async {
    if (_track == track) return;
    _track = track;
    if (!_playing || _disposed) return;
    // Swap under a fade so the change of bed is not itself a transient.
    await _guard(() async {
      await _rampTo(0);
      await _player.stop();
      await _setVolume(0);
      await _player.play(AssetSource(_assetKey(_track)));
      await _rampTo(effectiveVolume);
    });
  }

  @override
  Future<void> setVolumePreference(double value) async {
    _volume = value.clamp(0.0, 1.0);
    if (!_playing || _disposed) return;
    await _guard(() => _player.setVolume(effectiveVolume));
  }

  @override
  Future<void> setSensoryMode(bool value) async {
    if (_sensoryMode == value) return;
    _sensoryMode = value;
    if (!_playing || _disposed) return;
    // Entering sensory mode must lower an already-playing bed immediately.
    await _guard(() => _rampTo(effectiveVolume));
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _playing = false;
    _fade?.cancel();
    await _guard(_player.dispose);
  }

  /// `audioplayers` resolves `AssetSource` relative to `assets/`, so the
  /// declared path has that prefix stripped.
  String _assetKey(AmbientTrack track) =>
      track.asset.startsWith('assets/')
          ? track.asset.substring('assets/'.length)
          : track.asset;

  double _lastVolume = 0;

  /// Single place every volume change goes through, so the fade always
  /// knows where it is starting from.
  Future<void> _setVolume(double value) async {
    final clamped = value.clamp(0.0, 1.0);
    _lastVolume = clamped;
    await _guard(() => _player.setVolume(clamped));
  }

  /// Steps the volume toward [target] rather than jumping to it.
  Future<void> _rampTo(double target) async {
    _fade?.cancel();
    final start = _lastVolume;
    final step = fadeDuration ~/ _fadeSteps;
    final completer = Completer<void>();
    var i = 0;
    _fade = Timer.periodic(step, (timer) async {
      i++;
      final t = (i / _fadeSteps).clamp(0.0, 1.0);
      await _setVolume(start + (target - start) * t);
      if (i >= _fadeSteps || _disposed) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });
    return completer.future;
  }

  /// Runs a platform call, degrading to silence on failure.
  ///
  /// The calm screen is where a distressed child is most likely to be; an
  /// audio-device error must never surface as a crash there.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stack) {
      _playing = false;
      debugPrint('Ambient sound unavailable, continuing silently: $error');
      assert(() {
        debugPrintStack(stackTrace: stack, label: 'ambient-sound');
        return true;
      }());
    }
  }
}
