import 'ai_contracts.dart';

/// Tuning constants for the on-device expression practice pipeline.
class ExpressionPracticeConfig {
  const ExpressionPracticeConfig({
    this.emaAlpha = 0.3,
    this.smileThreshold = 0.75,
    this.holdDuration = const Duration(seconds: 1),
    this.minFrameInterval = const Duration(milliseconds: 100),
    this.repsTarget = 3,
  });

  /// Exponential moving average weight for new readings (plan value: 0.3).
  final double emaAlpha;

  /// Smoothed smile probability that must be sustained to count a rep.
  final double smileThreshold;

  /// How long the smoothed smile must stay above the threshold.
  final Duration holdDuration;

  /// Minimum spacing between processed frames; frames arriving sooner are
  /// dropped through the busy-flag throttle.
  final Duration minFrameInterval;

  /// Smiles required to finish one practice session.
  final int repsTarget;
}

/// Busy-flag frame throttle: accepts a frame only when the previous frame
/// has been processed and [ExpressionPracticeConfig.minFrameInterval] has
/// elapsed. Keeps inference load flat on low-end devices.
class FrameThrottle {
  FrameThrottle({required this.minInterval});

  final Duration minInterval;
  bool _busy = false;
  DateTime? _lastAcceptedAt;

  bool get busy => _busy;

  /// Marks processing start; returns false when still busy or too soon.
  bool beginFrame(DateTime now) {
    if (_busy) return false;
    final last = _lastAcceptedAt;
    if (last != null && now.difference(last) < minInterval) return false;
    _busy = true;
    _lastAcceptedAt = now;
    return true;
  }

  void endFrame() {
    _busy = false;
  }
}

/// Exponential moving average smoother around alpha `0.3`.
class SmileEmaSmoother {
  SmileEmaSmoother({required this.alpha});

  final double alpha;
  double _value = 0;
  bool _primed = false;

  double get value => _value;

  double smooth(double raw) {
    if (!_primed) {
      _value = raw;
      _primed = true;
      return _value;
    }
    _value = alpha * raw + (1 - alpha) * _value;
    return _value;
  }

  void reset() {
    _value = 0;
    _primed = false;
  }
}

/// Outcome of feeding one throttled frame into the session engine.
class ExpressionFeedback {
  const ExpressionFeedback({
    required this.faceDetected,
    required this.smoothedSmile,
    required this.holding,
    required this.starAwarded,
    required this.starsEarned,
    required this.sessionComplete,
    this.eyesClosed = false,
    this.headTiltedDeg = 0,
  });

  final bool faceDetected;
  final double smoothedSmile;
  final bool holding;
  final bool starAwarded;
  final int starsEarned;
  final bool sessionComplete;

  /// True when the latest reading's eye-open probability suggests closed
  /// eyes (below the configured floor); drives the "open your eyes" hint.
  final bool eyesClosed;

  /// Latest signed head tilt in degrees; values beyond the configured
  /// threshold drive the "look at the camera" hint.
  final double headTiltedDeg;
}

  /// Deterministic state machine over an `ExpressionReading` stream.
///
/// A rep is counted when the EMA-smoothed smile probability stays at or
/// above [ExpressionPracticeConfig.smileThreshold] for
/// [ExpressionPracticeConfig.holdDuration]; each rep awards one star and
/// the session completes after [ExpressionPracticeConfig.repsTarget] reps.
///
/// Frames never leave memory: the engine keeps aggregates only.
class ExpressionSessionEngine {
  ExpressionSessionEngine({
    this.config = const ExpressionPracticeConfig(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       _throttle = FrameThrottle(minInterval: config.minFrameInterval),
       _smoother = SmileEmaSmoother(alpha: config.emaAlpha);

  final ExpressionPracticeConfig config;
  final DateTime Function() _clock;
  final FrameThrottle _throttle;
  final SmileEmaSmoother _smoother;

  /// Probability floor under which an eye counts as closed.
  static const double eyeOpenFloor = 0.3;

  /// Absolute tilt (degrees) beyond which the head is considered turned.
  static const double headTiltThresholdDeg = 20;

  DateTime? _holdStartedAt;
  int _stars = 0;
  bool _complete = false;

  int get starsEarned => _stars;
  bool get sessionComplete => _complete;
  double get smoothedSmile => _smoother.value;

  void restart() {
    _smoother.reset();
    _holdStartedAt = null;
    _stars = 0;
    _complete = false;
  }

  /// Processes one raw camera reading. Returns feedback describing the
  /// practice state after this frame; `starAwarded` is true exactly once
  /// per completed hold.
  ExpressionFeedback feed(ExpressionReading reading) {
    final now = _clock();
    if (_complete || !reading.faceDetected || !_throttle.beginFrame(now)) {
      // Lost face or throttled frame: any in-progress hold decays.
      if (!reading.faceDetected) _holdStartedAt = null;
      _throttle.endFrame();
      return ExpressionFeedback(
        faceDetected: reading.faceDetected,
        smoothedSmile: _smoother.value,
        holding: false,
        starAwarded: false,
        starsEarned: _stars,
        sessionComplete: _complete,
        eyesClosed: _eyesClosed(reading),
        headTiltedDeg: reading.headTiltDegrees,
      );
    }

    final smoothed = _smoother.smooth(reading.smile);
    var awarded = false;
    if (smoothed >= config.smileThreshold) {
      _holdStartedAt ??= now;
      if (now.difference(_holdStartedAt!) >= config.holdDuration &&
          _stars < config.repsTarget) {
        _stars++;
        awarded = true;
        _holdStartedAt = null;
        if (_stars >= config.repsTarget) _complete = true;
      }
    } else {
      _holdStartedAt = null;
    }
    _throttle.endFrame();

    return ExpressionFeedback(
      faceDetected: true,
      smoothedSmile: smoothed,
      holding: _holdStartedAt != null,
      starAwarded: awarded,
      starsEarned: _stars,
      sessionComplete: _complete,
      eyesClosed: _eyesClosed(reading),
      headTiltedDeg: reading.headTiltDegrees,
    );
  }

  static bool _eyesClosed(ExpressionReading reading) =>
      reading.leftEyeOpen < eyeOpenFloor &&
      reading.rightEyeOpen < eyeOpenFloor;
}
