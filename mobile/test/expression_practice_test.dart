import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/features/ai/domain/ai_contracts.dart';
import 'package:autimate/features/ai/domain/expression_practice_engine.dart';

void main() {
  group('SmileEmaSmoother', () {
    test('first reading primes and later readings apply alpha 0.3', () {
      final smoother = SmileEmaSmoother(alpha: 0.3);
      expect(smoother.smooth(0.5), closeTo(0.5, 0.0001));
      expect(smoother.smooth(1.0), closeTo(0.3 * 1.0 + 0.7 * 0.5, 0.0001));
      smoother.reset();
      expect(smoother.value, 0);
      expect(smoother.smooth(0.4), closeTo(0.4, 0.0001));
    });
  });

  group('FrameThrottle', () {
    test('rejects while busy and before the minimum interval', () {
      final throttle = FrameThrottle(minInterval: const Duration(milliseconds: 100));
      final start = DateTime(2026, 8, 22, 10);

      expect(throttle.beginFrame(start), isTrue);
      expect(throttle.busy, isTrue);
      expect(throttle.beginFrame(start.add(const Duration(milliseconds: 10))),
          isFalse, reason: 'still busy');
      throttle.endFrame();
      expect(throttle.beginFrame(start.add(const Duration(milliseconds: 50))),
          isFalse, reason: 'too soon after last accepted frame');
      expect(throttle.beginFrame(start.add(const Duration(milliseconds: 100))),
          isTrue, reason: 'interval elapsed');
    });
  });

  group('ExpressionSessionEngine', () {
    test('one second of sustained smile awards exactly one star', () async {
      var ticks = 0;
      final engine = ExpressionSessionEngine(
        clock: () => DateTime(2026, 8, 22, 10).add(
          Duration(milliseconds: 100 * ticks++),
        ),
      );

      var awards = 0;
      for (var i = 0; i < 10; i++) {
        final feedback = engine.feed(_reading(0.9));
        if (feedback.starAwarded) awards++;
      }
      expect(engine.starsEarned, 0, reason: 'hold has not reached one second');

      final awardingFeedback = engine.feed(_reading(0.9));
      if (awardingFeedback.starAwarded) awards++;
      expect(awardingFeedback.starAwarded, isTrue);
      expect(awardingFeedback.holding, isFalse, reason: 'hold resets after star');
      expect(awards, 1);
    });

    test('session completes after three held smiles with three stars total',
        () async {
      var ticks = 0;
      final engine = ExpressionSessionEngine(
        clock: () => DateTime(2026, 8, 22, 10).add(
          Duration(milliseconds: 100 * ticks++),
        ),
      );

      var awards = 0;
      ExpressionFeedback? last;
      for (var i = 0; i < 40 && !(last?.sessionComplete ?? false); i++) {
        last = engine.feed(_reading(0.9));
        if (last.starAwarded) awards++;
      }

      expect(awards, 3);
      expect(last!.starsEarned, 3);
      expect(last.sessionComplete, isTrue);
      expect(engine.sessionComplete, isTrue);
    });

    test('smile dip below threshold resets an in-progress hold', () async {
      var ticks = 0;
      final engine = ExpressionSessionEngine(
        clock: () => DateTime(2026, 8, 22, 10).add(
          Duration(milliseconds: 100 * ticks++),
        ),
      );

      // Build a hold for half a second.
      for (var i = 0; i < 6; i++) {
        engine.feed(_reading(0.9));
      }
      // Drop the smile: smoothed value falls below the threshold.
      final dipped = engine.feed(_reading(0.1));
      expect(dipped.holding, isFalse);

      // EMA needs a few frames to climb back above the threshold, and a
      // full second must pass again before any star: none of these award.
      var awards = 0;
      for (var i = 0; i < 11; i++) {
        final feedback = engine.feed(_reading(0.9));
        if (feedback.starAwarded) awards++;
      }
      expect(awards, 0);
      final late = engine.feed(_reading(0.9));
      expect(late.starAwarded, isTrue);
      expect(engine.starsEarned, 1);
    });

    test('lost face cancels the current hold', () async {
      var ticks = 0;
      final engine = ExpressionSessionEngine(
        clock: () => DateTime(2026, 8, 22, 10).add(
          Duration(milliseconds: 100 * ticks++),
        ),
      );

      for (var i = 0; i < 6; i++) {
        engine.feed(_reading(0.9));
      }
      final lost = engine.feed(_noFace());
      expect(lost.faceDetected, isFalse);
      expect(lost.holding, isFalse);

      var awards = 0;
      // Smile stays high through the smoother, so a new hold starts as soon
      // as frames resume (t=700); a full second later (t>=1700) it pays out.
      for (var i = 0; i < 10; i++) {
        final feedback = engine.feed(_reading(0.9));
        if (feedback.starAwarded) awards++;
      }
      expect(awards, 0);
      final late = engine.feed(_reading(0.9));
      expect(late.starAwarded, isTrue);
      expect(engine.starsEarned, 1);
    });

    test('restart clears stars and completion state', () async {
      var ticks = 0;
      final engine = ExpressionSessionEngine(
        config: const ExpressionPracticeConfig(repsTarget: 1),
        clock: () => DateTime(2026, 8, 22, 10).add(
          Duration(milliseconds: 100 * ticks++),
        ),
      );

      for (var i = 0; i < 15 && !engine.sessionComplete; i++) {
        engine.feed(_reading(0.9));
      }
      expect(engine.sessionComplete, isTrue);

      engine.restart();
      expect(engine.starsEarned, 0);
      expect(engine.sessionComplete, isFalse);
    });
  });
}

ExpressionReading _reading(double smile) => ExpressionReading(
  faceDetected: true,
  smile: smile,
  leftEyeOpen: 0.9,
  rightEyeOpen: 0.9,
  headTiltDegrees: 0,
);

ExpressionReading _noFace() => ExpressionReading(
  faceDetected: false,
  smile: 0,
  leftEyeOpen: 0,
  rightEyeOpen: 0,
  headTiltDegrees: 0,
);
