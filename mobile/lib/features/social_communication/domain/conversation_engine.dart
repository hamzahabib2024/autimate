import 'social_models.dart';

/// Outcome of choosing a reply in a scripted conversation.
class ConversationOutcome {
  const ConversationOutcome({
    required this.advanced,
    required this.completed,
    this.nextStep,
  });

  /// True when the reply was fitting and the script moved forward.
  final bool advanced;

  /// True when the script reached its final step.
  final bool completed;
  final ConversationStep? nextStep;
}

/// Deterministic walker for fixed branching conversation scripts.
///
/// Fitting replies advance; safe-but-unexpected replies stay on the same
/// step so the child can try again. There is no failure state and no
/// free-form input anywhere in the flow.
class ConversationEngine {
  ConversationEngine({required ConversationScript script})
    : _script = script,
      _current = script.stepById(script.startStepId);

  final ConversationScript _script;
  ConversationStep? _current;
  int _triesOnCurrentStep = 0;

  bool get completed => _current == null;
  ConversationStep? get current => _current;

  /// Number of gentle retries taken on the current step (reset on advance).
  int get triesOnCurrentStep => _triesOnCurrentStep;

  void reset() {
    _current = _script.stepById(_script.startStepId);
    _triesOnCurrentStep = 0;
  }

  ConversationOutcome choose(ConversationOption option) {
    if (_current == null) {
      return const ConversationOutcome(
        advanced: false,
        completed: true,
      );
    }
    if (!option.encouraging) {
      _triesOnCurrentStep++;
      return ConversationOutcome(advanced: false, completed: false, nextStep: _current);
    }
    if (option.nextStepId == 'end') {
      final finishedStep = _current;
      _current = null;
      return ConversationOutcome(advanced: true, completed: true, nextStep: finishedStep);
    }
    final next = _script.stepById(option.nextStepId) ?? _current;
    _current = next;
    _triesOnCurrentStep = 0;
    return ConversationOutcome(advanced: true, completed: false, nextStep: next);
  }
}
