import 'dart:convert';

import 'local_store.dart';
import '../../features/communication/domain/card_ranker.dart';
import '../../features/emotion_recognition/domain/emotion_activity_engine.dart';
import '../../features/progress/domain/progress_models.dart';

/// Durable offline [ProgressRepository].
///
/// All child progress is stored as JSON through the [KeyValueStore] so it
/// survives app restarts without any network access. A future Firestore
/// adapter can drain the sync queue behind the same interface.
class LocalProgressRepository implements ProgressRepository {
  LocalProgressRepository({required KeyValueStore store, DateTime Function()? clock})
    : _store = store,
      _clock = clock ?? DateTime.now;

  static const String _sessionsKey = 'autimate.progress.sessions.v1';
  static const String _usageKey = 'autimate.progress.usage.v1';
  static const String _observationsKey = 'autimate.progress.observations.v1';

  final KeyValueStore _store;
  final DateTime Function() _clock;

  @override
  Future<void> recordSession(SessionResult result) async {
    final records = await _readList(_sessionsKey);
    records.add({
      'childId': result.childId,
      'activityType': result.activityType,
      'score': result.score,
      'total': result.total,
      'levelPlayed': result.levelPlayed.name,
      'levelAfter': result.levelAfter.name,
      'durationMs': result.duration.inMilliseconds,
      'completedAt': result.completedAt.toIso8601String(),
      'starsAwarded': result.starsAwarded,
      'recordedAt': _clock().toIso8601String(),
    });
    await _writeList(_sessionsKey, records);
  }

  @override
  Future<void> recordCardUsage(CardUsageEvent event) async {
    final records = await _readList(_usageKey);
    records.add({
      'cardId': event.cardId,
      'usedAt': event.usedAt.toIso8601String(),
    });
    await _writeList(_usageKey, records);
  }

  @override
  Future<void> recordObservation(ObservationNote note) async {
    final records = await _readList(_observationsKey);
    records.add({
      'childId': note.childId,
      'note': note.note,
      'authorRole': note.authorRole,
      'createdAt': note.createdAt.toIso8601String(),
      'tag': note.tag,
    });
    await _writeList(_observationsKey, records);
  }

  @override
  Future<List<ProgressRecord>> getSessions(String childId) async {
    final records = await _readList(_sessionsKey);
    return List.unmodifiable(
      records
          .map(_decodeSession)
          .where((record) => record.result.childId == childId)
          .toList()
        ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt)),
    );
  }

  @override
  Future<List<CardUsageEvent>> getCardUsage(String childId) async {
    final records = await _readList(_usageKey);
    return List.unmodifiable(
      records.map(_decodeUsage).toList()
        ..sort((a, b) => a.usedAt.compareTo(b.usedAt)),
    );
  }

  @override
  Future<List<ObservationNote>> getObservations(String childId) async {
    final records = await _readList(_observationsKey);
    return List.unmodifiable(
      records
          .map(_decodeObservation)
          .where((note) => note.childId == childId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  Future<List<Map<String, dynamic>>> _readList(String key) async {
    final raw = await _store.read(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> _writeList(String key, List<Map<String, dynamic>> records) =>
      _store.write(key, jsonEncode(records));

  ProgressRecord _decodeSession(Map<String, dynamic> map) => ProgressRecord(
    result: SessionResult(
      childId: map['childId'] as String? ?? '',
      activityType: map['activityType'] as String? ?? '',
      score: (map['score'] as num?)?.toInt() ?? 0,
      total: (map['total'] as num?)?.toInt() ?? 0,
      levelPlayed: SupportLevel.values.firstWhere(
        (level) => level.name == map['levelPlayed'],
        orElse: () => SupportLevel.beginner,
      ),
      levelAfter: SupportLevel.values.firstWhere(
        (level) => level.name == map['levelAfter'],
        orElse: () => SupportLevel.beginner,
      ),
      duration: Duration(
        milliseconds: (map['durationMs'] as num?)?.toInt() ?? 0,
      ),
      completedAt: DateTime.tryParse(map['completedAt'] as String? ?? '') ??
          _clock(),
      starsAwarded: (map['starsAwarded'] as num?)?.toInt() ?? 0,
    ),
    recordedAt: DateTime.tryParse(map['recordedAt'] as String? ?? '') ??
        _clock(),
  );

  CardUsageEvent _decodeUsage(Map<String, dynamic> map) => CardUsageEvent(
    cardId: map['cardId'] as String? ?? '',
    usedAt:
        DateTime.tryParse(map['usedAt'] as String? ?? '') ?? _clock(),
  );

  ObservationNote _decodeObservation(Map<String, dynamic> map) =>
      ObservationNote(
        childId: map['childId'] as String? ?? '',
        note: map['note'] as String? ?? '',
        authorRole: map['authorRole'] as String? ?? 'parent',
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            _clock(),
        tag: map['tag'] as String? ?? 'general',
      );
}
