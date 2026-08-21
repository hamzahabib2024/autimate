import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/ai/domain/ai_contracts.dart';
import 'package:autimate/features/ai/domain/expression_practice_engine.dart';
import 'package:autimate/features/emotion_recognition/presentation/expression_screen.dart';

import 'helpers/test_app.dart';

class FakeExpressionService implements ExpressionPracticeService {
  final StreamController<ExpressionReading> controller =
      StreamController<ExpressionReading>.broadcast();
  bool supported = true;
  int starts = 0;
  int stops = 0;

  @override
  Future<bool> isSupported() async => supported;

  @override
  Stream<ExpressionReading> start() {
    starts++;
    return controller.stream;
  }

  @override
  Future<void> stop() async {
    stops++;
  }
}

class ScriptedPermissions implements CameraPermissionService {
  ScriptedPermissions(this._status);

  CameraPermissionStatus _status;
  int requests = 0;

  @override
  Future<CameraPermissionStatus> status() async => _status;

  @override
  Future<CameraPermissionStatus> request() async {
    requests++;
    // Grant on request, like a caregiver accepting the OS prompt.
    _status = CameraPermissionStatus.granted;
    return _status;
  }
}

void main() {
  AppState appState() => AppState(MockAuthRepository(), MockTtsService());

  /// Engine whose clock advances one frame interval per feed so every
  /// reading is accepted and holds resolve deterministically.
  ExpressionSessionEngine tickingEngine({int repsTarget = 3}) {
    var ticks = 0;
    return ExpressionSessionEngine(
      config: ExpressionPracticeConfig(repsTarget: repsTarget),
      clock: () => DateTime(2026, 8, 22, 10)
          .add(Duration(milliseconds: 100 * ticks++)),
    );
  }

  Future<void> startPractice(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(testApp(screen));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start practice'));
    await tester.pumpAndSettle();
  }

  group('camera permission flow', () {
    testWidgets('rationale dialog explains, deny lands in denied state',
        (tester) async {
      final permissions = ScriptedPermissions(CameraPermissionStatus.denied);
      final service = FakeExpressionService();
      await tester.pumpWidget(
        testApp(
          ExpressionPracticeScreen(
            appState: appState(),
            service: service,
            permissions: permissions,
          ),
        ),
      );
      // The checking-phase spinner never settles; pump fixed durations.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Why the camera?'), findsOneWidget);
      expect(find.textContaining('never saved or uploaded'), findsOneWidget);

      // Opting out parks the user on the denied panel with a retry path.
      await tester.tap(find.byKey(const ValueKey('permission-not-now')));
      await tester.pumpAndSettle();

      expect(permissions.requests, 0);
      expect(
        find.byKey(const ValueKey('permission-denied-panel')),
        findsOneWidget,
      );

      // Retry opens the rationale again; allowing grants and reaches start.
      await tester.tap(find.text('Allow camera'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const ValueKey('permission-allow')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('permission-allow')));
      await tester.pumpAndSettle();

      expect(permissions.requests, 1);
      expect(find.text('Start practice'), findsOneWidget);
    });

    testWidgets('unsupported permission status skips the dialog',
        (tester) async {
      final permissions = ScriptedPermissions(
        CameraPermissionStatus.unsupported,
      );
      await tester.pumpWidget(
        testApp(
          ExpressionPracticeScreen(
            appState: appState(),
            service: FakeExpressionService(),
            permissions: permissions,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Why the camera?'), findsNothing);
      expect(
        find.byKey(const ValueKey('permission-denied-panel')),
        findsOneWidget,
      );
    });
  });

  group('camera lifecycle', () {
    testWidgets('backgrounding stops the camera; resuming keeps progress', (
      tester,
    ) async {
      final service = FakeExpressionService();
      final state = appState();
      final starsBefore = state.stars;
      final engine = tickingEngine(repsTarget: 2);

      await startPractice(
        tester,
        ExpressionPracticeScreen(
          appState: state,
          service: service,
          engine: engine,
        ),
      );

      // Complete rep one.
      for (var i = 0; i < 12; i++) {
        service.controller.add(_reading(0.9));
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();
      expect(find.text('1 of 2 smiles held'), findsOneWidget);

      // App goes to background: the camera must stop immediately while
      // the practice UI stays put.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(service.stops, greaterThanOrEqualTo(1));
      expect(find.text('Hold a big smile for one second'), findsOneWidget);

      // Returning to the foreground reattaches the same session.
      final stopsBeforeResume = service.stops;
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(milliseconds: 50));

      expect(service.starts, 2);
      expect(service.stops, stopsBeforeResume);

      // Progress survived the pause: one more rep completes at 2 stars.
      for (var i = 0; i < 12; i++) {
        service.controller.add(_reading(0.9));
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      expect(find.text('Great smiling! 2 stars earned'), findsOneWidget);
      expect(state.stars, starsBefore + 2);
    });

    testWidgets('dispose stops the camera exactly once more', (tester) async {
      final service = FakeExpressionService();
      final screen = ExpressionPracticeScreen(
        appState: appState(),
        service: service,
        engine: tickingEngine(),
      );
      await startPractice(tester, screen);

      final stopsBefore = service.stops;
      await tester.pumpWidget(const SizedBox.shrink());
      expect(service.stops, greaterThan(stopsBefore));
    });
  });

  group('posture feedback', () {
    testWidgets('eyes, tilt, and lost-face hints surface from readings', (
      tester,
    ) async {
      final service = FakeExpressionService();
      await startPractice(
        tester,
        ExpressionPracticeScreen(
          appState: appState(),
          service: service,
          engine: tickingEngine(),
        ),
      );

      // Closed eyes win over everything else.
      service.controller.add(_reading(0.9, leftEye: 0.05, rightEye: 0.05));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(find.text('Try opening your eyes'), findsOneWidget);

      // A tilted head switches the hint.
      service.controller.add(_reading(0.9, headTilt: 25));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(find.text('Look straight at the camera'), findsOneWidget);

      // Losing the face asks the child to come closer.
      service.controller.add(_reading(0.9, faceDetected: false));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(find.text('Come closer to the camera'), findsOneWidget);
    });
  });

  group('engine posture fields', () {
    test('eyesClosed follows the probability floor on both eyes', () {
      final engine = ExpressionSessionEngine(clock: () => DateTime(2026));
      var feedback = engine.feed(_reading(0.9, leftEye: 0.29, rightEye: 0.29));
      expect(feedback.eyesClosed, isTrue);

      engine.restart();
      feedback = engine.feed(_reading(0.9, leftEye: 0.31, rightEye: 0.29));
      expect(feedback.eyesClosed, isFalse);
    });

    test('headTiltedDeg passes through signed tilt degrees', () {
      final engine = ExpressionSessionEngine(clock: () => DateTime(2026));
      final feedback = engine.feed(_reading(0.2, headTilt: -24));
      expect(feedback.headTiltedDeg, -24);
      expect(
        feedback.headTiltedDeg.abs(),
        greaterThan(ExpressionSessionEngine.headTiltThresholdDeg),
      );
    });
  });
}

ExpressionReading _reading(
  double smile, {
  bool faceDetected = true,
  double leftEye = 0.9,
  double rightEye = 0.9,
  double headTilt = 0,
}) =>
    ExpressionReading(
      faceDetected: faceDetected,
      smile: smile,
      leftEyeOpen: leftEye,
      rightEyeOpen: rightEye,
      headTiltDegrees: headTilt,
    );
