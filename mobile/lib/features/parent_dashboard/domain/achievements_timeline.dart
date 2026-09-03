import '../../gamification/domain/badges.dart';
import '../../progress/domain/progress_models.dart';

/// A dated thing worth remembering.
///
/// The dashboard already answers "how is this week going". This answers a
/// different and longer question — "how far have we come" — which is the one
/// a caregiver asks on a bad day, and the one a weekly view is structurally
/// incapable of answering.
///
/// Deliberately built only from **firsts and milestones**, never from
/// per-day counts. A timeline of every session would be a log; a timeline of
/// firsts is a story, and the story is the point.
class Achievement {
  const Achievement({
    required this.id,
    required this.kind,
    required this.achievedAt,
    this.detail = '',
  });

  final String id;
  final AchievementKind kind;
  final DateTime achievedAt;

  /// Extra context — a badge name, a card label. Localised by the caller;
  /// this layer stays language-agnostic.
  final String detail;
}

enum AchievementKind {
  /// The first recorded session of any kind.
  firstSession,

  /// The first session of a particular activity type.
  firstActivityType,

  /// A badge milestone was reached.
  badge,

  /// A run of consecutive active days ended at a new best.
  streakRecord,

  /// A round number of sessions.
  sessionMilestone,
}

/// Builds the timeline from recorded data only.
///
/// Nothing here is invented or estimated. If a caregiver cannot point at the
/// session that produced an entry, it should not be on the timeline.
class AchievementsBuilder {
  const AchievementsBuilder({this.sessionMilestones = const [10, 25, 50, 100]});

  /// Round numbers worth marking. Kept sparse on purpose — a timeline that
  /// celebrates every fifth session stops meaning anything.
  final List<int> sessionMilestones;

  List<Achievement> build({
    required List<ProgressRecord> sessions,
    required int stars,
  }) {
    if (sessions.isEmpty) return const [];

    final ordered = [...sessions]
      ..sort((a, b) => a.result.completedAt.compareTo(b.result.completedAt));

    final achievements = <Achievement>[
      Achievement(
        id: 'first-session',
        kind: AchievementKind.firstSession,
        achievedAt: ordered.first.result.completedAt,
      ),
    ];

    // First time each activity type appeared.
    final seenTypes = <String>{};
    for (final record in ordered) {
      final type = record.result.activityType;
      if (type.isEmpty || !seenTypes.add(type)) continue;
      if (seenTypes.length == 1) continue; // already covered by firstSession
      achievements.add(
        Achievement(
          id: 'first-$type',
          kind: AchievementKind.firstActivityType,
          achievedAt: record.result.completedAt,
          detail: type,
        ),
      );
    }

    // Session count milestones, dated to the session that crossed them.
    for (final milestone in sessionMilestones) {
      if (ordered.length < milestone) continue;
      achievements.add(
        Achievement(
          id: 'sessions-$milestone',
          kind: AchievementKind.sessionMilestone,
          achievedAt: ordered[milestone - 1].result.completedAt,
          detail: '$milestone',
        ),
      );
    }

    // Badges, dated to the session that earned them where that is knowable.
    final evaluated = evaluateBadges(
      sessionCount: ordered.length,
      streakDays: currentStreak(
        sessionDayKeys(ordered),
        ordered.last.result.completedAt,
      ),
      stars: stars,
    );
    for (final badge in evaluated.where((badge) => badge.earned)) {
      final index = badge.definition.target - 1;
      // A star-based badge has no single session that earned it, so it is
      // dated to the most recent session rather than guessed at.
      final at = index >= 0 && index < ordered.length
          ? ordered[index].result.completedAt
          : ordered.last.result.completedAt;
      achievements.add(
        Achievement(
          id: 'badge-${badge.definition.id}',
          kind: AchievementKind.badge,
          achievedAt: at,
          detail: badge.definition.id,
        ),
      );
    }

    // Best streak, if it is worth mentioning at all.
    final best = longestStreak(sessionDayKeys(ordered));
    if (best >= 3) {
      achievements.add(
        Achievement(
          id: 'streak-$best',
          kind: AchievementKind.streakRecord,
          achievedAt: ordered.last.result.completedAt,
          detail: '$best',
        ),
      );
    }

    // Newest first: a caregiver opening this wants the recent win.
    achievements.sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
    return List.unmodifiable(achievements);
  }
}

/// The longest run of consecutive active days in the whole history.
///
/// Distinct from `currentStreak`, which only counts the run ending today.
/// A caregiver on a bad week benefits from seeing the best they ever did,
/// not only what is live right now.
int longestStreak(Iterable<String> activeDayKeys) {
  final days = activeDayKeys.toList()..sort();
  if (days.isEmpty) return 0;
  var best = 1;
  var run = 1;
  for (var i = 1; i < days.length; i++) {
    final previous = DateTime.parse(days[i - 1]);
    final current = DateTime.parse(days[i]);
    if (current.difference(previous).inDays == 1) {
      run++;
      if (run > best) best = run;
    } else {
      run = 1;
    }
  }
  return best;
}
