import 'emotion_activity_engine.dart';

abstract interface class AdaptiveLevelController {
  SupportLevel evaluate({
    required SupportLevel current,
    required List<bool> recentOutcomes,
    required bool parentLocked,
    SupportLevel? parentOverride,
  });
}

class RuleBasedAdaptiveLevelController implements AdaptiveLevelController {
  @override
  SupportLevel evaluate({
    required SupportLevel current,
    required List<bool> recentOutcomes,
    required bool parentLocked,
    SupportLevel? parentOverride,
  }) {
    if (parentOverride != null) return parentOverride;
    if (parentLocked || recentOutcomes.isEmpty) return current;
    if (recentOutcomes.length >= 3 &&
        recentOutcomes
            .sublist(recentOutcomes.length - 3)
            .every((value) => value)) {
      return SupportLevel.values[(current.index + 1).clamp(
        0,
        SupportLevel.values.length - 1,
      )];
    }
    if (recentOutcomes.length >= 2 &&
        recentOutcomes
            .sublist(recentOutcomes.length - 2)
            .every((value) => !value)) {
      return SupportLevel.values[(current.index - 1).clamp(
        0,
        SupportLevel.values.length - 1,
      )];
    }
    return current;
  }
}
