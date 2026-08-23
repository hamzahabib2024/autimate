import '../../progress/domain/progress_models.dart';

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

/// One day on the emotion accuracy trend. [accuracy] is the pooled
/// score/total across that day's emotion sessions, or null when none were
/// recorded — gaps are rendered as missing points, never as zero.
class EmotionTrendPoint {
  const EmotionTrendPoint({
    required this.day,
    required this.accuracy,
    required this.sessions,
  });

  final DateTime day;
  final double? accuracy;
  final int sessions;
}

/// Buckets recorded sessions into the last [days] calendar days and pools
/// emotion-activity accuracy per day. Pure and deterministic so tests can
/// pin exact dates.
class EmotionTrendSeries {
  const EmotionTrendSeries({this.days = 7});

  final int days;

  List<EmotionTrendPoint> build(List<ProgressRecord> records, DateTime now) {
    final today = _dateOnly(now);
    // Oldest first, ending today.
    final buckets = <DateTime, ({int score, int total})>{};
    for (var i = days - 1; i >= 0; i--) {
      buckets[today.subtract(Duration(days: i))] = (score: 0, total: 0);
    }
    for (final record in records) {
      if (!record.result.activityType.startsWith('emotion')) continue;
      final day = _dateOnly(record.result.completedAt);
      final bucket = buckets[day];
      if (bucket == null) continue;
      buckets[day] = (
        score: bucket.score + record.result.score,
        total: bucket.total + record.result.total,
      );
    }
    return [
      for (final entry in buckets.entries)
        EmotionTrendPoint(
          day: entry.key,
          accuracy:
              entry.value.total > 0
                  ? entry.value.score / entry.value.total
                  : null,
          sessions: entry.value.total,
        ),
    ];
  }
}
