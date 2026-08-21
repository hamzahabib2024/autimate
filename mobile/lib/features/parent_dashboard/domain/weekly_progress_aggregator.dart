import '../../../core/services/app_services.dart';
import '../../progress/domain/progress_models.dart';

/// Completed activity count for one weekday bucket.
class DailyActivityBucket {
  const DailyActivityBucket({required this.weekday, required this.count});

  /// 1 = Monday ... 7 = Sunday (ISO-8601 ordering).
  final int weekday;
  final int count;
}

/// Explainable weekly aggregation over recorded emotion sessions.
///
/// Pure and deterministic so the caregiver chart can be unit-tested without
/// widgets or clocks.
class WeeklyProgressAggregator {
  const WeeklyProgressAggregator();

  /// Buckets Monday..Sunday covering the seven days ending [today].
  List<DailyActivityBucket> aggregate(
    List<ProgressRecord> records,
    DateTime today,
  ) {
    final counts = <int, int>{};
    for (final record in records) {
      final day = record.result.completedAt;
      final age = DateTime(day.year, day.month, day.day)
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
      if (age > 0 || age < -6) continue;
      counts.update(day.weekday, (value) => value + 1, ifAbsent: () => 1);
    }
    return [
      for (var offset = 6; offset >= 0; offset--)
        _bucketFor(today.subtract(Duration(days: offset)), counts),
    ];
  }

  DailyActivityBucket _bucketFor(DateTime day, Map<int, int> counts) =>
      DailyActivityBucket(
        weekday: day.weekday,
        count: counts[day.weekday] ?? 0,
      );

  /// Routine completion ratio for today from the routine repository state.
  double routineCompletion({
    required ChildProfile child,
    required int completedSteps,
    required int totalSteps,
  }) =>
      totalSteps == 0 ? 0 : completedSteps / totalSteps;
}
