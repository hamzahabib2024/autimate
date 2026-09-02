import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/config/app_config.dart';
import 'package:autimate/core/data/firebase/firestore_child_repository.dart';
import 'package:autimate/core/data/firebase/firestore_paths.dart';
import 'package:autimate/core/data/firebase/firestore_progress_repository.dart';
import 'package:autimate/core/data/firebase/firestore_sync_backend.dart';
import 'package:autimate/core/data/firebase/progress_codec.dart';
import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/data/offline_sync_queue.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/communication/domain/card_ranker.dart';
import 'package:autimate/features/emotion_recognition/domain/emotion_activity_engine.dart';
import 'package:autimate/features/progress/domain/progress_models.dart';

SessionResult _session({
  String childId = 'demo-child',
  int score = 4,
  DateTime? completedAt,
}) => SessionResult(
  childId: childId,
  activityType: 'emotion',
  score: score,
  total: 5,
  levelPlayed: SupportLevel.beginner,
  levelAfter: SupportLevel.intermediate,
  duration: const Duration(seconds: 42),
  completedAt: completedAt ?? DateTime(2026, 3, 1, 9),
  starsAwarded: 1,
);

void main() {
  group('credential gate', () {
    test('no credentials means no Firebase', () {
      const config = AppConfig();
      expect(config.firebaseConfigured, isFalse);
      expect(config.useMockBackend, isTrue);
    });

    test('partial credentials do not count as configured', () {
      const partial = AppConfig(
        firebaseApiKey: 'key',
        firebaseProjectId: 'project',
        // appId missing
      );
      expect(partial.firebaseConfigured, isFalse);
    });

    test('a full credential set flips the gate', () {
      const full = AppConfig(
        environment: 'production',
        firebaseApiKey: 'key',
        firebaseAppId: 'app',
        firebaseProjectId: 'project',
      );
      expect(full.firebaseConfigured, isTrue);
      expect(full.useMockBackend, isFalse);
    });

    test('mock environment overrides real credentials', () {
      const forced = AppConfig(
        environment: 'mock',
        firebaseApiKey: 'key',
        firebaseAppId: 'app',
        firebaseProjectId: 'project',
      );
      expect(forced.useMockBackend, isTrue,
          reason: 'a demo build must be able to force local-only');
    });
  });

  group('document layout', () {
    test('every collection hangs off the child it belongs to', () {
      const childId = 'child-1';
      for (final path in [
        FirestorePaths.sessions(childId),
        FirestorePaths.cardUsage(childId),
        FirestorePaths.observations(childId),
        FirestorePaths.routineSteps(childId),
        FirestorePaths.routineDays(childId),
      ]) {
        expect(path, startsWith('children/$childId/'),
            reason: 'the rules scope access per child, not per caregiver');
      }
      expect(FirestorePaths.child(childId), 'children/$childId');
    });

    test('a day id is deterministic, so replays converge', () {
      final morning = FirestorePaths.routineDayId(DateTime(2026, 3, 1, 8));
      final night = FirestorePaths.routineDayId(DateTime(2026, 3, 1, 22));
      expect(morning, night, reason: 'same day, same document');
      expect(morning, isNot(FirestorePaths.routineDayId(DateTime(2026, 3, 2))));
    });
  });

  group('progress codec', () {
    test('a session survives the wire shape unchanged', () {
      final original = _session();
      final restored =
          ProgressCodec.sessionFromMap(ProgressCodec.sessionToMap(original));
      expect(restored.result.childId, original.childId);
      expect(restored.result.score, original.score);
      expect(restored.result.total, original.total);
      expect(restored.result.levelPlayed, original.levelPlayed);
      expect(restored.result.levelAfter, original.levelAfter);
      expect(restored.result.duration, original.duration);
      expect(restored.result.completedAt, original.completedAt);
      expect(restored.result.starsAwarded, original.starsAwarded);
    });

    test('an unparseable time falls back to the epoch, not to now', () {
      final decoded = ProgressCodec.sessionFromMap({'completedAt': 'rubbish'});
      expect(decoded.result.completedAt.millisecondsSinceEpoch, 0,
          reason: 'a corrupt record must never win a last-write-wins merge');
    });

    test('observations keep their tag and author role', () {
      final note = ObservationNote(
        childId: 'demo-child',
        note: 'Settled quickly after the breathing activity.',
        authorRole: 'parent',
        createdAt: DateTime(2026, 3, 2),
        tag: 'sensory',
      );
      final restored = ProgressCodec.observationFromMap(
        ProgressCodec.observationToMap(note),
      );
      expect(restored.tag, 'sensory');
      expect(restored.authorRole, 'parent');
      expect(restored.note, note.note);
    });
  });

  group('FirestoreProgressRepository', () {
    late FakeFirebaseFirestore db;
    late FirestoreProgressRepository repository;
    String uid = 'caregiver-1';

    setUp(() {
      db = FakeFirebaseFirestore();
      // Reset explicitly: the signed-out case mutates `uid`, and without
      // this it leaks into whichever test runs next.
      uid = 'caregiver-1';
      repository = FirestoreProgressRepository(
        firestore: db,
        currentUid: () => uid,
        currentChildId: () => 'demo-child',
      );
    });

    test('records and reads back a session', () async {
      await repository.recordSession(_session());
      final sessions = await repository.getSessions('demo-child');
      expect(sessions, hasLength(1));
      expect(sessions.single.result.score, 4);
    });

    test('each child gets its own subcollection', () async {
      await repository.recordSession(_session(childId: 'child-a'));
      await repository.recordSession(_session(childId: 'child-b'));
      expect(await repository.getSessions('child-a'), hasLength(1));
      expect(await repository.getSessions('child-b'), hasLength(1));
      expect(await repository.getSessions('child-c'), isEmpty);
      // The separation is structural, not a Dart-side filter, so the rules
      // can grant a therapist one child and nothing else.
      final leaked = await db
          .collection(FirestorePaths.sessions('child-a'))
          .get();
      expect(leaked.docs, hasLength(1));
    });

    test('history is append-only — a second session adds, never replaces',
        () async {
      await repository.recordSession(_session(score: 1));
      await repository.recordSession(_session(score: 5));
      final sessions = await repository.getSessions('demo-child');
      expect(sessions, hasLength(2));
      expect(sessions.map((s) => s.result.score), containsAll([1, 5]));
    });

    test('sessions come back in chronological order', () async {
      await repository.recordSession(
        _session(completedAt: DateTime(2026, 3, 3)),
      );
      await repository.recordSession(
        _session(completedAt: DateTime(2026, 3, 1)),
      );
      final sessions = await repository.getSessions('demo-child');
      expect(
        sessions.first.recordedAt.isBefore(sessions.last.recordedAt) ||
            sessions.first.recordedAt == sessions.last.recordedAt,
        isTrue,
      );
    });

    test('card usage round-trips for the ranking', () async {
      await repository.recordCardUsage(
        CardUsageEvent(cardId: 'apple', usedAt: DateTime(2026, 3, 1)),
      );
      final usage = await repository.getCardUsage('demo-child');
      expect(usage.single.cardId, 'apple');
    });

    test('observations come back newest first', () async {
      for (final day in [1, 5, 3]) {
        await repository.recordObservation(
          ObservationNote(
            childId: 'demo-child',
            note: 'day $day',
            authorRole: 'parent',
            createdAt: DateTime(2026, 3, day),
          ),
        );
      }
      final notes = await repository.getObservations('demo-child');
      expect(notes.map((n) => n.note), ['day 5', 'day 3', 'day 1']);
    });

    test('signed out is a silent no-op, never a crash', () async {
      uid = '';
      await repository.recordSession(_session());
      expect(await repository.getSessions('demo-child'), isEmpty);
      expect(await repository.getCardUsage('demo-child'), isEmpty);
      expect(await repository.getObservations('demo-child'), isEmpty);
    });

    test('observations are written under their own child', () async {
      await repository.recordObservation(
        ObservationNote(
          childId: 'child-a',
          note: 'settled quickly',
          authorRole: 'parent',
          createdAt: DateTime(2026, 3, 1),
        ),
      );
      expect(await repository.getObservations('child-a'), hasLength(1));
      expect(await repository.getObservations('child-b'), isEmpty);
    });
  });

  group('FirestoreChildRepository', () {
    late FakeFirebaseFirestore db;

    FirestoreChildRepository repoFor(String uid) =>
        FirestoreChildRepository(firestore: db, currentUid: () => uid);

    setUp(() => db = FakeFirebaseFirestore());

    test('saving lists the caregiver as an owner', () async {
      final parent = repoFor('parent-1');
      await parent.saveChild(
        const ChildProfile(id: 'c1', name: 'Ayaan', supportLevel: 'Beginner'),
      );
      final children = await parent.getChildren();
      expect(children.single.name, 'Ayaan');
      expect(children.single.id, 'c1');
    });

    test('saving the same id edits rather than duplicating', () async {
      final parent = repoFor('parent-1');
      await parent.saveChild(
        const ChildProfile(id: 'c1', name: 'Ayaan', supportLevel: 'Beginner'),
      );
      await parent.saveChild(
        const ChildProfile(id: 'c1', name: 'Ayaan K', supportLevel: 'Advanced'),
      );
      final children = await parent.getChildren();
      expect(children, hasLength(1));
      expect(children.single.name, 'Ayaan K');
      expect(children.single.supportLevel, 'Advanced');
    });

    test('another family sees nothing', () async {
      await repoFor('parent-1').saveChild(
        const ChildProfile(id: 'c1', name: 'Ayaan', supportLevel: 'Beginner'),
      );
      expect(await repoFor('parent-2').getChildren(), isEmpty);
    });

    test('a therapist sees only the child they were assigned', () async {
      final parent = repoFor('parent-1');
      await parent.saveChild(
        const ChildProfile(id: 'c1', name: 'Ayaan', supportLevel: 'Beginner'),
      );
      await parent.saveChild(
        const ChildProfile(id: 'c2', name: 'Sara', supportLevel: 'Beginner'),
      );

      await parent.shareChildWith('c1', 'therapist-1');

      final therapist = repoFor('therapist-1');
      final visible = await therapist.getChildren();
      expect(visible, hasLength(1));
      expect(visible.single.id, 'c1',
          reason: 'assignment is per child, never to the whole caseload');
    });

    test('sharing does not displace the parent', () async {
      final parent = repoFor('parent-1');
      await parent.saveChild(
        const ChildProfile(id: 'c1', name: 'Ayaan', supportLevel: 'Beginner'),
      );
      await parent.shareChildWith('c1', 'therapist-1');
      expect(await parent.getChildren(), hasLength(1));
    });

    test('access can be revoked', () async {
      final parent = repoFor('parent-1');
      await parent.saveChild(
        const ChildProfile(id: 'c1', name: 'Ayaan', supportLevel: 'Beginner'),
      );
      await parent.shareChildWith('c1', 'therapist-1');
      expect(await repoFor('therapist-1').getChildren(), hasLength(1));

      await parent.revokeAccess('c1', 'therapist-1');
      expect(await repoFor('therapist-1').getChildren(), isEmpty);
    });
  });

  group('FirestoreSyncBackend', () {
    late FakeFirebaseFirestore db;
    late OfflineSyncQueue queue;
    String uid = 'caregiver-1';

    setUp(() {
      db = FakeFirebaseFirestore();
      queue = OfflineSyncQueue(store: InMemoryKeyValueStore());
      uid = 'caregiver-1';
    });

    FirestoreSyncBackend backend() =>
        FirestoreSyncBackend(firestore: db, currentUid: () => uid);

    PendingWrite write(String id, {PendingWriteKind? kind}) => PendingWrite(
      id: id,
      kind: kind ?? PendingWriteKind.session,
      childId: 'demo-child',
      payload: ProgressCodec.sessionToMap(_session()),
      recordedAt: DateTime(2026, 3, 1),
    );

    test('a queued write reaches Firestore and leaves the queue', () async {
      await queue.enqueue(write('w1'));
      expect(await queue.length, 1);

      final accepted = await backend().drain(queue);
      expect(accepted, 1);
      expect(await queue.length, 0);

      final docs =
          await db.collection(FirestorePaths.sessions('demo-child')).get();
      expect(docs.docs, hasLength(1));
      expect(docs.docs.single.data()['childId'], 'demo-child');
    });

    test('replaying the same write does not duplicate it', () async {
      await queue.enqueue(write('w1'));
      await backend().drain(queue);
      await queue.enqueue(write('w1'));
      await backend().drain(queue);

      final docs =
          await db.collection(FirestorePaths.sessions('demo-child')).get();
      expect(docs.docs, hasLength(1),
          reason: 'the queue id is the document id, so replay overwrites');
    });

    test('a write with no child stays queued rather than going astray',
        () async {
      await queue.enqueue(
        PendingWrite(
          id: 'orphan',
          kind: PendingWriteKind.session,
          childId: '',
          payload: const {},
          recordedAt: DateTime(2026, 3, 1),
        ),
      );
      expect(await backend().drain(queue), 0);
      expect(await queue.length, 1);
    });

    test('signed out keeps the write queued rather than dropping it',
        () async {
      uid = '';
      await queue.enqueue(write('w1'));
      final accepted = await backend().drain(queue);
      expect(accepted, 0);
      expect(await queue.length, 1,
          reason: 'an unsent write must survive for the next attempt');
    });

    test('each kind lands in its own collection', () async {
      await queue.enqueue(write('s1'));
      await queue.enqueue(write('u1', kind: PendingWriteKind.cardUsage));
      await queue.enqueue(write('o1', kind: PendingWriteKind.observation));
      await backend().drain(queue);

      expect(
        (await db.collection(FirestorePaths.sessions('demo-child')).get())
            .docs,
        hasLength(1),
      );
      expect(
        (await db.collection(FirestorePaths.cardUsage('demo-child')).get())
            .docs,
        hasLength(1),
      );
      expect(
        (await db.collection(FirestorePaths.observations('demo-child')).get())
            .docs,
        hasLength(1),
      );
    });
  });
}
