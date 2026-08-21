import 'dart:async';

import '../domain/ai_contracts.dart';

/// Deterministic offline stand-in for the future ML Kit camera adapter.
///
/// Emits a repeating smile ramp (low -> high -> low) so the practice flow,
/// UI states, and star awarding can be demonstrated and tested without a
/// camera or on-device model. No frames are captured, stored, or uploaded.
class SimulatedExpressionService implements ExpressionPracticeService {
  SimulatedExpressionService({this.period = const Duration(seconds: 2)});

  final Duration period;
  StreamController<ExpressionReading>? _controller;
  Timer? _ticker;
  int _tick = 0;

  @override
  Future<bool> isSupported() async => true;

  @override
  Stream<ExpressionReading> start() {
    stop();
    _controller = StreamController<ExpressionReading>.broadcast();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final t = (_tick++ * 100) % period.inMilliseconds;
      // Triangle wave between 0.05 and 0.95 across the period.
      final phase = t / period.inMilliseconds;
      final smile =
          0.05 + 0.9 * (phase <= 0.5 ? phase * 2 : (1 - phase) * 2);
      _controller?.add(
        ExpressionReading(
          faceDetected: true,
          smile: smile,
          leftEyeOpen: 0.9,
          rightEyeOpen: 0.9,
          headTiltDegrees: 0,
        ),
      );
    });
    return _controller!.stream;
  }

  @override
  Future<void> stop() async {
    _ticker?.cancel();
    _ticker = null;
    await _controller?.close();
    _controller = null;
  }
}
