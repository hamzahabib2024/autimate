import 'emotion_activity_engine.dart';

/// A five-point scale for how strong a feeling is.
///
/// Modelled on the Feelings Scale that Choiceworks and similar tools use.
/// The value over a bare emotion label is real: "angry" and "a bit annoyed"
/// are the same word and very different situations, and a child who can only
/// report the label has no way to say the difference before it escalates.
///
/// **The risk this design guards against.** A number invites
/// over-interpretation — a caregiver reading a 4 as clinically meaningful, or
/// tracking a child's "average anger" over weeks. Three deliberate limits:
///
/// 1. The scale is **the child's own report**, never inferred from anything.
///    Nothing in the app computes it.
/// 2. It is deliberately **not aggregated**. There is no average, no trend
///    line, no weekly intensity chart — those are exactly the artefacts that
///    turn a communication aid into a surveillance record.
/// 3. Every level has a **plain-language name and an action**, so the useful
///    output is "what would help now", not a score.
enum IntensityLevel {
  /// Barely there. Nameable, not a problem.
  aLittle(1),

  /// Noticeable.
  someWhat(2),

  /// Clearly felt.
  quite(3),

  /// Hard to sit with.
  very(4),

  /// Overwhelming. The point at which words usually stop being available.
  tooMuch(5);

  const IntensityLevel(this.value);

  /// 1..5, for display only. Never summed, never averaged.
  final int value;

  static IntensityLevel fromValue(int value) => IntensityLevel.values
      .firstWhere((level) => level.value == value, orElse: () => aLittle);

  /// The rung above, or null at the top.
  IntensityLevel? get stronger {
    final index = IntensityLevel.values.indexOf(this);
    return index >= IntensityLevel.values.length - 1
        ? null
        : IntensityLevel.values[index + 1];
  }

  IntensityLevel? get gentler {
    final index = IntensityLevel.values.indexOf(this);
    return index <= 0 ? null : IntensityLevel.values[index - 1];
  }

  /// Whether this level should offer a calming route.
  ///
  /// Only the top two. Offering a breathing exercise for "a little happy"
  /// would be absurd, and offering one for every feeling teaches a child
  /// that all feelings are problems to be managed.
  bool get suggestsSupport => value >= 4;
}

/// One self-report: an emotion plus how strong it is.
///
/// Carries no interpretation, no cause, and no duration — only what the
/// child said, and when.
class IntensityReport {
  const IntensityReport({
    required this.emotion,
    required this.level,
    required this.reportedAt,
  });

  final EmotionLabel emotion;
  final IntensityLevel level;
  final DateTime reportedAt;

  Map<String, dynamic> toJson() => {
    'emotion': emotion.name,
    'level': level.value,
    'reportedAt': reportedAt.toIso8601String(),
  };

  static IntensityReport fromJson(Map<String, dynamic> json) =>
      IntensityReport(
        emotion: EmotionLabel.values.firstWhere(
          (value) => value.name == json['emotion'],
          orElse: () => EmotionLabel.neutral,
        ),
        level: IntensityLevel.fromValue(
          (json['level'] as num?)?.toInt() ?? 1,
        ),
        reportedAt:
            DateTime.tryParse(json['reportedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}

/// What to offer after a report.
///
/// Rule-based and readable. The output is a suggestion the child can decline,
/// never an instruction, and never a claim about what they are experiencing.
class IntensityGuidance {
  const IntensityGuidance._();

  /// Which support to offer, or null when none is warranted.
  ///
  /// Note that a strong *pleasant* feeling gets no calming suggestion:
  /// being very happy is not a state to be regulated down, and treating it
  /// as one is a mistake worth encoding against.
  static SupportSuggestion? suggest(IntensityReport report) {
    if (!report.level.suggestsSupport) return null;
    return switch (report.emotion) {
      EmotionLabel.happy || EmotionLabel.surprised => null,
      EmotionLabel.angry ||
      EmotionLabel.scared => SupportSuggestion.breathing,
      EmotionLabel.sad => SupportSuggestion.tellSomeone,
      EmotionLabel.neutral => null,
    };
  }
}

/// A route out, offered rather than imposed.
enum SupportSuggestion {
  /// Open the guided breathing activity.
  breathing,

  /// Prompt to find a trusted adult — some feelings need a person, not a
  /// technique, and an app that only ever offers self-regulation teaches a
  /// child to handle everything alone.
  tellSomeone,
}
