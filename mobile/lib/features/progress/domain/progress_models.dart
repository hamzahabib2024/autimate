import '../../communication/domain/card_ranker.dart';
import '../../emotion_recognition/domain/emotion_activity_engine.dart';

class ProgressRecord {
  const ProgressRecord({required this.result, required this.recordedAt});

  final SessionResult result;
  final DateTime recordedAt;
}

/// A free-text caregiver observation. Human-authored, never generated.
class ObservationNote {
  const ObservationNote({
    required this.childId,
    required this.note,
    required this.authorRole,
    required this.createdAt,
  });

  final String childId;
  final String note;
  final String authorRole;
  final DateTime createdAt;
}

abstract interface class ProgressRepository {
  Future<void> recordSession(SessionResult result);
  Future<void> recordCardUsage(CardUsageEvent event);
  Future<void> recordObservation(ObservationNote note);
  Future<List<ProgressRecord>> getSessions(String childId);
  Future<List<CardUsageEvent>> getCardUsage(String childId);
  Future<List<ObservationNote>> getObservations(String childId);
}

class InMemoryProgressRepository implements ProgressRepository {
  final List<ProgressRecord> _sessions = [];
  final List<CardUsageEvent> _usage = [];
  final List<ObservationNote> _observations = [];

  @override
  Future<void> recordSession(SessionResult result) async {
    _sessions.add(ProgressRecord(result: result, recordedAt: DateTime.now()));
  }

  @override
  Future<void> recordCardUsage(CardUsageEvent event) async {
    _usage.add(event);
  }

  @override
  Future<void> recordObservation(ObservationNote note) async {
    _observations.add(note);
  }

  @override
  Future<List<ProgressRecord>> getSessions(String childId) async =>
      List.unmodifiable(
        _sessions.where((record) => record.result.childId == childId),
      );

  @override
  Future<List<CardUsageEvent>> getCardUsage(String childId) async =>
      List.unmodifiable(_usage);

  @override
  Future<List<ObservationNote>> getObservations(String childId) async =>
      List.unmodifiable(
        _observations.where((note) => note.childId == childId),
      );
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
  Future<void> recordObservation(ObservationNote note) async {
    // TODO: BACKEND INTEGRATION - persist caregiver observations.
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

  @override
  Future<List<ObservationNote>> getObservations(String childId) async {
    // TODO: BACKEND INTEGRATION - query observations for the child.
    return const [];
  }
}
