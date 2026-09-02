import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/features/ai/data/rule_based_ai_engine.dart';
import 'package:autimate/features/ai/data/simulated_expression_service.dart';
import 'package:autimate/features/ai/domain/ai_contracts.dart';
import 'package:autimate/features/ai/domain/expression_classifier.dart';
import 'package:autimate/features/ai/domain/expression_practice_engine.dart';

ExpressionReading _reading({
  bool face = true,
  double smile = 0.5,
  double leftEye = 0.9,
  double rightEye = 0.9,
  double tilt = 0,
}) => ExpressionReading(
  faceDetected: face,
  smile: smile,
  leftEyeOpen: leftEye,
  rightEyeOpen: rightEye,
  headTiltDegrees: tilt,
);

void main() {
  const classifier = ExpressionClassifier();

  group('ExpressionClassifier', () {
    test('no face is reported as such, with full confidence', () {
      final result = classifier.classify(_reading(face: false));
      expect(result.label, ExpressionLabel.noFace);
      expect(result.confidence, 1);
    });

    test('a clear smile is recognised', () {
      final result = classifier.classify(_reading(smile: 0.9));
      expect(result.label, ExpressionLabel.smiling);
      expect(result.confidence, greaterThan(0.5));
      expect(result.reason, contains('90%'));
    });

    test('a level mouth reads as neutral', () {
      expect(
        classifier.classify(_reading(smile: 0.05)).label,
        ExpressionLabel.neutral,
      );
    });

    test('closed eyes are reported before any expression is claimed', () {
      // Even with a high smile score, shut eyes make the reading
      // unreliable — asserting "smiling" here would overstate the data.
      final result =
          classifier.classify(_reading(smile: 0.95, leftEye: 0.05, rightEye: 0.05));
      expect(result.label, ExpressionLabel.eyesClosed);
    });

    test('a tilted head outranks everything else', () {
      final result = classifier.classify(
        _reading(smile: 0.95, leftEye: 0.05, rightEye: 0.05, tilt: 40),
      );
      expect(result.label, ExpressionLabel.headTilted);
      expect(result.reason, contains('unreliable'));
    });

    test('tilt is symmetric — leaning either way is equally unreadable', () {
      expect(
        classifier.classify(_reading(tilt: -35)).label,
        ExpressionLabel.headTilted,
      );
      expect(
        classifier.classify(_reading(tilt: 35)).label,
        ExpressionLabel.headTilted,
      );
    });

    test('wide eyes only count on a mouth that is not smiling', () {
      expect(
        classifier
            .classify(_reading(smile: 0.1, leftEye: 0.97, rightEye: 0.97))
            .label,
        ExpressionLabel.wideEyed,
      );
      // A broad grin also widens the eyes, so it must not be misread.
      expect(
        classifier
            .classify(_reading(smile: 0.9, leftEye: 0.97, rightEye: 0.97))
            .label,
        ExpressionLabel.smiling,
      );
    });

    test('an in-between face is reported as unclear, not guessed at', () {
      final result = classifier.classify(_reading(smile: 0.5));
      expect(result.label, ExpressionLabel.unclear);
      expect(result.confidence, lessThan(0.5));
      expect(result.reason, contains('normal result'));
    });

    test('every outcome carries a plain-language reason', () {
      for (final reading in [
        _reading(face: false),
        _reading(smile: 0.95),
        _reading(smile: 0.05),
        _reading(leftEye: 0.05, rightEye: 0.05),
        _reading(tilt: 40),
        _reading(smile: 0.1, leftEye: 0.98, rightEye: 0.98),
        _reading(smile: 0.5),
      ]) {
        final result = classifier.classify(reading);
        expect(result.reason, isNotEmpty);
        expect(result.confidence, inInclusiveRange(0.0, 1.0));
      }
    });

    test('no label claims to know what the child feels', () {
      // The ethical line the scope draws: this reports what a face is
      // doing, never an inner state. Guard it in code so a future rename
      // cannot quietly cross it.
      const feelings = [
        'happy', 'sad', 'angry', 'afraid', 'scared',
        'excited', 'upset', 'anxious', 'feeling',
      ];
      for (final label in ExpressionLabel.values) {
        for (final feeling in feelings) {
          expect(
            label.name.toLowerCase(),
            isNot(contains(feeling)),
            reason: '"${label.name}" names an emotion, not an appearance',
          );
        }
      }
    });
  });

  group('RuleBasedAiEngine', () {
    late RuleBasedAiEngine engine;

    setUp(() => engine = RuleBasedAiEngine());

    test('initialise makes it ready, dispose makes it not', () async {
      expect(engine.isReady, isFalse);
      await engine.initialise();
      expect(engine.isReady, isTrue);
      await engine.dispose();
      expect(engine.isReady, isFalse);
    });

    test('predicts a real label — no placeholder remains', () async {
      await engine.initialise();
      final result = await engine.predict(_reading(smile: 0.9));
      expect(result.label, 'smiling');
      expect(result.label, isNot('not_implemented'));
      expect(result.confidence, greaterThan(0));
      expect(result.modelVersion, ExpressionClassifier.version);
    });

    test('a wrong input type is reported, never thrown', () async {
      // This runs inside a camera frame callback; an exception there would
      // kill the stream rather than one frame.
      await engine.initialise();
      final result = await engine.predict('not a reading');
      expect(result.label, 'unsupported_input');
      expect(result.confidence, 0);
    });

    test('assess exposes the reasoning, not just the label', () async {
      final assessment = engine.assess(_reading(smile: 0.85));
      expect(assessment.label, ExpressionLabel.smiling);
      expect(assessment.reason, isNotEmpty);
    });

    test('works before initialise — no hidden ordering requirement', () async {
      final result = await engine.predict(_reading(smile: 0.9));
      expect(result.label, 'smiling');
    });
  });

  group('practice pipeline end to end', () {
    test('a simulated session drives the engine to completion', () async {
      final service = SimulatedExpressionService(
        period: const Duration(milliseconds: 400),
      );
      expect(await service.isSupported(), isTrue);

      var now = DateTime(2026, 3, 1);
      final engine = ExpressionSessionEngine(
        config: const ExpressionPracticeConfig(
          // The EMA lags the ramp, so the default 0.75 threshold is not
          // reachable inside this short window. The point under test is
          // the wiring, not the tuning.
          smileThreshold: 0.45,
          holdDuration: Duration(milliseconds: 100),
          minFrameInterval: Duration(milliseconds: 10),
          repsTarget: 2,
        ),
        clock: () => now,
      );

      final stream = service.start();
      final feedback = <ExpressionFeedback>[];
      final sub = stream.listen((reading) {
        now = now.add(const Duration(milliseconds: 60));
        feedback.add(engine.feed(reading));
      });

      await Future<void>.delayed(const Duration(milliseconds: 900));
      await sub.cancel();
      await service.stop();

      expect(feedback, isNotEmpty,
          reason: 'the simulated source must actually drive the engine');
      expect(feedback.any((f) => f.faceDetected), isTrue);
      expect(engine.smoothedSmile, greaterThan(0));
      // The ramp crosses the threshold, so at least one hold should land.
      expect(feedback.any((f) => f.holding || f.starAwarded), isTrue);
    });

    test('the simulated source stops cleanly and can restart', () async {
      final service = SimulatedExpressionService();
      final first = service.start();
      final sub = first.listen((_) {});
      await service.stop();
      await sub.cancel();

      // Restarting must not throw on a closed controller.
      final second = service.start();
      final sub2 = second.listen((_) {});
      await service.stop();
      await sub2.cancel();
    });
  });

  group('camera permission contract', () {
    test('the always-grant source stays available for demos', () async {
      const service = AutoGrantCameraPermissions();
      expect(await service.status(), CameraPermissionStatus.granted);
      expect(await service.request(), CameraPermissionStatus.granted);
    });

    test('permanently denied is distinct from denied', () {
      // The distinction the UI depends on: re-prompting after a permanent
      // denial does nothing, so the app must offer settings instead.
      expect(
        CameraPermissionStatus.permanentlyDenied,
        isNot(CameraPermissionStatus.denied),
      );
      expect(CameraPermissionStatus.values, hasLength(4));
    });
  });
}
