import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../gamification/domain/badges.dart';
import '../domain/achievements_timeline.dart';

/// The long view, for a caregiver on a bad day.
///
/// The dashboard already answers "how is this week going". This answers a
/// different question — "how far have we come" — and a weekly view is
/// structurally incapable of answering it.
///
/// Built only from firsts and milestones, never from per-day counts. A
/// timeline of every session would be a log; a timeline of firsts is a
/// story, and the story is what helps on a hard week.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> _achievements = const [];
  bool _loading = true;
  String? _loadedChildId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final childId = widget.appState.selectedChild.id;
    _loadedChildId = childId;
    final sessions =
        await widget.appState.progressRepository.getSessions(childId);
    if (!mounted || _loadedChildId != childId) return;
    setState(() {
      _achievements = const AchievementsBuilder().build(
        sessions: sessions,
        stars: widget.appState.stars,
      );
      _loading = false;
    });
  }

  String _title(AppLocalizations l10n, Achievement achievement) =>
      switch (achievement.kind) {
        AchievementKind.firstSession => l10n.achievementFirstSession,
        AchievementKind.firstActivityType =>
          l10n.achievementFirstActivity(achievement.detail),
        AchievementKind.badge => _badgeTitle(achievement.detail, l10n),
        AchievementKind.streakRecord =>
          l10n.achievementStreak(int.tryParse(achievement.detail) ?? 0),
        AchievementKind.sessionMilestone =>
          l10n.achievementSessions(int.tryParse(achievement.detail) ?? 0),
      };

  String _badgeTitle(String badgeId, AppLocalizations l10n) {
    final definition = badgeCatalog
        .where((badge) => badge.id == badgeId)
        .firstOrNull;
    return definition?.titleFor(widget.appState.locale) ??
        l10n.achievementBadge;
  }

  IconData _icon(Achievement achievement) => switch (achievement.kind) {
    AchievementKind.firstSession => Icons.flag_outlined,
    AchievementKind.firstActivityType => Icons.auto_awesome_outlined,
    AchievementKind.badge => Icons.workspace_premium_outlined,
    AchievementKind.streakRecord => Icons.local_fire_department_outlined,
    AchievementKind.sessionMilestone => Icons.emoji_events_outlined,
  };

  String _dateText(DateTime when) =>
      '${when.day}/${when.month}/${when.year}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.achievementsTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  l10n.achievementsSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_achievements.isEmpty)
                  EmptyState(
                    message: l10n.achievementsEmpty,
                    icon: Icons.timeline_outlined,
                  )
                else
                  for (var i = 0; i < _achievements.length; i++)
                    _TimelineRow(
                      key: ValueKey(
                        'achievement-${_achievements[i].id}',
                      ),
                      title: _title(l10n, _achievements[i]),
                      date: _dateText(_achievements[i].achievedAt),
                      icon: _icon(_achievements[i]),
                      accent: palette.progress,
                      isFirst: i == 0,
                      isLast: i == _achievements.length - 1,
                    ),
              ],
            ),
    );
  }
}

/// One entry, with the connecting rail that makes it read as a timeline
/// rather than a list.
class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.title,
    required this.date,
    required this.icon,
    required this.accent,
    required this.isFirst,
    required this.isLast,
    super.key,
  });

  final String title;
  final String date;
  final IconData icon;
  final Color accent;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst ? Colors.transparent : palette.outline,
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: palette.accentTint(accent, 0.78),
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 2),
                  ),
                  child: Icon(icon, size: 18, color: accent),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : palette.outline,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xs,
                bottom: AppSpacing.sm,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        date,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
