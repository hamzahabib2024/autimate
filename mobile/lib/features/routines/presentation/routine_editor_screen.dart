import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/presentation/parent_gate_screen.dart';
import '../domain/routine_models.dart';

/// Caregiver-only editor for the daily routine: add/edit/remove steps
/// (bilingual titles, time, icon, optional spoken cues), tune the
/// transition-warning lead time, and plan one friendly change for today.
class RoutineEditorScreen extends StatefulWidget {
  const RoutineEditorScreen({required this.appState, super.key});

  final AppState appState;

  /// Pushes this screen behind the parent gate.
  static Future<void> openGated(BuildContext context, AppState appState) async {
    final passed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ParentGateScreen(appState: appState),
      ),
    );
    if (passed == true && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RoutineEditorScreen(appState: appState),
        ),
      );
    }
  }

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  List<RoutineStep> _steps = [];
  FlexibilityChange? _change;
  bool _loading = true;

  String? _flexStepId;
  final _flexEnController = TextEditingController();
  final _flexUrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _flexEnController.dispose();
    _flexUrController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = widget.appState.routineRepository;
    final steps = await repo.getSteps();
    final change =
        await repo.flexibilityChangeFor(widget.appState.selectedChild.id, DateTime.now());
    if (!mounted) return;
    setState(() {
      _steps = steps;
      _change = change;
      // Keep the picker consistent when its step disappears.
      if (_flexStepId != null && !steps.any((step) => step.id == _flexStepId)) {
        _flexStepId = steps.isNotEmpty ? steps.first.id : null;
      }
      _flexStepId ??= change?.stepId ?? (steps.isNotEmpty ? steps.first.id : null);
      _loading = false;
    });
  }

  Future<void> _persistSteps(List<RoutineStep> steps) async {
    await widget.appState.routineRepository.saveSteps(steps);
    await _load();
  }

  Future<void> _openStepDialog([RoutineStep? existing]) async {
    final result = await showDialog<RoutineStep>(
      context: context,
      builder: (_) => _StepDialog(existing: existing, appState: widget.appState),
    );
    if (result == null) return;
    final steps = [..._steps];
    final index = steps.indexWhere((step) => step.id == result.id);
    if (index >= 0) {
      steps[index] = result;
    } else {
      steps.add(result);
    }
    await _persistSteps(steps);
  }

  Future<void> _removeStep(RoutineStep step) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.routineDeleteStepTitle),
        content: Text(l10n.routineDeleteStepBody(step.titleEn)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (_change?.stepId == step.id) {
      await widget.appState.routineRepository.setFlexibilityChange(
        widget.appState.selectedChild.id,
        DateTime.now(),
        null,
      );
    }
    await _persistSteps(
      _steps.where((candidate) => candidate.id != step.id).toList(),
    );
  }

  Future<void> _applyFlexibilityChange() async {
    final stepId = _flexStepId;
    if (stepId == null) return;
    final change = FlexibilityChange(
      stepId: stepId,
      newTitleEn: _flexEnController.text.trim(),
      newTitleUr: _flexUrController.text.trim(),
    );
    await widget.appState.routineRepository.setFlexibilityChange(
      widget.appState.selectedChild.id,
      DateTime.now(),
      change,
    );
    await _load();
  }

  Future<void> _clearFlexibilityChange() async {
    await widget.appState.routineRepository.setFlexibilityChange(
      widget.appState.selectedChild.id,
      DateTime.now(),
      null,
    );
    _flexEnController.clear();
    _flexUrController.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.routineEditorTitle)),
      body: AnimatedBuilder(
        animation: widget.appState,
        builder: (context, _) => _buildBody(context, l10n),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final lead = widget.appState.transitionLeadMinutes;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l10n.leadMinutesLabel,
            style: Theme.of(context).textTheme.titleMedium),
        Slider(
          key: const ValueKey('lead-slider'),
          value: lead.toDouble(),
          min: 0,
          max: 30,
          divisions: 30,
          label: '$lead',
          onChanged: (value) =>
              widget.appState.setTransitionLeadMinutes(value.round()),
        ),
        Text(l10n.transitionWarningsSubtitle),
        const SizedBox(height: 16),

        for (final step in _steps) ...[
          Card(
            child: ListTile(
              key: ValueKey('editor-step-${step.id}'),
              leading: CircleAvatar(child: Icon(step.iconCode)),
              title: Text('${step.titleEn} · ${step.timeOfDay}'),
              subtitle: Text(step.titleUr),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: l10n.routineEditTooltip,
                    onPressed: () => _openStepDialog(step),
                  ),
                  IconButton(
                    key: ValueKey('delete-step-${step.id}'),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.deleteAction,
                    onPressed: () => _removeStep(step),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: FilledButton.tonalIcon(
            key: const ValueKey('add-step'),
            onPressed: () => _openStepDialog(),
            icon: const Icon(Icons.add),
            label: Text(l10n.routineAddStep),
          ),
        ),
        const SizedBox(height: 24),
        Semantics(
          header: true,
          child: Text(l10n.flexibilityTitle,
              style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 8),
        Text(l10n.flexibilityExplanation),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: const ValueKey('flex-step-picker'),
          initialValue: _flexStepId,
          decoration:
              InputDecoration(labelText: l10n.flexibilityPickStep),
          items: [
            for (final step in _steps)
              DropdownMenuItem(value: step.id, child: Text(step.titleEn)),
          ],
          onChanged: (value) => setState(() => _flexStepId = value),
        ),
        TextField(
          controller: _flexEnController,
          decoration:
              InputDecoration(labelText: l10n.flexibilityNewLabelEn),
        ),
        TextField(
          controller: _flexUrController,
          decoration:
              InputDecoration(labelText: l10n.flexibilityNewLabelUr),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: FilledButton.icon(
            key: const ValueKey('flex-apply'),
            onPressed:
                _steps.isEmpty ? null : () => _applyFlexibilityChange(),
            icon: const Icon(Icons.auto_awesome),
            label: Text(l10n.flexibilityApply),
          ),
        ),
        if (_change != null) ...[
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: Text(l10n.flexibilityPlannedToday),
              trailing: TextButton(
                key: const ValueKey('flex-clear'),
                onPressed: _clearFlexibilityChange,
                child: Text(l10n.flexibilityClear),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StepDialog extends StatefulWidget {
  const _StepDialog({this.existing, required this.appState});

  final RoutineStep? existing;
  final AppState appState;

  @override
  State<_StepDialog> createState() => _StepDialogState();
}

class _StepDialogState extends State<_StepDialog> {
  late TimeOfDay _time = _parseTime(widget.existing?.timeOfDay);
  late IconData _icon = widget.existing?.iconCode ?? Icons.task_alt;
  late final TextEditingController _enController =
      TextEditingController(text: widget.existing?.titleEn ?? '');
  late final TextEditingController _urController =
      TextEditingController(text: widget.existing?.titleUr ?? '');
  late final TextEditingController _cueEnController =
      TextEditingController(text: widget.existing?.audioCueEn ?? '');
  late final TextEditingController _cueUrController =
      TextEditingController(text: widget.existing?.audioCueUr ?? '');

  static TimeOfDay _parseTime(String? value) {
    final parts = (value ?? '08:00').split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.first) ?? 8,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  String get _formattedTime =>
      '${_time.hour.toString().padLeft(2, '0')}:'
      '${_time.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _enController.dispose();
    _urController.dispose();
    _cueEnController.dispose();
    _cueUrController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final en = _enController.text.trim();
    final ur = _urController.text.trim();
    if (en.isEmpty || ur.isEmpty) return;
    Navigator.of(context).pop(
      (widget.existing ?? RoutineStep(
        id: 'step-${DateTime.now().microsecondsSinceEpoch}',
        titleEn: en,
        titleUr: ur,
        timeOfDay: _formattedTime,
      ))
          .copyWith(
            titleEn: en,
            titleUr: ur,
            timeOfDay: _formattedTime,
            iconCode: _icon,
            audioCueEn: _cueEnController.text.trim(),
            audioCueUr: _cueUrController.text.trim(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final valid =
        _enController.text.trim().isNotEmpty && _urController.text.trim().isNotEmpty;
    return AlertDialog(
      title: Text(widget.existing == null
          ? l10n.routineAddStep
          : l10n.routineEditTooltip),
      content: SizedBox(
        width: 420,
        child: ListView(
          shrinkWrap: true,
          children: [
            TextField(
              key: const ValueKey('step-title-en'),
              controller: _enController,
              decoration: InputDecoration(labelText: l10n.stepTitleEnLabel),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              key: const ValueKey('step-title-ur'),
              controller: _urController,
              decoration: InputDecoration(labelText: l10n.stepTitleUrLabel),
              onChanged: (_) => setState(() {}),
            ),
            ListTile(
              key: const ValueKey('step-time'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: Text(l10n.stepTimeLabel),
              subtitle: Text(_formattedTime),
              onTap: _pickTime,
            ),
            Text(l10n.stepIconLabel),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final icon in editorIconChoices)
                  ChoiceChip(
                    label: Icon(icon, size: 20),
                    selected: _icon.codePoint == icon.codePoint,
                    onSelected: (_) => setState(() => _icon = icon),
                  ),
              ],
            ),
            TextField(
              controller: _cueEnController,
              decoration: InputDecoration(labelText: l10n.stepCueEnLabel),
            ),
            TextField(
              controller: _cueUrController,
              decoration: InputDecoration(labelText: l10n.stepCueUrLabel),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const ValueKey('step-save'),
          onPressed: valid ? _save : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
