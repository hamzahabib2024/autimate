import 'dart:convert';

import '../../../core/data/local_store.dart';

/// Per-child interest profile persistence (caregiver-managed).
abstract interface class InterestRepository {
  Future<Set<String>> interestsFor(String childId);
  Future<void> setInterests(String childId, Set<String> ids);
}

/// Durable offline implementation over the shared [KeyValueStore].
class LocalInterestRepository implements InterestRepository {
  LocalInterestRepository({required KeyValueStore store}) : _store = store;

  final KeyValueStore _store;

  String _key(String childId) => 'autimate.interests.$childId';

  @override
  Future<Set<String>> interestsFor(String childId) async {
    final raw = await _store.read(_key(childId));
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <String>{};
      return decoded.whereType<String>().toSet();
    } on FormatException {
      return <String>{};
    }
  }

  @override
  Future<void> setInterests(String childId, Set<String> ids) =>
      _store.write(_key(childId), jsonEncode(ids.toList()..sort()));
}
