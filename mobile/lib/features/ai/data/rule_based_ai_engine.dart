import '../domain/ai_contracts.dart';
import '../domain/expression_classifier.dart';

/// The app's working [AiEngine].
///
/// It replaces the earlier placeholder that returned `not_implemented` for
/// every input. That stub was honest about being unfinished but left the
/// contract untested and unusable, and an interface nothing implements is
/// an interface nobody can trust.
///
/// This one runs [ExpressionClassifier] over an [ExpressionReading] and
/// returns a real label, a real confidence, and a version string. No model
/// file, no download, no network — which keeps the offline-first guarantee
/// intact and means there is no bias baked into weights nobody here can
/// inspect.
///
/// If a trained classifier ever arrives, it implements this same interface
/// and nothing upstream changes. That was the point of the boundary.
class RuleBasedAiEngine implements AiEngine {
  RuleBasedAiEngine({
    this.classifier = const ExpressionClassifier(),
  });

  final ExpressionClassifier classifier;
  bool _ready = false;

  bool get isReady => _ready;

  @override
  Future<void> initialise() async {
    // Nothing to load. Stated rather than left as an empty body, because
    // "no initialisation needed" and "initialisation forgotten" look
    // identical otherwise.
    _ready = true;
  }

  @override
  Future<PredictionResult> predict(Object input) async {
    if (input is! ExpressionReading) {
      // A wrong input type is a programming error, not a user-facing one.
      // Report it as an explicit label rather than throwing into a camera
      // frame callback, where an exception would kill the stream.
      return const PredictionResult(
        label: 'unsupported_input',
        confidence: 0,
        modelVersion: ExpressionClassifier.version,
      );
    }
    final assessment = classifier.classify(input);
    return PredictionResult(
      label: assessment.label.name,
      confidence: assessment.confidence,
      modelVersion: ExpressionClassifier.version,
    );
  }

  /// The classification with its plain-language reason attached.
  ///
  /// [predict] satisfies the generic contract; this is what the caregiver
  /// UI should call, because a label with no account of itself is exactly
  /// the black box this project rules out.
  ExpressionAssessment assess(ExpressionReading reading) =>
      classifier.classify(reading);

  @override
  Future<void> dispose() async {
    _ready = false;
  }
}
