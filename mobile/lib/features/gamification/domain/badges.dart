import 'package:flutter/material.dart';

import '../../progress/domain/progress_models.dart';

/// A milestone the child and caregiver reach together. Purely descriptive,
/// never competitive — there is no leaderboard anywhere in the app.
class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.titleEn,
    required this.titleUr,
    required this.descriptionEn,
    required this.descriptionUr,
    required this.icon,
    required this.target,
  });

  final String id;
  final String titleEn;
  final String titleUr;
  final String descriptionEn;
  final String descriptionUr;
  final IconData icon;

  /// Value at which the badge is earned.
  final int target;

  String titleFor(Locale locale) =>
      locale.languageCode == 'ur' ? titleUr : titleEn;

  String descriptionFor(Locale locale) =>
      locale.languageCode == 'ur' ? descriptionUr : descriptionEn;
}

const List<BadgeDefinition> badgeCatalog = [
  BadgeDefinition(
    id: 'first-session',
    titleEn: 'First step',
    titleUr: 'پہلا قدم',
    descriptionEn: 'Complete your first activity together.',
    descriptionUr: 'پہلی سرگرمی مل کر مکمل کریں۔',
    icon: Icons.flag_outlined,
    target: 1,
  ),
  BadgeDefinition(
    id: 'ten-sessions',
    titleEn: 'Ten together',
    titleUr: 'دس ساتھ',
    descriptionEn: 'Finish ten activities side by side.',
    descriptionUr: 'دس سرگرمیاں ساتھ مکمل کریں۔',
    icon: Icons.favorite_outline,
    target: 10,
  ),
  BadgeDefinition(
    id: 'streak-3',
    titleEn: 'Three days in a row',
    titleUr: 'تین دن مسلسل',
    descriptionEn: 'Practise a little on three days back to back.',
    descriptionUr: 'تین روزے مل کر ہر روز تھوڑی مشق کریں۔',
    icon: Icons.event_repeat_outlined,
    target: 3,
  ),
  BadgeDefinition(
    id: 'star-collector',
    titleEn: 'Star collector',
    titleUr: 'ستارہ جمع کرنے والے',
    descriptionEn: 'Gather twenty-five stars as a team.',
    descriptionUr: 'ٹیم بن کر پچیس ستارے جمع کریں۔',
    icon: Icons.stars_outlined,
    target: 25,
  ),
];

/// Where a badge stands right now.
class BadgeEvaluation {
  const BadgeEvaluation({
    required this.definition,
    required this.current,
  });

  final BadgeDefinition definition;
  final int current;

  bool get earned => current >= definition.target;

  /// 0..1, clamped, for ring rendering.
  double get progress => (current / definition.target).clamp(0.0, 1.0);
}

/// Evaluates every catalog badge against plain counters. No clinical
/// claims, no comparisons between children — just milestones.
List<BadgeEvaluation> evaluateBadges({
  required int sessionCount,
  required int streakDays,
  required int stars,
}) =>
    [
      for (final definition in badgeCatalog)
        BadgeEvaluation(
          definition: definition,
          current: switch (definition.id) {
            'first-session' || 'ten-sessions' => sessionCount,
            'streak-3' => streakDays,
            _ => stars,
          },
        ),
    ];

String _dayKey(DateTime value) =>
    value.toIso8601String().substring(0, 10);

/// Day keys (yyyy-MM-dd) covered by recorded sessions.
Set<String> sessionDayKeys(List<ProgressRecord> records) =>
    {for (final record in records) _dayKey(record.result.completedAt)};

/// Consecutive active days ending today, or yesterday when today has no
/// activity yet — an unfinished day never breaks a live streak.
int currentStreak(Iterable<String> activeDayKeys, DateTime today) {
  final days = activeDayKeys.toSet();
  var cursor = DateTime(today.year, today.month, today.day);
  if (!days.contains(_dayKey(cursor))) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var streak = 0;
  while (days.contains(_dayKey(cursor))) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
