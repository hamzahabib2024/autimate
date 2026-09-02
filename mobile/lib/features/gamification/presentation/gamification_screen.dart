import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../domain/badges.dart';

/// Team-progress view: stars, streak, and shared milestones. The framing
/// is always cooperative — child and caregiver together, never ranked
/// against anyone.
class GamificationScreen extends StatefulWidget {
  const GamificationScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> {
  List<BadgeEvaluation> _badges = const [];
  int _streakDays = 0;
  bool _loading = true;
  String? _loadedChildId;

  String get _childId => widget.appState.selectedChild.id;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await widget.appState.progressRepository.getSessions(
      _childId,
    );
    if (!mounted) return;
    setState(() {
      _badges = evaluateBadges(
        sessionCount: sessions.length,
        streakDays: currentStreak(
          sessionDayKeys(sessions),
          DateTime.now(),
        ),
        stars: widget.appState.stars,
      );
      _streakDays = currentStreak(sessionDayKeys(sessions), DateTime.now());
      _loading = false;
    });
  }

  void _ensureChildData() {
    if (_loadedChildId == _childId) return;
    _loadedChildId = _childId;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    _ensureChildData();
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        _ensureChildData();
        return _buildBody(context, AppLocalizations.of(context));
      },
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    final locale = widget.appState.locale;
    final palette = context.palette;
    final reduced = AppMotion.reduced(
      context,
      sensoryMode: widget.appState.sensoryMode,
    );
    final next = _badges.where((badge) => !badge.earned).toList();
    return ChildTextScale(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.gamificationTileTitle)),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Cooperative framing: the team first, then the shared
                  // total. Nothing here ranks the child against anyone.
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: palette.accentTint(palette.progress, 0.86),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: palette.progress, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Mascot(size: 84),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.coopTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          l10n.coopSubtitle(
                            widget.appState.selectedChild.name,
                          ),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          alignment: WrapAlignment.center,
                          children: [
                            Chip(
                              avatar: Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: palette.progress,
                              ),
                              label: Text(
                                l10n.starsEarned(widget.appState.stars),
                              ),
                            ),
                            Chip(
                              key: const ValueKey('streak-chip'),
                              avatar: Icon(
                                Icons.local_fire_department_outlined,
                                size: 18,
                                color: palette.progress,
                              ),
                              label: Text(l10n.streakDays(_streakDays)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  SectionHeader(
                    title: l10n.nextMilestone,
                    accent: palette.progress,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          SizedBox(
                            key: const ValueKey('progress-ring'),
                            child: ProgressRing(
                              progress:
                                  next.isEmpty ? 1.0 : next.first.progress,
                              size: 140,
                              strokeWidth: 12,
                              color: palette.progress,
                              animate: !reduced,
                              child: Icon(
                                next.isEmpty
                                    ? Icons.emoji_events_outlined
                                    : next.first.definition.icon,
                                size: 44,
                                color: palette.progress,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            next.isEmpty
                                ? l10n.allBadgesEarned
                                : l10n.progressOf(
                                    next.first.current,
                                    next.first.definition.target,
                                  ),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (next.isNotEmpty)
                            Text(
                              next.first.definition.titleFor(locale),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  SectionHeader(
                    title: l10n.badgesSectionTitle,
                    accent: palette.progress,
                  ),
                  for (final badge in _badges)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Card(
                        key: ValueKey('badge-${badge.definition.id}'),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          // Earned and locked differ by fill, border, and
                          // trailing icon — never by colour alone.
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: badge.earned
                                  ? palette.accentTint(palette.progress, 0.72)
                                  : palette.sunken,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: badge.earned
                                    ? palette.progress
                                    : palette.outline,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              badge.definition.icon,
                              color: badge.earned
                                  ? palette.progress
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          title: Text(badge.definition.titleFor(locale)),
                          subtitle: Text(
                            '${badge.definition.descriptionFor(locale)} '
                            '${l10n.progressOf(badge.current, badge.definition.target)}',
                          ),
                          trailing: Icon(
                            badge.earned
                                ? Icons.check_circle
                                : Icons.hourglass_empty,
                            color: badge.earned
                                ? palette.success
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
