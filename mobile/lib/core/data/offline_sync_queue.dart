import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'local_store.dart';

/// Kind of pending write waiting to reach the backend.
enum PendingWriteKind { session, cardUsage, observation }

/// A single queued mutation produced while the device was offline.
class PendingWrite {
  const PendingWrite({
    required this.id,
    required this.kind,
    required this.childId,
    required this.payload,
    required this.recordedAt,
  });

  final String id;
  final PendingWriteKind kind;
  final String childId;
  final Map<String, dynamic> payload;

  /// Logical event time used for last-write-wins conflict resolution.
  final DateTime recordedAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'kind': kind.name,
    'childId': childId,
    'payload': payload,
    'recordedAt': recordedAt.toIso8601String(),
  };

  static PendingWrite fromMap(Map<String, dynamic> map) => PendingWrite(
    id: map['id'] as String? ?? '',
    kind: PendingWriteKind.values.firstWhere(
      (kind) => kind.name == map['kind'],
      orElse: () => PendingWriteKind.session,
    ),
    childId: map['childId'] as String? ?? '',
    payload:
        (map['payload'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{},
    recordedAt: DateTime.tryParse(map['recordedAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}

/// Durable offline queue with last-write-wins drain semantics.
///
/// While Firestore is not connected the queue simply accumulates writes.
/// When a backend adapter is available, [drain] replays writes in logical
/// order and collapses superseded mutations per (childId, kind, entity).
class OfflineSyncQueue {
  OfflineSyncQueue({required KeyValueStore store})
    : _store = store;

  static const String _queueKey = 'autimate.sync.queue.v1';

  final KeyValueStore _store;
  final List<PendingWrite> _cache = [];
  bool _loaded = false;

  Future<void> enqueue(PendingWrite write) async {
    await _ensureLoaded();
    _cache.add(write);
    await _persist();
  }

  Future<int> get length async {
    await _ensureLoaded();
    return _cache.length;
  }

  /// Replays every pending write through [send] in last-write-wins order.
  ///
  /// [send] returns true when the backend accepted the write. Accepted
  /// writes are removed from the queue; failures stay queued for retry.
  Future<int> drain(Future<bool> Function(PendingWrite write) send) async {
    await _ensureLoaded();
    final ordered = _dedupeLatestPerEntity()..sort(_byRecordedTime);
    var accepted = 0;
    for (final write in ordered) {
      if (await send(write)) {
        _cache.remove(write);
        accepted++;
      }
    }
    if (accepted > 0) await _persist();
    return accepted;
  }

  /// Keeps only the newest write per (childId, kind, entityKey).
  @visibleForTesting
  List<PendingWrite> dedupeForTest() => _dedupeLatestPerEntity();

  List<PendingWrite> _dedupeLatestPerEntity() {
    final latest = <String, PendingWrite>{};
    for (final write in _cache) {
      final key =
          '${write.childId}|${write.kind.name}|${write.payload['entityKey'] ?? write.id}';
      final existing = latest[key];
      if (existing == null || write.recordedAt.isAfter(existing.recordedAt)) {
        latest[key] = write;
      }
    }
    return latest.values.toList();
  }

  int _byRecordedTime(PendingWrite a, PendingWrite b) =>
      a.recordedAt.compareTo(b.recordedAt);

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final raw = await _store.read(_queueKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _cache.addAll(
            decoded
                .whereType<Map<String, dynamic>>()
                .map(PendingWrite.fromMap),
          );
        }
      } on FormatException {
        // Corrupt queue contents are dropped rather than crashing startup.
        await _store.remove(_queueKey);
      }
    }
    _loaded = true;
  }

  Future<void> _persist() =>
      _store.write(_queueKey, jsonEncode(_cache.map((w) => w.toMap()).toList()));
}
