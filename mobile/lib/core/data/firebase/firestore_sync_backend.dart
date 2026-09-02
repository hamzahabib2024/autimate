import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../offline_sync_queue.dart';
import 'firestore_paths.dart';

/// Replays queued offline writes into Firestore.
///
/// This is the piece the existing [OfflineSyncQueue] was built to wait for.
/// The queue already handles the hard parts — durable storage, logical
/// ordering, and collapsing superseded mutations per entity — so this class
/// only has to answer one question per write: did it land?
///
/// It returns `false` rather than throwing on failure, which is what tells
/// the queue to **keep** the write and try again later. Getting this
/// backwards would silently drop a child's session history, so it is worth
/// being explicit: a `false` here is data preserved, not data lost.
class FirestoreSyncBackend {
  FirestoreSyncBackend({
    required FirebaseFirestore firestore,
    required String Function() currentUid,
  }) : _db = firestore,
       _uid = currentUid;

  final FirebaseFirestore _db;
  final String Function() _uid;

  /// Drains everything currently queued. Returns how many writes were
  /// accepted; anything not accepted stays queued for the next attempt.
  Future<int> drain(OfflineSyncQueue queue) => queue.drain(_send);

  Future<bool> _send(PendingWrite write) async {
    final uid = _uid();
    // Signed out means we cannot know which caregiver owns this write, so
    // it waits rather than being written somewhere arbitrary.
    if (uid.isEmpty) return false;
    try {
      // Writes are addressed by child, matching the rules' ownership model.
      if (write.childId.isEmpty) return false;
      final collection = switch (write.kind) {
        PendingWriteKind.session => FirestorePaths.sessions(write.childId),
        PendingWriteKind.cardUsage => FirestorePaths.cardUsage(write.childId),
        PendingWriteKind.observation =>
          FirestorePaths.observations(write.childId),
      };
      // The queue's own id is the document id, so replaying a write that
      // actually succeeded before a crash overwrites rather than duplicates.
      // Combined with the queue's per-entity collapsing, that makes the
      // drain idempotent.
      await _db.doc('$collection/${write.id}').set({
        ...write.payload,
        'childId': write.childId,
        'recordedAt': write.recordedAt.toIso8601String(),
        'syncedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      return true;
    } catch (error) {
      debugPrint('Sync write ${write.id} deferred: $error');
      return false;
    }
  }
}
