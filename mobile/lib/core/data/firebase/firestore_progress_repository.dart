import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../features/communication/domain/card_ranker.dart';
import '../../../features/emotion_recognition/domain/emotion_activity_engine.dart';
import '../../../features/progress/domain/progress_models.dart';
import 'firestore_paths.dart';
import 'progress_codec.dart';

/// Firestore-backed [ProgressRepository].
///
/// Writes are **append-only**: every session, card tap, and observation is a
/// new document, never an edit of an existing one. That matches
/// `firestore.rules`, and it matters beyond tidiness — this data is the
/// evidence a caregiver reads on the dashboard, and history that can be
/// silently rewritten is not evidence.
///
/// Each child's history lives in its own subcollection, so a read is scoped
/// by path rather than by a filter — which is also what lets the rules grant
/// a therapist access to one assigned child and nothing else.
class FirestoreProgressRepository implements ProgressRepository {
  FirestoreProgressRepository({
    required FirebaseFirestore firestore,
    required String Function() currentUid,
    required String Function() currentChildId,
    DateTime Function()? clock,
  }) : _db = firestore,
       _uid = currentUid,
       _childId = currentChildId,
       _clock = clock ?? DateTime.now;

  final FirebaseFirestore _db;

  /// Resolved lazily on every call: a caregiver can sign in or out long
  /// after this repository was constructed.
  final String Function() _uid;

  /// `CardUsageEvent` carries no child id — the AAC board records a tap, not
  /// a profile — so the active child is supplied the same lazy way.
  final String Function() _childId;
  final DateTime Function() _clock;

  /// False while nobody is signed in. Every method then no-ops rather than
  /// throwing, so a signed-out app degrades to local-only silently.
  bool get _signedIn => _uid().isNotEmpty;

  @override
  Future<void> recordSession(SessionResult result) async {
    if (!_signedIn || result.childId.isEmpty) return;
    await _db
        .collection(FirestorePaths.sessions(result.childId))
        .add(ProgressCodec.sessionToMap(result, recordedAt: _clock()));
  }

  @override
  Future<void> recordCardUsage(CardUsageEvent event) async {
    final childId = _childId();
    if (!_signedIn || childId.isEmpty) return;
    await _db
        .collection(FirestorePaths.cardUsage(childId))
        .add(ProgressCodec.usageToMap(event));
  }

  @override
  Future<void> recordObservation(ObservationNote note) async {
    if (!_signedIn || note.childId.isEmpty) return;
    await _db
        .collection(FirestorePaths.observations(note.childId))
        .add(ProgressCodec.observationToMap(note));
  }

  @override
  Future<List<ProgressRecord>> getSessions(String childId) async {
    if (!_signedIn) return const [];
    final snapshot =
        await _db.collection(FirestorePaths.sessions(childId)).get();
    final records = snapshot.docs
        .map((doc) => ProgressCodec.sessionFromMap(doc.data()))
        .toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return List.unmodifiable(records);
  }

  @override
  Future<List<CardUsageEvent>> getCardUsage(String childId) async {
    if (!_signedIn) return const [];
    final snapshot =
        await _db.collection(FirestorePaths.cardUsage(childId)).get();
    final events = snapshot.docs
        .map((doc) => ProgressCodec.usageFromMap(doc.data()))
        .toList()
      ..sort((a, b) => a.usedAt.compareTo(b.usedAt));
    return List.unmodifiable(events);
  }

  @override
  Future<List<ObservationNote>> getObservations(String childId) async {
    if (!_signedIn) return const [];
    final snapshot =
        await _db.collection(FirestorePaths.observations(childId)).get();
    final notes = snapshot.docs
        .map((doc) => ProgressCodec.observationFromMap(doc.data()))
        .toList()
      // Newest first, matching the dashboard's reading order.
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(notes);
  }
}
