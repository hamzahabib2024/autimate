import '../../emotion_recognition/domain/emotion_activity_engine.dart';

/// Reward-frequency dimension of adaptive support: gentler levels pay a
/// star after every completed session, harder levels space rewards out so
/// effort stays meaningful without becoming discouraging.
class RewardPolicy {
  const RewardPolicy();

  /// One star is paid every [sessionsPerStar] completed sessions.
  int sessionsPerStar(SupportLevel level) => switch (level) {
    SupportLevel.beginner => 1,
    SupportLevel.intermediate => 2,
    SupportLevel.advanced => 3,
  };

  /// [completedSessions] counts this child's finished sessions since the
  /// ledger began (per child, persisted).
  bool shouldReward({
    required SupportLevel level,
    required int completedSessions,
  }) =>
      completedSessions > 0 &&
      completedSessions % sessionsPerStar(level) == 0;
}
