/// A single predictable step in a child's daily routine.
class RoutineStep {
  const RoutineStep({
    required this.id,
    required this.titleEn,
    required this.titleUr,
    required this.timeOfDay,
  });

  final String id;
  final String titleEn;

  /// Urdu label rendered RTL on the routine screen.
  final String titleUr;

  /// Local 24-hour `HH:mm` time the step is expected to start.
  final String timeOfDay;

  RoutineStep copyWith({String? timeOfDay}) => RoutineStep(
    id: id,
    titleEn: titleEn,
    titleUr: titleUr,
    timeOfDay: timeOfDay ?? this.timeOfDay,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'titleEn': titleEn,
    'titleUr': titleUr,
    'timeOfDay': timeOfDay,
  };

  static RoutineStep fromMap(Map<String, dynamic> map) => RoutineStep(
    id: map['id'] as String? ?? '',
    titleEn: map['titleEn'] as String? ?? '',
    titleUr: map['titleUr'] as String? ?? '',
    timeOfDay: map['timeOfDay'] as String? ?? '08:00',
  );
}

/// Seeded default routine used until a caregiver edits steps.
const List<RoutineStep> defaultRoutineSteps = [
  RoutineStep(
    id: 'breakfast',
    titleEn: 'Breakfast',
    titleUr: 'ناشتہ',
    timeOfDay: '08:00',
  ),
  RoutineStep(
    id: 'get_dressed',
    titleEn: 'Get dressed',
    titleUr: 'کپڑے پہنو',
    timeOfDay: '08:30',
  ),
  RoutineStep(
    id: 'school_time',
    titleEn: 'School time',
    titleUr: 'اسکول کا وقت',
    timeOfDay: '09:00',
  ),
];
