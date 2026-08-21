import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/services/tts_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/routine_models.dart';
import '../domain/routine_repository.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final RoutineReminderEngine _reminderEngine = const RoutineReminderEngine();
  final Set<String> _announcedToday = {};
  List<RoutineStep> _steps = [];
  Set<String> _completed = {};
  bool _loading = true;
  bool _remindersEnabled = true;
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

  String get _childId => widget.appState.children.first.id;

  Future<void> _load() async {
    final steps = await widget.appState.routineRepository.getSteps();
    final completed = await widget.appState.routineRepository
        .completedStepIdsFor(_childId, DateTime.now());
    if (!mounted) return;
    setState(() {
      _steps = steps;
      _completed = completed;
      _loading = false;
    });
    _checkReminders();
  }

  Future<void> _toggleStep(RoutineStep step, bool value) async {
    await widget.appState.routineRepository.setStepCompleted(
      _childId,
      DateTime.now(),
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
  }

  void _checkReminders() {
    if (!_remindersEnabled || _loading) return;
    if (_steps.isEmpty) return;
    final due = _reminderEngine.dueStepIds(
      steps: _steps,
      completedIds: _completed,
      announcedIds: _announcedToday,
      now: DateTime.now(),
    );
    if (due.isEmpty) return;
    setState(() => _announcedToday.addAll(due));
    final tts = widget.appState.ttsService;
    final urdu = widget.appState.locale.languageCode == 'ur';
    for (final id in due) {
      final step = _steps.firstWhere((step) => step.id == id);
      if (tts is QueuedTtsService) {
        tts.enqueue(urdu ? step.titleUr : step.titleEn, widget.appState.locale);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = _steps.isEmpty ? 0.0 : _completed.length / _steps.length;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.routineTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.oneStepAtATime,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Semantics(
            label: l10n.routineProgressLabel,
            value: '${(progress * 100).round()}%',
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.stepsDone(_completed.length, _steps.length)),
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
            ..._steps.map(
              (step) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(child: Icon(_iconFor(step.id))),
                  title: Text(step.titleEn),
                  subtitle: Text(step.titleUr),
                  trailing: Checkbox(
                    value: _completed.contains(step.id),
                    onChanged: (value) => _toggleStep(step, value ?? false),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: OutlinedButton.icon(
              onPressed: () async {
                for (final step in _steps) {
                  await widget.appState.routineRepository.setStepCompleted(
                    _childId,
                    DateTime.now(),
                    step.id,
                    false,
                  );
                }
                setState(_announcedToday.clear);
                await _load();
              },
              icon: const Icon(Icons.restart_alt),
              label: Text(l10n.resetToday),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String id) => switch (id) {
    'breakfast' => Icons.restaurant,
    'get_dressed' => Icons.checkroom,
    'school_time' => Icons.school,
    _ => Icons.task_alt,
  };
}
