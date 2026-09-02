import '../../../features/communication/domain/card_ranker.dart';
import '../../../features/emotion_recognition/domain/emotion_activity_engine.dart';
import '../../../features/progress/domain/progress_models.dart';

/// The canonical wire shape for progress data.
///
/// This exists so three things cannot drift apart: what the local
/// repository writes to `shared_preferences`, what the offline queue carries
/// as a `PendingWrite` payload, and what lands in Firestore. They are the
/// same maps by construction, which is what lets a queued offline write be
/// replayed into Firestore later without a translation step.
///
/// Times are ISO-8601 strings rather than Firestore `Timestamp`s on purpose:
/// the same map has to survive a JSON round trip through the local store,
/// where a `Timestamp` has no meaning.
class ProgressCodec {
  const ProgressCodec._();

  // --- Sessions -----------------------------------------------------------

  static Map<String, dynamic> sessionToMap(
    SessionResult result, {
    DateTime? recordedAt,
  }) => {
    'childId': result.childId,
    'activityType': result.activityType,
    'score': result.score,
    'total': result.total,
    'levelPlayed': result.levelPlayed.name,
    'levelAfter': result.levelAfter.name,
    'durationMs': result.duration.inMilliseconds,
    'completedAt': result.completedAt.toIso8601String(),
    'starsAwarded': result.starsAwarded,
    'recordedAt': (recordedAt ?? DateTime.now()).toIso8601String(),
  };

  static ProgressRecord sessionFromMap(Map<String, dynamic> map) =>
      ProgressRecord(
        result: SessionResult(
          childId: map['childId'] as String? ?? '',
          activityType: map['activityType'] as String? ?? '',
          score: (map['score'] as num?)?.toInt() ?? 0,
          total: (map['total'] as num?)?.toInt() ?? 0,
          levelPlayed: _level(map['levelPlayed']),
          levelAfter: _level(map['levelAfter']),
          duration: Duration(
            milliseconds: (map['durationMs'] as num?)?.toInt() ?? 0,
          ),
          completedAt: _time(map['completedAt']),
          starsAwarded: (map['starsAwarded'] as num?)?.toInt() ?? 0,
        ),
        recordedAt: _time(map['recordedAt']),
      );

  // --- Card usage ---------------------------------------------------------

  static Map<String, dynamic> usageToMap(CardUsageEvent event) => {
    'cardId': event.cardId,
    'usedAt': event.usedAt.toIso8601String(),
  };

  static CardUsageEvent usageFromMap(Map<String, dynamic> map) =>
      CardUsageEvent(
        cardId: map['cardId'] as String? ?? '',
        usedAt: _time(map['usedAt']),
      );

  // --- Observations -------------------------------------------------------

  static Map<String, dynamic> observationToMap(ObservationNote note) => {
    'childId': note.childId,
    'note': note.note,
    'authorRole': note.authorRole,
    'createdAt': note.createdAt.toIso8601String(),
    'tag': note.tag,
  };

  static ObservationNote observationFromMap(Map<String, dynamic> map) =>
      ObservationNote(
        childId: map['childId'] as String? ?? '',
        note: map['note'] as String? ?? '',
        authorRole: map['authorRole'] as String? ?? 'parent',
        createdAt: _time(map['createdAt']),
        tag: map['tag'] as String? ?? 'general',
      );

  static SupportLevel _level(Object? value) => SupportLevel.values.firstWhere(
    (level) => level.name == value,
    orElse: () => SupportLevel.beginner,
  );

  /// Unparseable times fall back to the epoch rather than "now", so a
  /// corrupt record can never present itself as the newest one and win a
  /// last-write-wins merge.
  static DateTime _time(Object? value) =>
      DateTime.tryParse(value as String? ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
