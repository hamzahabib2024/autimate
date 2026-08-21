import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/data/offline_sync_queue.dart';

void main() {
  late InMemoryKeyValueStore store;
  late OfflineSyncQueue queue;

  setUp(() {
    store = InMemoryKeyValueStore();
    queue = OfflineSyncQueue(store: store);
  });

  PendingWrite write(
    String id, {
    DateTime? at,
    String entityKey = 'entity-1',
  }) =>
      PendingWrite(
        id: id,
        kind: PendingWriteKind.session,
        childId: 'demo-child',
        payload: {'entityKey': entityKey},
        recordedAt: at ?? DateTime(2026, 8, 21, 12),
      );

  test('queue persists across restarts', () async {
    await queue.enqueue(write('w1'));
    final restarted = OfflineSyncQueue(store: store);
    expect(await restarted.length, 1);
  });

  test('drain removes accepted writes and keeps failures', () async {
    await queue.enqueue(write('w1'));
    await queue.enqueue(write('w2', entityKey: 'entity-2'));

    final accepted = await queue.drain((_) async => true);
    expect(accepted, 2);
    expect(await queue.length, 0);
  });

  test('last write wins collapses superseded writes per entity', () async {
    await queue.enqueue(write('old', at: DateTime(2026, 8, 21, 10)));
    await queue.enqueue(write('new', at: DateTime(2026, 8, 21, 11)));

    final replayed = <String>[];
    await queue.drain((pending) async {
      replayed.add(pending.id);
      return true;
    });

    expect(replayed, ['new']);
  });

  test('failed sends stay queued for retry', () async {
    await queue.enqueue(write('w1'));

    var attempts = 0;
    final accepted = await queue.drain((_) async {
      attempts++;
      return false;
    });

    expect(accepted, 0);
    expect(attempts, 1);
    expect(await queue.length, 1);
  });
}
