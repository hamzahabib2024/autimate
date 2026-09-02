import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/app_services.dart';
import '../backend_contracts.dart';
import 'firestore_paths.dart';

/// Firestore-backed [ChildRepository], replacing the earlier stub that
/// returned an empty list behind a `TODO`.
///
/// A child is *shared*, not owned: `children/{childId}` carries a
/// `caregiverIds` array naming everyone allowed to see it. That is what
/// makes the scope's teacher/therapist access possible — a therapist is
/// added to the array for their assigned children and gets nothing else —
/// and it is exactly the check `firestore.rules` performs.
///
/// The child id is the document id, so a repeated save is an update rather
/// than a duplicate, which is the property the offline queue's
/// last-write-wins merge relies on to converge.
class FirestoreChildRepository implements ChildRepository {
  FirestoreChildRepository({
    required FirebaseFirestore firestore,
    required String Function() currentUid,
  }) : _db = firestore,
       _uid = currentUid;

  final FirebaseFirestore _db;
  final String Function() _uid;

  String? get _user {
    final uid = _uid();
    return uid.isEmpty ? null : uid;
  }

  @override
  Future<List<ChildProfile>> getChildren() async {
    final uid = _user;
    if (uid == null) return const [];
    // Only children this caregiver is listed on. The same predicate the
    // rules enforce server-side, so an accidental widening here still
    // cannot leak another family's child.
    final snapshot = await _db
        .collection(FirestorePaths.children)
        .where(FirestorePaths.caregiverIdsField, arrayContains: uid)
        .get();
    return List.unmodifiable(
      snapshot.docs.map(
        (doc) => ChildProfile(
          id: doc.id,
          name: doc.data()['name'] as String? ?? '',
          supportLevel: doc.data()['supportLevel'] as String? ?? 'Beginner',
        ),
      ),
    );
  }

  @override
  Future<ChildProfile> saveChild(ChildProfile child) async {
    final uid = _user;
    if (uid == null) return child;
    await _db.doc(FirestorePaths.child(child.id)).set({
      'name': child.name,
      'supportLevel': child.supportLevel,
      // The saving caregiver is always on the list; arrayUnion means adding
      // a teacher later never removes the parent.
      FirestorePaths.caregiverIdsField: FieldValue.arrayUnion([uid]),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
    return child;
  }

  /// Grants a teacher or therapist access to one assigned child.
  ///
  /// This is the whole of the Module 7 role requirement: membership of the
  /// array *is* the permission, and it is scoped to a single child.
  Future<void> shareChildWith(String childId, String caregiverUid) async {
    if (_user == null) return;
    await _db.doc(FirestorePaths.child(childId)).set({
      FirestorePaths.caregiverIdsField: FieldValue.arrayUnion([caregiverUid]),
    }, SetOptions(merge: true));
  }

  Future<void> revokeAccess(String childId, String caregiverUid) async {
    if (_user == null) return;
    await _db.doc(FirestorePaths.child(childId)).set({
      FirestorePaths.caregiverIdsField: FieldValue.arrayRemove([caregiverUid]),
    }, SetOptions(merge: true));
  }

  Future<void> deleteChild(String childId) async {
    if (_user == null) return;
    await _db.doc(FirestorePaths.child(childId)).delete();
  }
}
