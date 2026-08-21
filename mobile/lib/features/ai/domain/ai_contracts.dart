import 'dart:async';

class PredictionResult {
  const PredictionResult({
    required this.label,
    required this.confidence,
    required this.modelVersion,
  });

  final String label;
  final double confidence;
  final String modelVersion;
}

class ExpressionReading {
  const ExpressionReading({
    required this.faceDetected,
    required this.smile,
    required this.leftEyeOpen,
    required this.rightEyeOpen,
    required this.headTiltDegrees,
  });

  final bool faceDetected;
  final double smile;
  final double leftEyeOpen;
  final double rightEyeOpen;
  final double headTiltDegrees;
}

abstract interface class AiEngine {
  Future<void> initialise();
  Future<PredictionResult> predict(Object input);
  Future<void> dispose();
}

abstract interface class ExpressionPracticeService {
  Future<bool> isSupported();
  Stream<ExpressionReading> start();
  Future<void> stop();
}
