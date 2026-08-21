import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/emotion_recognition/domain/emotion_activity_engine.dart';
import 'package:autimate/features/parent_dashboard/domain/weekly_progress_aggregator.dart';
import 'package:autimate/features/progress/domain/progress_models.dart';

void main() {
  const aggregator = WeeklyProgressAggregator();

  ProgressRecord recordOn(DateTime day) => ProgressRecord(
    result: SessionResult(
      childId: 'demo-child',
      activityType: 'emotion_identification',
      score: 3,
      total: 5,
      levelPlayed: SupportLevel.beginner,
      levelAfter: SupportLevel.beginner,
      duration: const Duration(minutes: 2),
      completedAt: day,
      starsAwarded: 1,
    ),
    recordedAt: day,
  );

  test('buckets the last seven days Monday through Sunday', () async {
    // 2026-08-21 is a Friday. The window is Sat 15 .. Fri 21.
    final today = DateTime(2026, 8, 21);
    final records = [
      recordOn(DateTime(2026, 8, 16)), // Sunday
      recordOn(DateTime(2026, 8, 16)),
      recordOn(DateTime(2026, 8, 21)), // Friday
      recordOn(DateTime(2026, 8, 14)), // outside window
    ];

    final buckets = aggregator.aggregate(records, today);

    expect(buckets, hasLength(7));
    expect(buckets.first.weekday, DateTime.saturday);
    expect(buckets.last.weekday, DateTime.friday);
    expect(buckets.map((bucket) => bucket.count), [0, 2, 0, 0, 0, 0, 1]);
  });

  test('routine completion handles an empty routine safely', () async {
    expect(
      aggregator.routineCompletion(
        child: const ChildProfile(
          id: 'demo-child',
          name: 'Ayaan',
          supportLevel: 'Beginner',
        ),
        completedSteps: 0,
        totalSteps: 0,
      ),
      0,
    );
  });
}
