import 'dart:typed_data';
import 'dart:ui' show Size;

import 'package:camera/camera.dart' show CameraLensDirection, ImageFormatGroup;
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// One camera frame reduced to plain values.
///
/// This exists so the tricky part of the adapter — rotation and format
/// mapping — can be unit-tested without a camera, a plugin channel, or a
/// device. [MlKitExpressionService] adapts `CameraImage` into this shape;
/// nothing else in the app needs to know about it.
class CameraFrame {
  const CameraFrame({
    required this.bytes,
    required this.width,
    required this.height,
    required this.bytesPerRow,
    required this.formatGroup,
    required this.rawFormat,
    required this.sensorOrientation,
    required this.deviceOrientation,
    required this.lensDirection,
  });

  final Uint8List bytes;
  final int width;
  final int height;
  final int bytesPerRow;
  final ImageFormatGroup formatGroup;
  final Object? rawFormat;
  final int sensorOrientation;
  final DeviceOrientation deviceOrientation;
  final CameraLensDirection lensDirection;
}

/// Converts a [CameraFrame] into ML Kit's input format.
///
/// Returns null for anything we cannot describe honestly — an unsupported
/// format, a multi-plane frame, or malformed dimensions. One unusable frame
/// must cost one frame, never the session.
InputImage? inputImageFromFrame(CameraFrame frame) {
  if (frame.bytes.isEmpty ||
      frame.width <= 0 ||
      frame.height <= 0 ||
      frame.bytesPerRow <= 0) {
    return null;
  }

  final format = inputFormatFor(frame.formatGroup, frame.rawFormat);
  final rotation = rotationDegreesFor(
    sensorOrientation: frame.sensorOrientation,
    deviceOrientation: frame.deviceOrientation,
    lensDirection: frame.lensDirection,
  );
  if (format == null || rotation == null) return null;

  return InputImage.fromBytes(
    bytes: frame.bytes,
    metadata: InputImageMetadata(
      size: Size(frame.width.toDouble(), frame.height.toDouble()),
      rotation: InputImageRotationValue.fromRawValue(rotation)!,
      format: format,
      bytesPerRow: frame.bytesPerRow,
    ),
  );
}

/// Maps the platform format onto ML Kit's single-plane formats.
///
/// The adapter requests NV21 on Android and BGRA8888 on iOS precisely so the
/// frame is one contiguous buffer. YUV420 arrives as three planes and is
/// rejected rather than silently read as garbage.
InputImageFormat? inputFormatFor(ImageFormatGroup group, Object? rawFormat) {
  if (rawFormat is! int) return null;
  final resolved = InputImageFormatValue.fromRawValue(rawFormat);
  if (resolved == null) return null;

  return switch (group) {
    ImageFormatGroup.nv21 =>
      resolved == InputImageFormat.nv21 ? resolved : null,
    ImageFormatGroup.bgra8888 =>
      resolved == InputImageFormat.bgra8888 ? resolved : null,
    _ => null,
  };
}

/// Rotation ML Kit must apply to make the frame upright.
///
/// `sensorOrientation` is the sensor's clockwise offset from the device's
/// natural orientation. The device rotation is subtracted for a back camera
/// and added for a front camera, because a front sensor is mirrored. Getting
/// this wrong makes faces "invisible" to ML Kit even though the preview
/// looks fine.
int? rotationDegreesFor({
  required int sensorOrientation,
  required DeviceOrientation deviceOrientation,
  required CameraLensDirection lensDirection,
}) {
  final sensor = _normaliseDegrees(sensorOrientation);
  final device = switch (deviceOrientation) {
    DeviceOrientation.portraitUp => 0,
    DeviceOrientation.landscapeLeft => 90,
    DeviceOrientation.portraitDown => 180,
    DeviceOrientation.landscapeRight => 270,
  };

  final rotation = lensDirection == CameraLensDirection.front
      ? sensor + device
      : sensor - device;
  return _normaliseDegrees(rotation);
}

/// Rounds to the nearest quarter turn and keeps the result in [0, 360).
///
/// Some Android sensors report values like 270; a few report a value already
/// offset by the device. Snapping here keeps [InputImageRotation] valid.
int _normaliseDegrees(int degrees) {
  final wrapped = ((degrees % 360) + 360) % 360;
  return ((wrapped + 45) ~/ 90 % 4) * 90;
}
