import 'dart:typed_data';

import 'package:camera/camera.dart' show CameraLensDirection, ImageFormatGroup;
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:autimate/features/ai/data/frame_conversion.dart';

void main() {
  CameraFrame frame({
    ImageFormatGroup group = ImageFormatGroup.nv21,
    Object? rawFormat = 17,
    int width = 640,
    int height = 480,
    int bytesPerRow = 640,
    int sensorOrientation = 90,
    DeviceOrientation deviceOrientation = DeviceOrientation.portraitUp,
    CameraLensDirection lensDirection = CameraLensDirection.back,
    Uint8List? bytes,
  }) => CameraFrame(
    bytes: bytes ?? Uint8List(16),
    width: width,
    height: height,
    bytesPerRow: bytesPerRow,
    formatGroup: group,
    rawFormat: rawFormat,
    sensorOrientation: sensorOrientation,
    deviceOrientation: deviceOrientation,
    lensDirection: lensDirection,
  );

  group('inputFormatFor', () {
    test('accepts only the requested single-plane format', () {
      expect(inputFormatFor(ImageFormatGroup.nv21, 17), InputImageFormat.nv21);
      expect(
        inputFormatFor(ImageFormatGroup.bgra8888, 1111970369),
        InputImageFormat.bgra8888,
      );
    });

    test('rejects mismatched or multi-plane formats', () {
      expect(inputFormatFor(ImageFormatGroup.nv21, 1111970369), isNull);
      expect(inputFormatFor(ImageFormatGroup.nv21, 35), isNull);
      expect(inputFormatFor(ImageFormatGroup.bgra8888, 17), isNull);
      expect(inputFormatFor(ImageFormatGroup.yuv420, 35), isNull);
      expect(inputFormatFor(ImageFormatGroup.unknown, 17), isNull);
      expect(inputFormatFor(ImageFormatGroup.nv21, null), isNull);
      expect(inputFormatFor(ImageFormatGroup.nv21, '17'), isNull);
      expect(inputFormatFor(ImageFormatGroup.nv21, 999), isNull);
    });
  });

  group('rotationDegreesFor', () {
    test('back camera subtracts device rotation', () {
      const sensor = 90;
      const back = CameraLensDirection.back;
      expect(
        rotationDegreesFor(
          sensorOrientation: sensor,
          deviceOrientation: DeviceOrientation.portraitUp,
          lensDirection: back,
        ),
        90,
      );
      expect(
        rotationDegreesFor(
          sensorOrientation: sensor,
          deviceOrientation: DeviceOrientation.landscapeLeft,
          lensDirection: back,
        ),
        0,
      );
      expect(
        rotationDegreesFor(
          sensorOrientation: sensor,
          deviceOrientation: DeviceOrientation.portraitDown,
          lensDirection: back,
        ),
        270,
      );
      expect(
        rotationDegreesFor(
          sensorOrientation: sensor,
          deviceOrientation: DeviceOrientation.landscapeRight,
          lensDirection: back,
        ),
        180,
      );
    });

    test('front camera adds device rotation', () {
      const sensor = 90;
      const front = CameraLensDirection.front;
      expect(
        rotationDegreesFor(
          sensorOrientation: sensor,
          deviceOrientation: DeviceOrientation.portraitUp,
          lensDirection: front,
        ),
        90,
      );
      expect(
        rotationDegreesFor(
          sensorOrientation: sensor,
          deviceOrientation: DeviceOrientation.landscapeLeft,
          lensDirection: front,
        ),
        180,
      );
      expect(
        rotationDegreesFor(
          sensorOrientation: sensor,
          deviceOrientation: DeviceOrientation.portraitDown,
          lensDirection: front,
        ),
        270,
      );
      expect(
        rotationDegreesFor(
          sensorOrientation: sensor,
          deviceOrientation: DeviceOrientation.landscapeRight,
          lensDirection: front,
        ),
        0,
      );
    });

    test('wraps and snaps out-of-range sensor values', () {
      expect(
        rotationDegreesFor(
          sensorOrientation: 450,
          deviceOrientation: DeviceOrientation.portraitUp,
          lensDirection: CameraLensDirection.back,
        ),
        90,
      );
      expect(
        rotationDegreesFor(
          sensorOrientation: 270,
          deviceOrientation: DeviceOrientation.portraitUp,
          lensDirection: CameraLensDirection.back,
        ),
        270,
      );
      expect(
        rotationDegreesFor(
          sensorOrientation: -90,
          deviceOrientation: DeviceOrientation.portraitUp,
          lensDirection: CameraLensDirection.back,
        ),
        270,
      );
    });
  });

  group('inputImageFromFrame', () {
    test('builds metadata with the resolved rotation and format', () {
      final image = inputImageFromFrame(frame());

      expect(image, isNotNull);
      expect(image!.metadata!.format, InputImageFormat.nv21);
      expect(image.metadata!.rotation, InputImageRotation.rotation90deg);
      expect(image.metadata!.size.width, 640);
      expect(image.metadata!.size.height, 480);
      expect(image.metadata!.bytesPerRow, 640);
    });

    test('rejects malformed or unusable frames', () {
      expect(inputImageFromFrame(frame(bytes: Uint8List(0))), isNull);
      expect(inputImageFromFrame(frame(width: 0)), isNull);
      expect(inputImageFromFrame(frame(height: -1)), isNull);
      expect(inputImageFromFrame(frame(bytesPerRow: 0)), isNull);
      expect(inputImageFromFrame(frame(rawFormat: 35)), isNull);
      expect(
        inputImageFromFrame(
          frame(group: ImageFormatGroup.nv21, rawFormat: 1111970369),
        ),
        isNull,
      );
    });
  });
}
