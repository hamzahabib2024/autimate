import '../../communication/domain/card_ranker.dart';
import '../../emotion_recognition/domain/emotion_activity_engine.dart';

class ProgressRecord {
  const ProgressRecord({required this.result, required this.recordedAt});

  final SessionResult result;
  final DateTime recordedAt;
}

abstract interface class ProgressRepository {
  Future<void> recordSession(SessionResult result);
  Future<void> recordCardUsage(CardUsageEvent event);
  Future<List<ProgressRecord>> getSessions(String childId);
  Future<List<CardUsageEvent>> getCardUsage(String childId);
}

class InMemoryProgressRepository implements ProgressRepository {
  final List<ProgressRecord> _sessions = [];
  final List<CardUsageEvent> _usage = [];

  @override
  Future<void> recordSession(SessionResult result) async {
    _sessions.add(ProgressRecord(result: result, recordedAt: DateTime.now()));
  }

  @override
  Future<void> recordCardUsage(CardUsageEvent event) async {
    _usage.add(event);
  }

  @override
  Future<List<ProgressRecord>> getSessions(String childId) async =>
      List.unmodifiable(
        _sessions.where((record) => record.result.childId == childId),
      );

  @override
  Future<List<CardUsageEvent>> getCardUsage(String childId) async =>
      List.unmodifiable(_usage);
}

class FirestoreProgressRepository implements ProgressRepository {
  @override
  Future<void> recordSession(SessionResult result) async {
    // TODO: BACKEND INTEGRATION - write progress through Firestore rules.
  }

  @override
  Future<void> recordCardUsage(CardUsageEvent event) async {
    // TODO: BACKEND INTEGRATION - persist usage for explainable ranking.
  }

  @override
  Future<List<ProgressRecord>> getSessions(String childId) async {
    // TODO: BACKEND INTEGRATION - query progress for the authenticated child.
    return const [];
  }

  @override
  Future<List<CardUsageEvent>> getCardUsage(String childId) async {
    // TODO: BACKEND INTEGRATION - query usage for the authenticated child.
    return const [];
  }
}
