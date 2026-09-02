/// The single place the Firestore document layout is written down.
///
/// It mirrors `firestore.rules` exactly. If a path changes here, the rules
/// change with it, and `test/firebase_backend_test.dart` is what proves they
/// still agree.
///
/// **Ownership model: a child is shared, not owned.** Data hangs off
/// `children/{childId}`, and the child document carries a `caregiverIds`
/// array naming everyone allowed to see it. The obvious alternative —
/// nesting everything under `caregivers/{uid}` — is simpler but makes the
/// scope's teacher/therapist requirement impossible: a therapist needs read
/// and observation access to *assigned* children without owning them, and an
/// array membership check gives exactly that with no data duplication.
///
/// Progress is append-only by design: sessions, card usage, and observations
/// are history, and history that can be edited is not evidence.
class FirestorePaths {
  const FirestorePaths._();

  static const String children = 'children';

  static String child(String childId) => '$children/$childId';

  /// Append-only session history for one child.
  static String sessions(String childId) => '${child(childId)}/sessions';

  /// Append-only AAC card-usage events, feeding the frequent-cards ranking.
  static String cardUsage(String childId) => '${child(childId)}/cardUsage';

  /// Append-only caregiver observations.
  static String observations(String childId) =>
      '${child(childId)}/observations';

  /// Routine definitions are mutable — a caregiver edits the schedule.
  static String routineSteps(String childId) =>
      '${child(childId)}/routineSteps';

  /// Per-day routine completion.
  static String routineDays(String childId) =>
      '${child(childId)}/routineDays';

  /// Deterministic id for one day, so a repeated write updates the same
  /// document instead of creating duplicates — this is what makes the
  /// offline queue's last-write-wins semantics actually converge.
  static String routineDayId(DateTime day) =>
      day.toIso8601String().substring(0, 10);

  /// Field naming everyone permitted to read a child. The rules check
  /// membership of this array; nothing else grants access.
  static const String caregiverIdsField = 'caregiverIds';
}
