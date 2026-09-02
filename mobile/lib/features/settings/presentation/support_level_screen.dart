import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../emotion_recognition/domain/emotion_activity_engine.dart'
    show SupportLevel;
import '../../gamification/domain/reward_policy.dart';

/// Caregiver control for the child's adaptive support level. Choosing a
/// level pins the starting point; the lock stops automatic promotion and
/// demotion entirely. Everything applies live and persists per child.
class SupportLevelScreen extends StatelessWidget {
  const SupportLevelScreen({required this.appState, super.key});

  final AppState appState;

  String _levelLabel(AppLocalizations l10n, SupportLevel level) =>
      switch (level) {
        SupportLevel.intermediate => l10n.intermediateSupportLevel,
        SupportLevel.advanced => l10n.advancedSupportLevel,
        SupportLevel.beginner => l10n.beginnerSupportLevel,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final childId = appState.selectedChild.id;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportLevel)),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final override = appState.supportOverrideFor(childId);
          final locked = appState.isSupportLockedFor(childId);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                l10n.levelPickerForChild(appState.selectedChild.name),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              RadioGroup<SupportLevel?>(
                groupValue: override,
                onChanged: (value) => appState.setSupportPreference(
                  childId: childId,
                  level: value,
                  locked: locked,
                ),
                child: Column(
                  children: [
                    RadioListTile<SupportLevel?>(
                      key: const ValueKey('level-option-auto'),
                      value: null,
                      title: Text(l10n.levelAutomaticTitle),
                      subtitle: Text(l10n.levelAutomaticSubtitle),
                    ),
                    for (final level in SupportLevel.values)
                      RadioListTile<SupportLevel?>(
                        key: ValueKey('level-option-${level.name}'),
                        value: level,
                        title: Text(_levelLabel(l10n, level)),
                        subtitle: Text(
                          level == SupportLevel.beginner
                              ? l10n.rewardCadenceEverySession
                              : l10n.rewardCadenceEveryN(
                                  const RewardPolicy()
                                      .sessionsPerStar(level),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),
              SwitchListTile(
                key: const ValueKey('level-lock'),
                secondary: Icon(
                  locked ? Icons.lock : Icons.lock_open,
                ),
                title: Text(l10n.levelLockTitle),
                subtitle: Text(l10n.levelLockSubtitle),
                value: locked,
                onChanged: (value) => appState.setSupportPreference(
                  childId: childId,
                  level: override,
                  locked: value,
                ),
              ),
              if (locked)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.levelLockedNotice(
                      _levelLabel(
                        l10n,
                        override ?? appState.effectiveSupportFor(childId),
                      ),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
