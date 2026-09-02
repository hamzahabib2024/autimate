import 'ai_contracts.dart';

/// Turns an [ExpressionReading] into a labelled, explainable guess.
///
/// **Why rules and not a model.** The scope defers a multi-class emotion
/// classifier and forbids black boxes, and that is the right call twice
/// over. A neural classifier here would need training data of autistic
/// children's faces, would encode whatever bias that data carried, and
/// would give a caregiver a number with no account of itself. These rules
/// can be read, argued with, and corrected by the person using them.
///
/// **What this is not.** It reports what a *face is doing* — a mouth curved
/// upward, eyes wide — never what a child is feeling. The distinction is the
/// whole ethical basis of the feature: the scope's own wording is
/// "a practice signal, not a claim about a person's true emotional state",
/// and autistic expression frequently does not map onto neurotypical
/// readings anyway. Every label here is phrased as an appearance.
///
/// ML Kit supplies only three usable signals — smile probability, per-eye
/// openness, and head roll — so the honest ceiling is a handful of coarse
/// classes plus [ExpressionLabel.unclear], which is a real answer and often
/// the correct one.
enum ExpressionLabel {
  /// Mouth clearly curved upward.
  smiling,

  /// Face present, expression close to rest.
  neutral,

  /// Eyes unusually wide — reads as surprise on a neutral mouth.
  wideEyed,

  /// Eyes closed or nearly so.
  eyesClosed,

  /// Head rolled far enough that the readings are unreliable.
  headTilted,

  /// A face is present but the signals do not separate.
  unclear,

  /// Nothing to read.
  noFace,
}

/// A label with the numbers that produced it.
class ExpressionAssessment {
  const ExpressionAssessment({
    required this.label,
    required this.confidence,
    required this.reason,
  });

  final ExpressionLabel label;

  /// 0..1. Deliberately conservative — this drives encouragement, and an
  /// overstated number invites a caregiver to read more into it than is
  /// there.
  final double confidence;

  /// Plain-language account of which signal decided it. Surfaced to
  /// caregivers so the result is never unexplained.
  final String reason;
}

/// Thresholds, gathered so they can be tuned and tested in one place.
class ExpressionClassifierConfig {
  const ExpressionClassifierConfig({
    this.smileHigh = 0.70,
    this.smileLow = 0.30,
    this.eyeClosed = 0.25,
    this.eyeWide = 0.92,
    this.tiltDegrees = 22.0,
  });

  final double smileHigh;
  final double smileLow;
  final double eyeClosed;
  final double eyeWide;
  final double tiltDegrees;
}

/// Rule-based, order-sensitive classifier.
///
/// The order is the design: unreadable conditions are ruled out *before*
/// any expression is claimed. A tilted head or shut eyes make the smile
/// probability unreliable, so reporting "smiling" from them would be
/// asserting something the data does not support.
class ExpressionClassifier {
  const ExpressionClassifier({
    this.config = const ExpressionClassifierConfig(),
  });

  final ExpressionClassifierConfig config;

  static const String version = 'rules-1.0';

  ExpressionAssessment classify(ExpressionReading reading) {
    if (!reading.faceDetected) {
      return const ExpressionAssessment(
        label: ExpressionLabel.noFace,
        confidence: 1,
        reason: 'No face in view.',
      );
    }

    final tilt = reading.headTiltDegrees.abs();
    if (tilt >= config.tiltDegrees) {
      return ExpressionAssessment(
        label: ExpressionLabel.headTilted,
        confidence: _ramp(tilt, config.tiltDegrees, config.tiltDegrees * 2),
        reason: 'Head is tilted about ${tilt.round()} degrees, '
            'so the reading is unreliable.',
      );
    }

    final openness = (reading.leftEyeOpen + reading.rightEyeOpen) / 2;
    if (openness <= config.eyeClosed) {
      return ExpressionAssessment(
        label: ExpressionLabel.eyesClosed,
        confidence: _ramp(config.eyeClosed - openness, 0, config.eyeClosed),
        reason: 'Eyes look closed.',
      );
    }

    if (reading.smile >= config.smileHigh) {
      return ExpressionAssessment(
        label: ExpressionLabel.smiling,
        confidence: _ramp(reading.smile, config.smileHigh, 1.0),
        reason: 'Mouth is curved upward '
            '(${(reading.smile * 100).round()}%).',
      );
    }

    // Wide eyes only mean anything on a mouth that is not smiling; a broad
    // grin raises eye openness too.
    if (openness >= config.eyeWide && reading.smile <= config.smileLow) {
      return ExpressionAssessment(
        label: ExpressionLabel.wideEyed,
        confidence: _ramp(openness, config.eyeWide, 1.0),
        reason: 'Eyes are wide open with a level mouth.',
      );
    }

    if (reading.smile <= config.smileLow) {
      return ExpressionAssessment(
        label: ExpressionLabel.neutral,
        confidence: _ramp(config.smileLow - reading.smile, 0, config.smileLow),
        reason: 'Mouth is close to level.',
      );
    }

    return ExpressionAssessment(
      label: ExpressionLabel.unclear,
      confidence: 0.3,
      reason: 'The signals do not point one way. That is a normal result.',
    );
  }

  /// Linear 0..1 ramp, floored at 0.5 so a decided label never reports
  /// less confidence than a coin toss.
  double _ramp(double value, double low, double high) {
    if (high <= low) return 0.5;
    final t = ((value - low) / (high - low)).clamp(0.0, 1.0);
    return (0.5 + 0.5 * t).clamp(0.0, 1.0);
  }
}
