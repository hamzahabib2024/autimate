import 'dart:async';
import 'dart:io';
import 'dart:ui' show Size;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../domain/ai_contracts.dart';
import '../domain/expression_practice_engine.dart';

/// Real on-device expression practice: camera frames → ML Kit face
/// detection → [ExpressionReading].
///
/// **The privacy contract, enforced here rather than promised elsewhere.**
/// A frame is converted, passed to the detector, and dropped. Nothing is
/// written to disk, added to a buffer, or sent anywhere — there is no code
/// path in this class that could. The only thing that outlives a frame is a
/// handful of doubles. Whoever changes this file next: adding a debug frame
/// dump would break the promise the whole feature rests on.
///
/// The detector is configured for exactly the signals the practice engine
/// consumes — smile probability, eye openness, head angle — and nothing
/// else. Contours and landmarks stay off: they cost inference time and this
/// app has no use for them.
///
/// Everything degrades to "unsupported" rather than throwing. A camera that
/// will not open must leave the child on a calm explanatory screen, which
/// the practice UI already renders.
class MlKitExpressionService implements ExpressionPracticeService {
  MlKitExpressionService({
    this.config = const ExpressionPracticeConfig(),
    FaceDetector? detector,
    Future<List<CameraDescription>> Function()? camerasProvider,
  }) : _injectedDetector = detector,
       _camerasProvider = camerasProvider ?? availableCameras;

  final ExpressionPracticeConfig config;
  final FaceDetector? _injectedDetector;
  final Future<List<CameraDescription>> Function() _camerasProvider;

  CameraController? _camera;
  FaceDetector? _detector;
  StreamController<ExpressionReading>? _readings;
  late final FrameThrottle _throttle =
      FrameThrottle(minInterval: config.minFrameInterval);
  bool _streaming = false;

  /// Exposed so the practice screen can show a live preview.
  CameraController? get controller => _camera;

  @override
  Future<bool> isSupported() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return false;
    try {
      final cameras = await _camerasProvider();
      return cameras.any(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } catch (error) {
      debugPrint('Expression practice unsupported: $error');
      return false;
    }
  }

  FaceDetector _buildDetector() =>
      _injectedDetector ??
      FaceDetector(
        options: FaceDetectorOptions(
          // Classification is the whole point: it produces the smile and
          // eye-open probabilities the engine smooths.
          enableClassification: true,
          // Off deliberately — unused by this app and not free.
          enableLandmarks: false,
          enableContours: false,
          enableTracking: false,
          // `fast` over `accurate`: this runs every frame on a phone that
          // may be low-end, and the signal is a practice cue, not a
          // measurement.
          performanceMode: FaceDetectorMode.fast,
          minFaceSize: 0.15,
        ),
      );

  @override
  Stream<ExpressionReading> start() {
    // Returned synchronously to satisfy the contract; setup runs behind it.
    _readings = StreamController<ExpressionReading>.broadcast(
      onCancel: stop,
    );
    unawaited(_begin());
    return _readings!.stream;
  }

  Future<void> _begin() async {
    try {
      final cameras = await _camerasProvider();
      final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        front,
        // Low is deliberate. Face detection does not need more, and a
        // smaller frame is less to convert, less to infer on, and less heat
        // on a device a child is holding.
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      _camera = controller;
      await controller.initialize();

      _detector = _buildDetector();
      _streaming = true;
      await controller.startImageStream(_onFrame);
    } catch (error, stack) {
      debugPrint('Expression practice could not start: $error');
      assert(() {
        debugPrintStack(stackTrace: stack, label: 'ml-kit-expression');
        return true;
      }());
      // Close the stream so the UI falls to its error state rather than
      // waiting forever on a stream that will never emit.
      await _readings?.close();
      _readings = null;
      await stop();
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    final readings = _readings;
    if (!_streaming || readings == null || readings.isClosed) return;
    // The busy-flag throttle keeps inference load flat: a frame arriving
    // while the previous one is still in the detector is dropped, not queued.
    if (!_throttle.beginFrame(DateTime.now())) return;
    try {
      final input = _toInputImage(image);
      if (input == null) return;
      final faces = await _detector?.processImage(input) ?? const <Face>[];
      if (readings.isClosed) return;
      readings.add(_toReading(faces));
    } catch (error) {
      debugPrint('Frame skipped: $error');
    } finally {
      _throttle.endFrame();
      // The frame goes out of scope here and is never retained.
    }
  }

  /// Maps detector output onto the reading the engine consumes.
  ///
  /// No face is a first-class state, not an error: the practice UI turns it
  /// into a "come closer" hint rather than a failure.
  ExpressionReading _toReading(List<Face> faces) {
    if (faces.isEmpty) {
      return const ExpressionReading(
        faceDetected: false,
        smile: 0,
        leftEyeOpen: 0,
        rightEyeOpen: 0,
        headTiltDegrees: 0,
      );
    }
    // The largest face is the child holding the device; a smaller one in
    // frame is a bystander.
    final face = faces.reduce(
      (a, b) =>
          a.boundingBox.width * a.boundingBox.height >=
              b.boundingBox.width * b.boundingBox.height
          ? a
          : b,
    );
    return ExpressionReading(
      faceDetected: true,
      smile: face.smilingProbability ?? 0,
      leftEyeOpen: face.leftEyeOpenProbability ?? 1,
      rightEyeOpen: face.rightEyeOpenProbability ?? 1,
      headTiltDegrees: face.headEulerAngleZ ?? 0,
    );
  }

  /// Converts a camera frame into ML Kit's input format.
  ///
  /// Returns null rather than throwing on a format the platform gave us
  /// that we cannot describe — one unusable frame should cost one frame,
  /// not the session.
  InputImage? _toInputImage(CameraImage image) {
    final camera = _camera;
    if (camera == null) return null;

    final rotation = InputImageRotationValue.fromRawValue(
      camera.description.sensorOrientation,
    );
    final format = InputImageFormatValue.fromRawValue(image.format.raw is int
        ? image.format.raw as int
        : 0);
    if (rotation == null || format == null) return null;
    if (image.planes.isEmpty) return null;

    return InputImage.fromBytes(
      bytes: image.planes.first.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  @override
  Future<void> stop() async {
    _streaming = false;
    final camera = _camera;
    _camera = null;
    try {
      if (camera != null) {
        if (camera.value.isStreamingImages) {
          await camera.stopImageStream();
        }
        await camera.dispose();
      }
    } catch (error) {
      debugPrint('Camera stop: $error');
    }
    try {
      await _detector?.close();
    } catch (error) {
      debugPrint('Detector close: $error');
    }
    _detector = null;
    final readings = _readings;
    _readings = null;
    if (readings != null && !readings.isClosed) await readings.close();
  }
}
