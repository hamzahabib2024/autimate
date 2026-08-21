import '../services/app_services.dart';

abstract interface class ApiClient {
  Future<Object?> get(String path);
  Future<Object?> post(String path, Object body);
}

abstract interface class ChildRepository {
  Future<List<ChildProfile>> getChildren();
  Future<ChildProfile> saveChild(ChildProfile child);
}

class MockChildRepository implements ChildRepository {
  final List<ChildProfile> _children = const [
    ChildProfile(id: 'demo-child', name: 'Ayaan', supportLevel: 'Beginner'),
  ];

  @override
  Future<List<ChildProfile>> getChildren() async =>
      List.unmodifiable(_children);

  @override
  Future<ChildProfile> saveChild(ChildProfile child) async => child;
}

class FirestoreChildRepository implements ChildRepository {
  @override
  Future<List<ChildProfile>> getChildren() async {
    // TODO: BACKEND INTEGRATION - query children owned by the authenticated user.
    return const [];
  }

  @override
  Future<ChildProfile> saveChild(ChildProfile child) async {
    // TODO: BACKEND INTEGRATION - write through Firestore Security Rules.
    return child;
  }
}
