import 'dart:async';

/// The ambient-sound contract used to live here. It has nothing to do with
/// inference, so it now lives in `sensory_support/domain/ambient_sound.dart`
/// and is re-exported to keep existing imports working.
export '../../sensory_support/domain/ambient_sound.dart'
    show
        AmbientTrack,
        AmbientVolumePolicy,
        AmbientSoundService,
        SilentAmbientSoundService;

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

/// Permission state for the practice camera.
enum CameraPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  unsupported,
}

/// Camera permission boundary. The future ML Kit adapter will implement
/// this over the OS permission APIs; the offline simulated build answers
/// from configuration instead.
abstract interface class CameraPermissionService {
  Future<CameraPermissionStatus> status();
  Future<CameraPermissionStatus> request();
}

/// Always-granted permission source backing the simulated practice flow.
class AutoGrantCameraPermissions implements CameraPermissionService {
  const AutoGrantCameraPermissions();

  @override
  Future<CameraPermissionStatus> status() async =>
      CameraPermissionStatus.granted;

  @override
  Future<CameraPermissionStatus> request() async =>
      CameraPermissionStatus.granted;
}

