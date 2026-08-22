import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/data/local_store.dart';
import 'routine_models.dart';

/// Contract for reading routine steps and per-day completion state.
abstract interface class RoutineRepository {
  Future<List<RoutineStep>> getSteps();
  Future<void> saveSteps(List<RoutineStep> steps);
  Future<Set<String>> completedStepIdsFor(String childId, DateTime day);
  Future<void> setStepCompleted(
    String childId,
    DateTime day,
    String stepId,
    bool completed,
  );
  Future<FlexibilityChange?> flexibilityChangeFor(
    String childId,
    DateTime day,
  );
  Future<void> setFlexibilityChange(
    String childId,
    DateTime day,
    FlexibilityChange? change,
  );
}

/// Durable offline implementation backed by the shared [KeyValueStore].
///
/// Completion is tracked per calendar day so the routine resets naturally
/// every morning without any network access.
class LocalRoutineRepository implements RoutineRepository {
  LocalRoutineRepository({
    required KeyValueStore store,
    this.seedSteps = defaultRoutineSteps,
  }) : _store = store;

  static const String _stepsKey = 'autimate.routine.steps.v1';

  String _flexKey(String childId, DateTime day) =>
      'autimate.flex.$childId.${_dayId(day)}';

  final KeyValueStore _store;
  final List<RoutineStep> seedSteps;

  String _dayKey(String childId, DateTime day) =>
      'autimate.routine.$childId.${_dayId(day)}';

  static String _dayId(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  @visibleForTesting
  static String dayIdForTest(DateTime day) => _dayId(day);

  @override
  Future<List<RoutineStep>> getSteps() async {
    final raw = await _store.read(_stepsKey);
    if (raw == null || raw.isEmpty) return List.unmodifiable(seedSteps);
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return List.unmodifiable(seedSteps);
      final steps = decoded
          .whereType<Map<String, dynamic>>()
          .map(RoutineStep.fromMap)
          .where((step) => step.id.isNotEmpty)
          .toList();
      return List.unmodifiable(steps.isEmpty ? seedSteps : steps);
    } on FormatException {
      return List.unmodifiable(seedSteps);
    }
  }

  @override
  Future<void> saveSteps(List<RoutineStep> steps) =>
      _store.write(_stepsKey, jsonEncode(steps.map((s) => s.toMap()).toList()));

  @override
  Future<Set<String>> completedStepIdsFor(String childId, DateTime day) async {
    final raw = await _store.read(_dayKey(childId, day));
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <String>{};
      return decoded.whereType<String>().toSet();
    } on FormatException {
      return <String>{};
    }
  }

  @override
  Future<void> setStepCompleted(
    String childId,
    DateTime day,
    String stepId,
    bool completed,
  ) async {
    final key = _dayKey(childId, day);
    final current = await completedStepIdsFor(childId, day).then(
      (ids) => ids.toSet(),
    );
    if (completed) {
      current.add(stepId);
    } else {
      current.remove(stepId);
    }
    await _store.write(key, jsonEncode(current.toList()..sort()));
  }

  @override
  Future<FlexibilityChange?> flexibilityChangeFor(
    String childId,
    DateTime day,
  ) async {
    final raw = await _store.read(_flexKey(childId, day));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return FlexibilityChange.fromMap(decoded);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> setFlexibilityChange(
    String childId,
    DateTime day,
    FlexibilityChange? change,
  ) async {
    if (change == null) {
      await _store.write(_flexKey(childId, day), '');
      return;
    }
    await _store.write(
      _flexKey(childId, day),
      jsonEncode(change.toMap()),
    );
  }
}

/// One pending transition notification for a step.
class TransitionWarning {
  const TransitionWarning({
    required this.stepId,
    required this.countdown,
    required this.minutesUntil,
  });

  final String stepId;

  /// True while inside the configurable lead window ("5 minutes left");
  /// false once the scheduled time itself has arrived.
  final bool countdown;

  /// Whole minutes remaining until the step starts (countdown only).
  final int minutesUntil;
}

/// Pure reminder decision logic: which routine steps need a transition
/// warning right now?
///
/// Two phases per step, both suppressed once completed or announced:
/// 1. countdown — inside the [RoutineReminderEngine.pendingWarnings] lead
///    window before the scheduled time ("5 minutes left"),
/// 2. due — at/after the scheduled time (the step is announced itself).
class RoutineReminderEngine {
  const RoutineReminderEngine();

  /// Returns warnings (countdowns first-come) that should be surfaced at
  /// [now].
  List<TransitionWarning> pendingWarnings({
    required List<RoutineStep> steps,
    required Set<String> completedIds,
    required Set<String> announcedDueIds,
    required Set<String> announcedCountdownIds,
    required int leadMinutes,
    required DateTime now,
  }) {
    final minuteOfDay = now.hour * 60 + now.minute;
    final warnings = <TransitionWarning>[];
    for (final step in steps) {
      if (completedIds.contains(step.id)) continue;
      final stepMinute = _parseMinute(step.timeOfDay);
      // Due phase: the scheduled time has arrived.
      if (stepMinute <= minuteOfDay) {
        if (!announcedDueIds.contains(step.id)) {
          warnings.add(
            TransitionWarning(stepId: step.id, countdown: false, minutesUntil: 0),
          );
        }
        continue;
      }
      // Countdown phase: within the lead window before the step.
      final minutesUntil = stepMinute - minuteOfDay;
      if (leadMinutes > 0 &&
          minutesUntil <= leadMinutes &&
          !announcedCountdownIds.contains(step.id)) {
        warnings.add(
          TransitionWarning(
            stepId: step.id,
            countdown: true,
            minutesUntil: minutesUntil,
          ),
        );
      }
    }
    return warnings;
  }

  /// Returns step ids whose scheduled time has arrived (or passed).
  List<String> dueStepIds({
    required List<RoutineStep> steps,
    required Set<String> completedIds,
    required Set<String> announcedIds,
    required DateTime now,
  }) {
    return [
      for (final warning in pendingWarnings(
        steps: steps,
        completedIds: completedIds,
        announcedDueIds: announcedIds,
        announcedCountdownIds: const <String>{},
        leadMinutes: 0,
        now: now,
      ))
        warning.stepId,
    ];
  }

  static int parseMinute(String timeOfDay) {
    final parts = timeOfDay.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return hour.clamp(0, 23) * 60 + minute.clamp(0, 59);
  }

  int _parseMinute(String timeOfDay) => parseMinute(timeOfDay);
}
