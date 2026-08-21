/// Compile-time environment configuration.
///
/// Values are supplied with `--dart-define` (see `.env.example` at the
/// repository root). Every value has a safe default so the app runs in
/// mock/offline mode without any credentials.
class AppConfig {
  const AppConfig({
    this.environment = 'mock',
    this.firebaseApiKey = '',
    this.firebaseAppId = '',
    this.firebaseProjectId = '',
    this.firebaseMessagingSenderId = '',
    this.firebaseStorageBucket = '',
  });

  /// Builds the configuration from `--dart-define` entries.
  factory AppConfig.fromEnvironment() => AppConfig(
    environment: const String.fromEnvironment('AUTIMATE_ENVIRONMENT'),
    firebaseApiKey: const String.fromEnvironment('AUTIMATE_FIREBASE_API_KEY'),
    firebaseAppId: const String.fromEnvironment('AUTIMATE_FIREBASE_APP_ID'),
    firebaseProjectId: const String.fromEnvironment(
      'AUTIMATE_FIREBASE_PROJECT_ID',
    ),
    firebaseMessagingSenderId: const String.fromEnvironment(
      'AUTIMATE_FIREBASE_MESSAGING_SENDER_ID',
    ),
    firebaseStorageBucket: const String.fromEnvironment(
      'AUTIMATE_FIREBASE_STORAGE_BUCKET',
    ),
  );

  final String environment;
  final String firebaseApiKey;
  final String firebaseAppId;
  final String firebaseProjectId;
  final String firebaseMessagingSenderId;
  final String firebaseStorageBucket;

  /// True when real Firebase credentials were injected at build time.
  bool get firebaseConfigured =>
      firebaseApiKey.isNotEmpty &&
      firebaseProjectId.isNotEmpty &&
      firebaseAppId.isNotEmpty;

  /// True when the app should run against mock adapters only.
  bool get useMockBackend => !firebaseConfigured || environment == 'mock';
}
