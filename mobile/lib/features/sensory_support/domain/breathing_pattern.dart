/// A guided breathing pattern.
///
/// Three patterns rather than one, because the existing single rhythm suits
/// some children and not others, and the difference is not cosmetic: the
/// ratio of inhale to exhale changes what the exercise does. A longer exhale
/// than inhale is the part that actually calms; an equal-sided pattern is
/// easier to follow but does less.
///
/// **A limit stated plainly.** These are calming exercises, not clinical
/// interventions, and nothing here should be described to a caregiver as a
/// treatment. The 4-7-8 pattern in particular is popularly promoted well
/// beyond its evidence, so it is offered as one option among three rather
/// than as the recommended one.
class BreathingPattern {
  const BreathingPattern({
    required this.id,
    required this.inhale,
    required this.holdIn,
    required this.exhale,
    required this.holdOut,
  });

  final String id;

  final Duration inhale;

  /// Pause at the top of the breath.
  final Duration holdIn;

  final Duration exhale;

  /// Pause at the bottom, before the next inhale.
  final Duration holdOut;

  Duration get cycle => inhale + holdIn + exhale + holdOut;

  /// True when the exhale is longer than the inhale — the property that
  /// makes a pattern calming rather than merely rhythmic.
  bool get favoursExhale => exhale > inhale;

  /// Where in the cycle [elapsed] falls, and how open the circle should be.
  ///
  /// Returns a phase id the UI localises, plus a 0..1 openness the pace
  /// circle scales to. Held phases keep the circle still, which is the
  /// point — a circle that drifts during a hold teaches the wrong timing.
  BreathingPhase phaseAt(Duration elapsed) {
    final ms = cycle.inMilliseconds;
    if (ms <= 0) return const BreathingPhase(id: 'inhale', openness: 0);
    var t = elapsed.inMilliseconds % ms;

    if (t < inhale.inMilliseconds) {
      final progress = inhale.inMilliseconds == 0
          ? 1.0
          : t / inhale.inMilliseconds;
      return BreathingPhase(id: 'inhale', openness: progress);
    }
    t -= inhale.inMilliseconds;

    if (t < holdIn.inMilliseconds) {
      return const BreathingPhase(id: 'holdIn', openness: 1);
    }
    t -= holdIn.inMilliseconds;

    if (t < exhale.inMilliseconds) {
      final progress = exhale.inMilliseconds == 0
          ? 1.0
          : t / exhale.inMilliseconds;
      return BreathingPhase(id: 'exhale', openness: 1 - progress);
    }
    return const BreathingPhase(id: 'holdOut', openness: 0);
  }

  /// Slows the whole pattern for sensory mode, keeping the ratios intact.
  ///
  /// Scaling rather than substituting matters: the inhale-to-exhale ratio is
  /// what the pattern *is*, and a "calmer" version that flattened it would
  /// be a different exercise wearing the same name.
  BreathingPattern scaled(double factor) => BreathingPattern(
    id: id,
    inhale: inhale * factor,
    holdIn: holdIn * factor,
    exhale: exhale * factor,
    holdOut: holdOut * factor,
  );

  /// The app's original rhythm, kept as the default so nobody's familiar
  /// exercise changes underneath them.
  static const BreathingPattern gentle = BreathingPattern(
    id: 'gentle',
    inhale: Duration(seconds: 4),
    holdIn: Duration(seconds: 2),
    exhale: Duration(seconds: 6),
    holdOut: Duration.zero,
  );

  /// Box breathing: four equal sides. The easiest to follow, and the
  /// easiest to teach, because every phase is the same length.
  static const BreathingPattern box = BreathingPattern(
    id: 'box',
    inhale: Duration(seconds: 4),
    holdIn: Duration(seconds: 4),
    exhale: Duration(seconds: 4),
    holdOut: Duration(seconds: 4),
  );

  /// 4-7-8. The longest hold and the longest exhale; demanding, and not
  /// suitable for every child.
  static const BreathingPattern fourSevenEight = BreathingPattern(
    id: 'fourSevenEight',
    inhale: Duration(seconds: 4),
    holdIn: Duration(seconds: 7),
    exhale: Duration(seconds: 8),
    holdOut: Duration.zero,
  );

  static const List<BreathingPattern> all = [gentle, box, fourSevenEight];

  static BreathingPattern byId(String id) =>
      all.firstWhere((pattern) => pattern.id == id, orElse: () => gentle);
}

/// Where the breath is now.
class BreathingPhase {
  const BreathingPhase({required this.id, required this.openness});

  /// One of `inhale`, `holdIn`, `exhale`, `holdOut`.
  final String id;

  /// 0 = fully contracted, 1 = fully expanded.
  final double openness;

  bool get isHold => id == 'holdIn' || id == 'holdOut';
}
