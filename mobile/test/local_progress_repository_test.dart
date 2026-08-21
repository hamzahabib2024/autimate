import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/local_progress_repository.dart';
import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/features/communication/domain/card_ranker.dart';
import 'package:autimate/features/emotion_recognition/domain/emotion_activity_engine.dart';
import 'package:autimate/features/progress/domain/progress_models.dart';

void main() {
  late InMemoryKeyValueStore store;
  late LocalProgressRepository repository;

  setUp(() {
    store = InMemoryKeyValueStore();
    repository = LocalProgressRepository(store: store);
  });

  SessionResult session({int score = 3}) => SessionResult(
    childId: 'demo-child',
    activityType: 'emotion_identification',
    score: score,
    total: 5,
    levelPlayed: SupportLevel.beginner,
    levelAfter: SupportLevel.intermediate,
    duration: const Duration(minutes: 4),
    completedAt: DateTime(2026, 8, 21, 10),
    starsAwarded: 2,
  );

  test('sessions survive a repository restart through the store', () async {
    await repository.recordSession(session());
    await repository.recordCardUsage(
      CardUsageEvent(cardId: 'apple', usedAt: DateTime(2026, 8, 21, 9)),
    );
    await repository.recordObservation(
      ObservationNote(
        childId: 'demo-child',
        note: 'Used AAC at breakfast',
        authorRole: 'parent',
        createdAt: DateTime(2026, 8, 21, 8),
      ),
    );

    final restarted = LocalProgressRepository(store: store);

    final sessions = await restarted.getSessions('demo-child');
    expect(sessions, hasLength(1));
    expect(sessions.single.result.score, 3);
    expect(sessions.single.result.levelAfter, SupportLevel.intermediate);
    expect(sessions.single.result.starsAwarded, 2);

    final usage = await restarted.getCardUsage('demo-child');
    expect(usage, hasLength(1));
    expect(usage.single.cardId, 'apple');

    final notes = await restarted.getObservations('demo-child');
    expect(notes, hasLength(1));
    expect(notes.single.note, 'Used AAC at breakfast');
  });

  test('filters records by child id', () async {
    await repository.recordSession(session());
    await repository.recordSession(
      SessionResult(
        childId: 'other-child',
        activityType: 'emotion_identification',
        score: 1,
        total: 5,
        levelPlayed: SupportLevel.beginner,
        levelAfter: SupportLevel.beginner,
        duration: const Duration(minutes: 1),
        completedAt: DateTime(2026, 8, 20),
        starsAwarded: 1,
      ),
    );

    expect(await repository.getSessions('demo-child'), hasLength(1));
    expect(await repository.getSessions('other-child'), hasLength(1));
  });
}
