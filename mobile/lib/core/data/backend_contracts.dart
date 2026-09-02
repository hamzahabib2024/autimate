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

/// The real Firestore implementation lives in
/// `firebase/firestore_child_repository.dart`. The empty stub that used to
/// sit here has been removed so there is only one class with that name.
