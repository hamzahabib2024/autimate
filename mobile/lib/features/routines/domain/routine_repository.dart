import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/data/local_store.dart';
import 'routine_models.dart';

/// Contract for reading routine steps and per-day completion state.
abstract interface class RoutineRepository {
  Future<List<RoutineStep>> getSteps();
  Future<Set<String>> completedStepIdsFor(String childId, DateTime day);
  Future<void> setStepCompleted(
    String childId,
    DateTime day,
    String stepId,
    bool completed,
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
}

/// Pure reminder decision logic: which routine steps need a transition
/// warning right now?
///
/// A step is due when its scheduled time has arrived (or passed), it is not
/// completed yet, and it has not already been announced today.
class RoutineReminderEngine {
  const RoutineReminderEngine();

  /// Returns step ids that should be announced at [now].
  List<String> dueStepIds({
    required List<RoutineStep> steps,
    required Set<String> completedIds,
    required Set<String> announcedIds,
    required DateTime now,
  }) {
    final minuteOfDay = now.hour * 60 + now.minute;
    return [
      for (final step in steps)
        if (!completedIds.contains(step.id) &&
            !announcedIds.contains(step.id) &&
            _parseMinute(step.timeOfDay) <= minuteOfDay)
            step.id,
    ];
  }

  int _parseMinute(String timeOfDay) {
    final parts = timeOfDay.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return hour.clamp(0, 23) * 60 + minute.clamp(0, 59);
  }
}
