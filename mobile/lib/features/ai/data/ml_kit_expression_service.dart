import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../domain/ai_contracts.dart';
import '../domain/expression_practice_engine.dart';
import 'frame_conversion.dart';

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
/// Every session is isolated behind an integer token. A stop, a second start,
/// or disposal invalidates in-flight setup, so a camera that finishes
/// initialising late can never attach itself to a session that is already
/// gone. Failures are surfaced as [ExpressionPracticeException] so the UI can
/// choose a calm fallback instead of seeing a plugin error.
class MlKitExpressionService
    implements ExpressionPracticeService, CameraPreviewSource {
  MlKitExpressionService({
    this.config = const ExpressionPracticeConfig(),
    FaceDetector? detector,
    Future<List<CameraDescription>> Function()? camerasProvider,
  }) : _injectedDetector = detector,
       _camerasProvider = camerasProvider ?? availableCameras {
    _throttle = FrameThrottle(minInterval: config.minFrameInterval);
  }

  final ExpressionPracticeConfig config;
  final FaceDetector? _injectedDetector;
  final Future<List<CameraDescription>> Function() _camerasProvider;

  final ValueNotifier<CameraController?> _preview = ValueNotifier(null);

  StreamController<ExpressionReading>? _readings;
  CameraController? _camera;
  FaceDetector? _detector;
  late FrameThrottle _throttle;

  /// Incremented whenever a session starts or ends. Async work checks its
  /// token before touching shared state.
  int _session = 0;

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
  Widget? buildPreview({Widget? placeholder}) => _LivePreview(
    controller: _preview,
    placeholder: placeholder ?? const SizedBox.shrink(),
  );

  @override
  Stream<ExpressionReading> start() {
    // Invalidate any previous session before replacing its stream. The
    // teardown is asynchronous, but the token means it cannot disturb the
    // new session even if it finishes later.
    final token = ++_session;
    final previousReadings = _readings;
    final previousCamera = _camera;
    final previousDetector = _detector;
    _readings = null;
    _camera = null;
    _detector = null;
    _preview.value = null;
    unawaited(_teardown(previousCamera, previousDetector, previousReadings));

    final controller = StreamController<ExpressionReading>.broadcast(
      onCancel: stop,
    );
    _readings = controller;
    _throttle = FrameThrottle(minInterval: config.minFrameInterval);
    unawaited(_begin(token, controller));
    return controller.stream;
  }

  Future<void> _begin(
    int token,
    StreamController<ExpressionReading> readings,
  ) async {
    CameraController? pending;
    try {
      final cameras = await _camerasProvider();
      if (!_isCurrent(token, readings)) return;
      if (cameras.isEmpty) {
        throw const ExpressionPracticeException(
          ExpressionCameraFailure.noCamera,
        );
      }
      final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      pending = CameraController(
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

      await pending.initialize();
      if (!_isCurrent(token, readings)) {
        await pending.dispose();
        return;
      }

      _camera = pending;
      _detector = _buildDetector();
      _preview.value = pending;
      // The session owns the controller from here; the cleanup below must
      // not dispose it a second time.
      pending = null;
      await _camera!.startImageStream(
        (image) => _onFrame(token, readings, image),
      );
    } catch (error, stack) {
      // Setup failed before ownership moved to the session: release it.
      await pending?.dispose();
      if (!_isCurrent(token, readings)) return;
      final failure = _classify(error);
      debugPrint('Expression practice could not start: $error');
      assert(() {
        debugPrintStack(stackTrace: stack, label: 'ml-kit-expression');
        return true;
      }());
      readings.addError(ExpressionPracticeException(failure, error));
      await _end(token, readings);
    }
  }

  Future<void> _onFrame(
    int token,
    StreamController<ExpressionReading> readings,
    CameraImage image,
  ) async {
    final camera = _camera;
    if (!_isCurrent(token, readings) || camera == null) return;
    // The busy-flag throttle keeps inference load flat: a frame arriving
    // while the previous one is still in the detector is dropped, not queued.
    if (!_throttle.beginFrame(DateTime.now())) return;

    try {
      // We requested a single-plane format. Anything else (YUV420, for
      // example) is unusable here and costs exactly one frame.
      if (image.planes.length != 1) return;
      final plane = image.planes.first;
      final input = inputImageFromFrame(
        CameraFrame(
          bytes: plane.bytes,
          width: image.width,
          height: image.height,
          bytesPerRow: plane.bytesPerRow,
          formatGroup: image.format.group,
          rawFormat: image.format.raw,
          sensorOrientation: camera.description.sensorOrientation,
          deviceOrientation: camera.value.deviceOrientation,
          lensDirection: camera.description.lensDirection,
        ),
      );
      if (input == null) return;

      final detector = _detector;
      if (detector == null) return;
      final faces = await detector.processImage(input);
      if (!_isCurrent(token, readings)) return;
      readings.add(_toReading(faces));
    } catch (error) {
      // A single bad frame is not a session failure: drop it and keep the
      // practice going.
      debugPrint('Frame skipped: $error');
    } finally {
      _throttle.endFrame();
      // The frame goes out of scope here and is never retained.
    }
  }

  bool _isCurrent(int token, StreamController<ExpressionReading> readings) =>
      _session == token && identical(_readings, readings) && !readings.isClosed;

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

  /// Classifies platform errors into the small vocabulary the UI handles.
  ExpressionCameraFailure _classify(Object error) {
    if (error is ExpressionPracticeException) return error.reason;
    if (error is CameraException) {
      final code = error.code.toLowerCase();
      if (code.contains('denied') || code.contains('restricted')) {
        return ExpressionCameraFailure.permissionDenied;
      }
      if (code.contains('notfound') || code.contains('not_found')) {
        return ExpressionCameraFailure.noCamera;
      }
      if (code.contains('inuse') ||
          code.contains('in_use') ||
          code.contains('unavailable')) {
        return ExpressionCameraFailure.cameraInUse;
      }
    }
    return ExpressionCameraFailure.initialisationFailed;
  }

  @override
  Future<void> stop() async {
    // Invalidate in-flight work first, then release the current session.
    _session++;
    final readings = _readings;
    final camera = _camera;
    final detector = _detector;
    _readings = null;
    _camera = null;
    _detector = null;
    _preview.value = null;
    await _teardown(camera, detector, readings);
  }

  /// Ends a failed session without stealing a newer one's state.
  Future<void> _end(
    int token,
    StreamController<ExpressionReading> readings,
  ) async {
    if (!_isCurrent(token, readings)) return;
    final camera = _camera;
    final detector = _detector;
    _readings = null;
    _camera = null;
    _detector = null;
    _preview.value = null;
    await _teardown(camera, detector, readings);
  }

  Future<void> _teardown(
    CameraController? camera,
    FaceDetector? detector,
    StreamController<ExpressionReading>? readings,
  ) async {
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
      // A detector supplied by a caller stays theirs to close; only ours is
      // disposed with the session.
      if (detector != null && !identical(detector, _injectedDetector)) {
        await detector.close();
      }
    } catch (error) {
      debugPrint('Detector close: $error');
    }
    if (readings != null && !readings.isClosed) {
      await readings.close();
    }
  }
}

/// Watches the service's controller slot so the preview appears the moment
/// initialisation completes, without the screen polling or importing camera
/// types.
class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.controller, required this.placeholder});

  final ValueListenable<CameraController?> controller;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraController?>(
      valueListenable: controller,
      builder: (context, camera, _) {
        final size = camera?.value.previewSize;
        if (camera == null || size == null || !camera.value.isInitialized) {
          return placeholder;
        }
        // previewSize is landscape-first; swap for portrait so BoxFit.cover
        // fills the card without distortion or overflow.
        final portrait =
            MediaQuery.orientationOf(context) == Orientation.portrait;
        // A front camera is mirrored so the child sees a natural reflection.
        final preview = CameraPreview(camera);
        return ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: portrait ? size.height : size.width,
              height: portrait ? size.width : size.height,
              child:
                  camera.description.lensDirection == CameraLensDirection.front
                  ? Transform.scale(scaleX: -1, child: preview)
                  : preview,
            ),
          ),
        );
      },
    );
  }
}
