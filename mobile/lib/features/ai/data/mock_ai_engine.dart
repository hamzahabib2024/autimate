import '../domain/ai_contracts.dart';

class MockAiEngine implements AiEngine {
  @override
  Future<void> initialise() async {
    // TODO: AI IMPLEMENTATION - load the selected local model here.
  }

  @override
  Future<PredictionResult> predict(Object input) async {
    // TODO: AI IMPLEMENTATION - preprocess, infer, and postprocess input.
    return const PredictionResult(
      label: 'not_implemented',
      confidence: 0,
      modelVersion: 'placeholder',
    );
  }

  @override
  Future<void> dispose() async {}
}
