import 'package:flutter/material.dart';

/// A single predictable step in a child's daily routine.
class RoutineStep {
  const RoutineStep({
    required this.id,
    required this.titleEn,
    required this.titleUr,
    required this.timeOfDay,
    this.iconCode = Icons.task_alt,
    this.audioCueEn = '',
    this.audioCueUr = '',
  });

  final String id;
  final String titleEn;

  /// Urdu label rendered RTL on the routine screen.
  final String titleUr;

  /// Local 24-hour `HH:mm` time the step is expected to start.
  final String timeOfDay;

  /// Material icon shown for the step; persisted as a code point so the
  /// caregiver editor can personalise steps without new assets.
  final IconData iconCode;

  /// Optional spoken cue (TTS) used instead of the bare title when the
  /// step is announced. Empty string means "no custom cue".
  final String audioCueEn;
  final String audioCueUr;

  String cueFor(Locale? locale) =>
      locale?.languageCode == 'ur' ? audioCueUr : audioCueEn;

  String titleFor(Locale? locale) =>
      locale?.languageCode == 'ur' ? titleUr : titleEn;

  RoutineStep copyWith({
    String? titleEn,
    String? titleUr,
    String? timeOfDay,
    IconData? iconCode,
    String? audioCueEn,
    String? audioCueUr,
  }) =>
      RoutineStep(
        id: id,
        titleEn: titleEn ?? this.titleEn,
        titleUr: titleUr ?? this.titleUr,
        timeOfDay: timeOfDay ?? this.timeOfDay,
        iconCode: iconCode ?? this.iconCode,
        audioCueEn: audioCueEn ?? this.audioCueEn,
        audioCueUr: audioCueUr ?? this.audioCueUr,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'titleEn': titleEn,
    'titleUr': titleUr,
    'timeOfDay': timeOfDay,
    'iconCode': iconCode.codePoint,
    'audioCueEn': audioCueEn,
    'audioCueUr': audioCueUr,
  };

  static RoutineStep fromMap(Map<String, dynamic> map) => RoutineStep(
    id: map['id'] as String? ?? '',
    titleEn: map['titleEn'] as String? ?? '',
    titleUr: map['titleUr'] as String? ?? '',
    timeOfDay: map['timeOfDay'] as String? ?? '08:00',
    iconCode: _iconForCode(map['iconCode'] as int?),
    audioCueEn: map['audioCueEn'] as String? ?? '',
    audioCueUr: map['audioCueUr'] as String? ?? '',
  );

  static IconData _iconForCode(int? codePoint) {
    if (codePoint == null) return Icons.task_alt;
    for (final icon in editorIconChoices) {
      if (icon.codePoint == codePoint && icon.fontFamily == 'MaterialIcons') {
        return icon;
      }
    }
    return Icons.task_alt;
  }
}

/// Icon palette offered by the caregiver routine editor. Kept small and
/// concrete so choices stay predictable for children.
const List<IconData> editorIconChoices = [
  Icons.task_alt,
  Icons.restaurant,
  Icons.checkroom,
  Icons.school,
  Icons.directions_bus,
  Icons.bedtime,
  Icons.brush,
  Icons.sports_soccer,
  Icons.bathtub_outlined,
  Icons.music_note,
];

/// A parent-approved controlled change applied to one known routine step
/// for one day (flexibility training).
class FlexibilityChange {
  const FlexibilityChange({
    required this.stepId,
    required this.newTitleEn,
    required this.newTitleUr,
  });

  final String stepId;

  /// Replacement labels shown to the child for that day. Empty strings
  /// keep the original label and only flag the change visually.
  final String newTitleEn;
  final String newTitleUr;

  Map<String, dynamic> toMap() => {
    'stepId': stepId,
    'newTitleEn': newTitleEn,
    'newTitleUr': newTitleUr,
  };

  static FlexibilityChange fromMap(Map<String, dynamic> map) =>
      FlexibilityChange(
        stepId: map['stepId'] as String? ?? '',
        newTitleEn: map['newTitleEn'] as String? ?? '',
        newTitleUr: map['newTitleUr'] as String? ?? '',
      );
}

/// Seeded default routine used until a caregiver edits steps.
const List<RoutineStep> defaultRoutineSteps = [
  RoutineStep(
    id: 'breakfast',
    titleEn: 'Breakfast',
    titleUr: 'ناشتہ',
    timeOfDay: '08:00',
    iconCode: Icons.restaurant,
  ),
  RoutineStep(
    id: 'get_dressed',
    titleEn: 'Get dressed',
    titleUr: 'کپڑے پہنو',
    timeOfDay: '08:30',
    iconCode: Icons.checkroom,
  ),
  RoutineStep(
    id: 'school_time',
    titleEn: 'School time',
    titleUr: 'اسکول کا وقت',
    timeOfDay: '09:00',
    iconCode: Icons.school,
  ),
];
