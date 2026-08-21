import 'dart:math';

import 'adaptive_level_controller.dart';

enum EmotionLabel { happy, sad, angry, surprised, scared, neutral }

enum SupportLevel { beginner, intermediate, advanced }

class EmotionQuestion {
  const EmotionQuestion({
    required this.assetKey,
    required this.answer,
    required this.choices,
    required this.hintVisible,
    required this.index,
    required this.total,
  });

  final String assetKey;
  final EmotionLabel answer;
  final List<EmotionLabel> choices;
  final bool hintVisible;
  final int index;
  final int total;
}

class AnswerOutcome {
  const AnswerOutcome({
    required this.correct,
    required this.picked,
    required this.answer,
    required this.showHintNext,
  });

  final bool correct;
  final EmotionLabel picked;
  final EmotionLabel answer;
  final bool showHintNext;
}

class SessionResult {
  const SessionResult({
    required this.childId,
    required this.activityType,
    required this.score,
    required this.total,
    required this.levelPlayed,
    required this.levelAfter,
    required this.duration,
    required this.completedAt,
    required this.starsAwarded,
  });

  final String childId;
  final String activityType;
  final int score;
  final int total;
  final SupportLevel levelPlayed;
  final SupportLevel levelAfter;
  final Duration duration;
  final DateTime completedAt;
  final int starsAwarded;
}

abstract interface class EmotionActivityEngine {
  EmotionQuestion start({required SupportLevel level, int questionCount = 5});
  AnswerOutcome submit(EmotionLabel picked);
  EmotionQuestion? next();
  SessionResult finish();
}

class DeterministicEmotionActivityEngine implements EmotionActivityEngine {
  DeterministicEmotionActivityEngine({
    required this.childId,
    AdaptiveLevelController? adaptiveController,
    this.parentLocked = false,
    this.parentOverride,
    Random? random,
    DateTime Function()? clock,
  }) : _random = random ?? Random(7),
       _clock = clock ?? DateTime.now,
       _adaptiveController =
           adaptiveController ?? RuleBasedAdaptiveLevelController();

  String childId;
  final bool parentLocked;
  final SupportLevel? parentOverride;
  final Random _random;
  final DateTime Function() _clock;
  final AdaptiveLevelController _adaptiveController;

  /// Re-points future session records when the active profile changes.
  void updateChildId(String id) => childId = id;
  SupportLevel _level = SupportLevel.beginner;
  int _total = 5;
  int _index = 0;
  int _score = 0;
  DateTime? _startedAt;
  EmotionQuestion? _current;
  final List<bool> _answers = [];
  final Set<EmotionLabel> _usedAnswers = {};

  static const _emotions = EmotionLabel.values;
  static const _confusability = <EmotionLabel, Map<EmotionLabel, double>>{
    EmotionLabel.happy: {
      EmotionLabel.sad: 0.1,
      EmotionLabel.angry: 0.1,
      EmotionLabel.surprised: 0.3,
      EmotionLabel.scared: 0.1,
      EmotionLabel.neutral: 0.4,
    },
    EmotionLabel.sad: {
      EmotionLabel.happy: 0.1,
      EmotionLabel.angry: 0.5,
      EmotionLabel.surprised: 0.1,
      EmotionLabel.scared: 0.6,
      EmotionLabel.neutral: 0.4,
    },
    EmotionLabel.angry: {
      EmotionLabel.happy: 0.1,
      EmotionLabel.sad: 0.5,
      EmotionLabel.surprised: 0.2,
      EmotionLabel.scared: 0.5,
      EmotionLabel.neutral: 0.3,
    },
    EmotionLabel.surprised: {
      EmotionLabel.happy: 0.3,
      EmotionLabel.sad: 0.1,
      EmotionLabel.angry: 0.2,
      EmotionLabel.scared: 0.7,
      EmotionLabel.neutral: 0.2,
    },
    EmotionLabel.scared: {
      EmotionLabel.happy: 0.1,
      EmotionLabel.sad: 0.6,
      EmotionLabel.angry: 0.5,
      EmotionLabel.surprised: 0.7,
      EmotionLabel.neutral: 0.2,
    },
    EmotionLabel.neutral: {
      EmotionLabel.happy: 0.4,
      EmotionLabel.sad: 0.4,
      EmotionLabel.angry: 0.3,
      EmotionLabel.surprised: 0.2,
      EmotionLabel.scared: 0.2,
    },
  };

  @override
  EmotionQuestion start({required SupportLevel level, int questionCount = 5}) {
    _level = level;
    _total = questionCount.clamp(1, 20);
    _index = 1;
    _score = 0;
    _answers.clear();
    _usedAnswers.clear();
    _startedAt = _clock();
    _current = _buildQuestion();
    return _current!;
  }

  @override
  AnswerOutcome submit(EmotionLabel picked) {
    final question = _current;
    if (question == null) throw StateError('Start an emotion session first.');
    final correct = picked == question.answer;
    if (correct) _score++;
    _answers.add(correct);
    return AnswerOutcome(
      correct: correct,
      picked: picked,
      answer: question.answer,
      showHintNext: !correct || question.hintVisible,
    );
  }

  @override
  EmotionQuestion? next() {
    if (_current == null || _answers.length >= _total) return null;
    _index++;
    _current = _buildQuestion();
    return _current;
  }

  @override
  SessionResult finish() {
    if (_startedAt == null) throw StateError('Start an emotion session first.');
    final total = _answers.length;
    final levelAfter = _levelAfterSession();
    return SessionResult(
      childId: childId,
      activityType: 'emotion_identification',
      score: _score,
      total: total,
      levelPlayed: _level,
      levelAfter: levelAfter,
      duration: _clock().difference(_startedAt!),
      completedAt: _clock(),
      starsAwarded: _starsFor(_score, total),
    );
  }

  EmotionQuestion _buildQuestion() {
    final remaining = _emotions
        .where((emotion) => !_usedAnswers.contains(emotion))
        .toList();
    final pool = remaining.isEmpty ? _emotions : remaining;
    final answer = pool[_random.nextInt(pool.length)];
    _usedAnswers.add(answer);
    final choices = _choicesFor(answer);
    return EmotionQuestion(
      assetKey: 'emotion_${answer.name}',
      answer: answer,
      choices: choices,
      hintVisible: _level == SupportLevel.beginner,
      index: _index,
      total: _total,
    );
  }

  List<EmotionLabel> _choicesFor(EmotionLabel answer) {
    final count = switch (_level) {
      SupportLevel.beginner => 2,
      SupportLevel.intermediate => 3,
      SupportLevel.advanced => 4,
    };
    final candidates = _emotions.where((emotion) => emotion != answer).toList()
      ..sort((a, b) {
        final aScore = _confusability[answer]![a]!;
        final bScore = _confusability[answer]![b]!;
        return _level == SupportLevel.beginner
            ? aScore.compareTo(bScore)
            : bScore.compareTo(aScore);
      });
    final choices = [answer, ...candidates.take(count - 1)]..shuffle(_random);
    return choices;
  }

  SupportLevel _levelAfterSession() {
    return _adaptiveController.evaluate(
      current: _level,
      recentOutcomes: _answers,
      parentLocked: parentLocked,
      parentOverride: parentOverride,
    );
  }

  int _starsFor(int score, int total) {
    if (total == 0 || score == 0) return 0;
    final ratio = score / total;
    return ratio >= 0.8
        ? 3
        : ratio >= 0.5
        ? 2
        : 1;
  }
}
