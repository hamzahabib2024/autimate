import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../core/services/tts_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/routine_models.dart';
import '../domain/routine_repository.dart';
import 'routine_editor_screen.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({required this.appState, this.clock, super.key});

  final AppState appState;

  /// Overridable for tests so transition warnings are deterministic.
  final DateTime Function()? clock;

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final RoutineReminderEngine _reminderEngine = const RoutineReminderEngine();
  final Set<String> _announcedToday = {};
  final Set<String> _announcedCountdowns = {};
  List<RoutineStep> _steps = [];
  Set<String> _completed = {};
  FlexibilityChange? _change;
  bool _loading = true;
  bool _remindersEnabled = true;

  /// Bonus star for completing a planned change, once per session.
  String? _bonusAwardedFor;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _load();
    // Transition warnings are checked once a minute while the screen is open.
    _ticker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkReminders(),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _childId => widget.appState.selectedChild.id;

  DateTime _now() => widget.clock?.call() ?? DateTime.now();

  String? _loadedChildId;

  /// Reloads per-child completion data when the active profile changes.
  void _ensureChildData() {
    if (_loadedChildId == _childId) return;
    _loadedChildId = _childId;
    unawaited(_load());
  }

  Future<void> _load() async {
    final repo = widget.appState.routineRepository;
    final steps = await repo.getSteps();
    final today = _now();
    final completed = await repo.completedStepIdsFor(_childId, today);
    final change = await repo.flexibilityChangeFor(_childId, today);
    if (!mounted) return;
    setState(() {
      _steps = steps;
      _completed = completed;
      _change = change;
      _loading = false;
    });
    _checkReminders();
  }

  Future<void> _toggleStep(RoutineStep step, bool value) async {
    await widget.appState.routineRepository.setStepCompleted(
      _childId,
      _now(),
      step.id,
      value,
    );
    setState(() {
      if (value) {
        _completed.add(step.id);
      } else {
        _completed.remove(step.id);
      }
    });
    // Positive reinforcement: finishing a planned change earns a bonus.
    final change = _change;
    if (value &&
        change != null &&
        change.stepId == step.id &&
        _bonusAwardedFor != change.stepId) {
      _bonusAwardedFor = change.stepId;
      widget.appState.awardStars(1);
    }
  }

  void _speak(String text) {
    final tts = widget.appState.ttsService;
    if (tts is QueuedTtsService) {
      tts.enqueue(text, widget.appState.locale);
    }
  }

  void _checkReminders() {
    if (!_remindersEnabled || _loading) return;
    if (_steps.isEmpty) return;
    final warnings = _reminderEngine.pendingWarnings(
      steps: _steps,
      completedIds: _completed,
      announcedDueIds: _announcedToday,
      announcedCountdownIds: _announcedCountdowns,
      leadMinutes: widget.appState.transitionLeadMinutes,
      now: _now(),
    );
    if (warnings.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      for (final warning in warnings) {
        final step = _stepById(warning.stepId);
        if (warning.countdown) {
          _announcedCountdowns.add(warning.stepId);
          _speak(
            l10n.countdownWarning(warning.minutesUntil, _titleFor(step)),
          );
        } else {
          _announcedToday.add(warning.stepId);
          final cue = step.cueFor(widget.appState.locale);
          _speak(cue.isNotEmpty ? cue : _titleFor(step));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _ensureChildData();
    final progress = _steps.isEmpty ? 0.0 : _completed.length / _steps.length;
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        _ensureChildData();
        return _buildBody(context, AppLocalizations.of(context), progress);
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    double progress,
  ) {
    final countdowns = _steps.isEmpty
        ? const <TransitionWarning>[]
        // Banners stay visible for the whole lead window; the announced
        // set only de-duplicates the spoken announcement.
        : _reminderEngine.pendingWarnings(
            steps: _steps,
            completedIds: _completed,
            announcedDueIds: _announcedToday,
            announcedCountdownIds: const <String>{},
            leadMinutes: widget.appState.transitionLeadMinutes,
            now: _now(),
          ).where((warning) => warning.countdown).toList();
    final change = _change;
    final changeCompleted =
        change != null && _completed.contains(change.stepId);
    final palette = context.palette;
    final reduced = AppMotion.reduced(
      context,
      sensoryMode: widget.appState.sensoryMode,
    );
    return ChildTextScale(
      child: Scaffold(
      appBar: AppBar(
        title: Text(l10n.routineTitle),
        actions: [
          IconButton(
            key: const ValueKey('routine-edit'),
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.routineEditTooltip,
            onPressed: () async {
              await RoutineEditorScreen.openGated(context, widget.appState);
              await _load();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // The day at a glance. A ring reads as "how much is left" faster
          // than a bar does, which is the question this screen answers.
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: palette.accentTint(palette.routine, 0.86),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: palette.routine, width: 2),
            ),
            child: Row(
              children: [
                Semantics(
                  label: l10n.routineProgressLabel,
                  value: '${(progress * 100).round()}%',
                  child: ProgressRing(
                    progress: progress,
                    size: 84,
                    strokeWidth: 9,
                    color: palette.routine,
                    animate: !reduced,
                    child: Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.oneStepAtATime,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        l10n.stepsDone(_completed.length, _steps.length),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (countdowns.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final warning in countdowns)
              Card(
                key: ValueKey('countdown-${warning.stepId}'),
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.hourglass_top_outlined),
                  title: Text(
                    l10n.countdownWarning(
                      warning.minutesUntil,
                      _titleFor(_stepById(warning.stepId)),
                    ),
                  ),
                ),
              ),
          ],
          if (change != null) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: ListTile(
                key: const ValueKey('flex-banner'),
                leading: Icon(
                  changeCompleted ? Icons.celebration_outlined : Icons.auto_awesome,
                ),
                title: Text(
                  changeCompleted
                      ? l10n.flexibilityWellDone
                      : l10n.flexibilityPlannedToday,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(l10n.transitionWarnings),
            subtitle: Text(l10n.transitionWarningsSubtitle),
            value: _remindersEnabled,
            onChanged: (value) {
              setState(() => _remindersEnabled = value);
              if (value) _checkReminders();
            },
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            ..._steps.map((step) => _buildStepTile(step, change)),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: OutlinedButton.icon(
              onPressed: () async {
                for (final step in _steps) {
                  await widget.appState.routineRepository.setStepCompleted(
                    _childId,
                    _now(),
                    step.id,
                    false,
                  );
                }
                setState(() {
                  _announcedToday.clear();
                  _announcedCountdowns.clear();
                  _bonusAwardedFor = null;
                });
                await _load();
              },
              icon: const Icon(Icons.restart_alt),
              label: Text(l10n.resetToday),
            ),
          ),
        ],
      ),
      ),
    );
  }

  RoutineStep _stepById(String id) =>
      _steps.firstWhere((step) => step.id == id, orElse: () => _steps.first);

  String _titleFor(RoutineStep step) {
    final change = _change;
    final localeUr = widget.appState.locale.languageCode == 'ur';
    if (change != null && change.stepId == step.id) {
      final override = localeUr ? change.newTitleUr : change.newTitleEn;
      if (override.isNotEmpty) return override;
    }
    return localeUr ? step.titleUr : step.titleEn;
  }

  Widget _buildStepTile(RoutineStep step, FlexibilityChange? change) {
    final l10n = AppLocalizations.of(context);
    final localeUr = widget.appState.locale.languageCode == 'ur';
    final changed = change?.stepId == step.id;
    final title = _titleFor(step);
    // The subtitle always shows the original label in the other language
    // so the step stays recognisable even when a friendly change renames it.
    final subtitle = localeUr ? step.titleEn : step.titleUr;
    final palette = context.palette;
    final done = _completed.contains(step.id);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        key: ValueKey('routine-step-${step.id}'),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: done ? palette.success : palette.outline,
            width: done ? 2 : 1,
          ),
        ),
        // Completion is signalled by fill, icon, and border together, so
        // it never depends on colour perception alone.
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: done
                ? palette.accentTint(palette.success, 0.74)
                : palette.accentTint(palette.routine, 0.84),
            shape: BoxShape.circle,
            border: Border.all(
              color: done ? palette.success : palette.routine,
              width: 2,
            ),
          ),
          child: Icon(
            done ? Icons.check : step.iconCode,
            color: done ? palette.success : palette.routine,
          ),
        ),
        title: Text(title),
        subtitle: changed
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subtitle),
                  Chip(
                    avatar: const Icon(Icons.auto_awesome, size: 14),
                    label: Text(l10n.flexibilityBadge),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              )
            : Text(subtitle),
        trailing: Checkbox(
          key: ValueKey('routine-check-${step.id}'),
          value: _completed.contains(step.id),
          onChanged: (value) => _toggleStep(step, value ?? false),
        ),
      ),
    );
  }
}
