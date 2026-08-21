/// Connectivity boundary for the offline banner and future sync drain.
///
/// A real adapter over `connectivity_plus` arrives with device
/// verification; the static implementation keeps every surface runnable.
abstract interface class ConnectivityService {
  Future<bool> isOnline();

  /// Emits `true` when the device regains connectivity.
  Stream<bool> onChanged();
}

/// Always-online placeholder used until a platform adapter is verified.
class StaticConnectivityService implements ConnectivityService {
  const StaticConnectivityService({this.online = true});

  final bool online;

  @override
  Future<bool> isOnline() async => online;

  @override
  Stream<bool> onChanged() => const Stream.empty();
}
