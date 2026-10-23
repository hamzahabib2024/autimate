import 'dart:async';

import 'package:flutter/widgets.dart' show Widget;

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

/// Why the practice camera could not deliver frames.
///
/// The UI maps each value to a calm, child-safe fallback instead of showing
/// a raw plugin exception. This is the only failure vocabulary that crosses
/// the service boundary.
enum ExpressionCameraFailure {
  /// No usable camera exists on this device.
  noCamera,

  /// The OS refused access to the camera.
  permissionDenied,

  /// Another app currently owns the camera.
  cameraInUse,

  /// Initialisation or streaming failed for any other reason.
  initialisationFailed,
}

/// Typed camera failure carried on [ExpressionPracticeService]'s stream.
class ExpressionPracticeException implements Exception {
  const ExpressionPracticeException(this.reason, [this.cause]);

  final ExpressionCameraFailure reason;

  /// Original platform error, kept for diagnostics only. Never rendered.
  final Object? cause;

  @override
  String toString() => 'ExpressionPracticeException($reason, $cause)';
}

/// Optional live-preview capability of an [ExpressionPracticeService].
///
/// Kept separate from the core service so simulated and test doubles need no
/// camera. Presentation renders the returned widget and never imports
/// `package:camera`, which keeps the platform plugin behind the domain
/// boundary.
abstract interface class CameraPreviewSource {
  /// Current preview, or [placeholder] while the camera initialises.
  /// Null when the service has no preview at all.
  Widget? buildPreview({Widget? placeholder});
}

/// Permission state for the practice camera.
enum CameraPermissionStatus {
  granted,
  denied,
  permanentlyDenied,

  /// Blocked by device policy; the caregiver cannot grant it in settings.
  restricted,

  /// No camera permission concept on this platform.
  unsupported,
}

/// Camera permission boundary. The ML Kit adapter implements this over the
/// OS permission APIs; the offline simulated build answers from
/// configuration instead.
abstract interface class CameraPermissionService {
  Future<CameraPermissionStatus> status();
  Future<CameraPermissionStatus> request();

  /// Opens this app's OS settings page. Returns false when unavailable.
  Future<bool> openSettings();
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

  @override
  Future<bool> openSettings() async => false;
}
