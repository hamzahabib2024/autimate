import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../progress/domain/progress_models.dart';
import '../domain/emotion_trend.dart';
import '../domain/weekly_progress_aggregator.dart';
import 'achievements_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WeeklyProgressAggregator _aggregator = const WeeklyProgressAggregator();
  final EmotionTrendSeries _trendSeries = const EmotionTrendSeries();

  late Future<_DashboardData> _data;
  List<ObservationNote> _observations = [];
  String? _loadedChildId;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  /// Reloads metrics when the active profile changes while the tab is kept
  /// alive by the shell's IndexedStack.
  void _ensureChildData() {
    final childId = widget.appState.selectedChild.id;
    if (_loadedChildId == childId) return;
    _loadedChildId = childId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final future = _load();
      setState(() {
        _data = future;
      });
    });
  }

  Future<_DashboardData> _load() async {
    final child = widget.appState.selectedChild;
    final sessions = await widget.appState.progressRepository.getSessions(
      child.id,
    );
    final completed = await widget.appState.routineRepository
        .completedStepIdsFor(child.id, DateTime.now());
    final steps = await widget.appState.routineRepository.getSteps();
    final observations = await widget.appState.progressRepository
        .getObservations(child.id);
    if (!mounted) return _DashboardData.empty();
    setState(() => _observations = observations);
    return _DashboardData(
      buckets: _aggregator.aggregate(sessions, DateTime.now()),
      activityCount: sessions.length,
      routineRatio: _aggregator.routineCompletion(
        child: child,
        completedSteps: completed.length,
        totalSteps: steps.length,
      ),
      stars: widget.appState.stars,
      trend: _trendSeries.build(sessions, DateTime.now()),
    );
  }

  Future<void> _addObservation() async {
    // The dialog owns its controller. Disposing one here instead would fire
    // while the dialog's exit animation is still rebuilding the field —
    // "A TextEditingController was used after being disposed".
    final result = await showDialog<_ObservationDraft>(
      context: context,
      builder: (_) => const _ObservationDialog(),
    );
    if (result == null || !mounted) return;
    await widget.appState.progressRepository.recordObservation(
      ObservationNote(
        childId: widget.appState.selectedChild.id,
        note: result.note,
        authorRole: 'parent',
        createdAt: DateTime.now(),
        tag: result.tag,
      ),
    );
    if (!mounted) return;
    final refreshed = _load();
    setState(() {
      _data = refreshed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        _ensureChildData();
        return _buildBody(context, l10n);
      },
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.progressTitle),
        actions: [
          IconButton(
            key: const ValueKey('open-achievements'),
            tooltip: l10n.achievementsTitle,
            icon: const Icon(Icons.timeline_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    AchievementsScreen(appState: widget.appState),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('observation-button'),
        onPressed: _addObservation,
        icon: const Icon(Icons.edit_note),
        label: Text(l10n.observationButton),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          96,
        ),
        children: [
          Text(
            l10n.childWeekHeader(widget.appState.selectedChild.name),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          FutureBuilder<_DashboardData>(
            future: _data,
            builder: (context, snapshot) {
              final data = snapshot.data;
              if (data == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntrinsicHeight(
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: CaregiverStatTile(
                          label: l10n.metricActivities,
                          value: '${data.activityCount}',
                          icon: Icons.check_circle_outline,
                          accent: context.palette.communicate,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: CaregiverStatTile(
                          label: l10n.metricRoutine,
                          value: '${(data.routineRatio * 100).round()}%',
                          icon: Icons.today_outlined,
                          accent: context.palette.routine,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: CaregiverStatTile(
                          label: l10n.metricStars,
                          value: '${widget.appState.stars}',
                          icon: Icons.star_outline,
                          accent: context.palette.progress,
                        ),
                      ),
                    ],
                  ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      // The card sizes to its content rather than to a fixed
                      // height. Only the bar row is measured; a Spacer here
                      // needed a bounded height, which a growing header at a
                      // large text scale no longer left it.
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SectionHeader(
                              title: l10n.activitiesThisWeek,
                              accent: context.palette.communicate,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              height: 120,
                              child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                for (final bucket in data.buckets)
                                  _Bar(
                                    height: _barHeight(bucket.count),
                                    label: _weekdayLabel(bucket.weekday),
                                    count: bucket.count,
                                  ),
                              ],
                              ),
                            ),
                          ],
                        ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TrendCard(
                    trend: data.trend,
                    title: l10n.emotionTrendTitle,
                    emptyHint: l10n.noEmotionDataYet,
                    latestLabel: (accuracy) => l10n.emotionTrendLatest(
                      '${(accuracy * 100).round()}%',
                    ),
                    dayLabels: [
                      for (final point in data.trend)
                        _weekdayLabel(point.day.weekday),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.explainableProgress),
            subtitle: Text(l10n.explainableProgressMessage),
          ),
          const SizedBox(height: 8),
          SectionHeader(
            title: l10n.caregiverNotes,
            accent: context.palette.learning,
          ),
          if (_observations.isEmpty)
            EmptyState(
              message: l10n.noObservationsYet,
              icon: Icons.sticky_note_2_outlined,
            )
          else
            ..._observations.take(5).map(
              (note) => Card(
                child: ListTile(
                  leading: const Icon(Icons.sticky_note_2_outlined),
                  title: Text(note.note),
                  subtitle: Text(
                    MaterialLocalizations.of(context).formatFullDate(
                      note.createdAt,
                    ),
                  ),
                  trailing: Chip(
                    key: ValueKey('note-tag-${note.tag}'),
                    label: Text(_tagLabel(l10n, note.tag)),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  double _barHeight(int count) => switch (count) {
    0 => 12,
    1 => 45,
    2 => 75,
    3 => 105,
    _ => 130,
  };

  String _weekdayLabel(int weekday) => switch (weekday) {
    DateTime.monday => 'M',
    DateTime.tuesday => 'T',
    DateTime.wednesday => 'W',
    DateTime.thursday => 'T',
    DateTime.friday => 'F',
    DateTime.saturday => 'S',
    _ => 'S',
  };

  String _tagLabel(AppLocalizations l10n, String tag) =>
      observationTagLabel(l10n, tag);
}

/// Localized name for an observation tag. Top-level so the dashboard list
/// and the entry dialog cannot drift apart.
String observationTagLabel(AppLocalizations l10n, String tag) =>
    switch (tag) {
      'mood' => l10n.tagMood,
      'behaviour' => l10n.tagBehaviour,
      'sensory' => l10n.tagSensory,
      'communication' => l10n.tagCommunication,
      _ => l10n.tagGeneral,
    };

class _DashboardData {
  const _DashboardData({
    required this.buckets,
    required this.activityCount,
    required this.routineRatio,
    required this.stars,
    required this.trend,
  });

  _DashboardData.empty()
    : this(
        buckets: const [],
        activityCount: 0,
        routineRatio: 0,
        stars: 0,
        trend: const [],
      );

  final List<DailyActivityBucket> buckets;
  final int activityCount;
  final double routineRatio;
  final int stars;
  final List<EmotionTrendPoint> trend;
}

/// Score/total accuracy over the last seven days as a simple line. Gaps
/// (days without emotion sessions) are skipped rather than drawn as zero.
class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.trend,
    required this.title,
    required this.emptyHint,
    required this.latestLabel,
    required this.dayLabels,
  });

  final List<EmotionTrendPoint> trend;
  final String title;
  final String emptyHint;
  final String Function(double accuracy) latestLabel;
  final List<String> dayLabels;

  @override
  Widget build(BuildContext context) {
    final plotted = [
      for (var i = 0; i < trend.length; i++)
        if (trend[i].accuracy != null) (index: i, point: trend[i]),
    ];
    return Card(
      child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: Text(title)),
                  if (plotted.isNotEmpty)
                    Text(
                      latestLabel(plotted.last.point.accuracy!),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                key: const ValueKey('emotion-trend'),
                height: 80,
                width: double.infinity,
                child:
                    plotted.isEmpty
                        ? Text(emptyHint, textAlign: TextAlign.center)
                        : CustomPaint(
                          painter: _TrendPainter(
                            plottedIndexes: [
                              for (final entry in plotted) entry.index,
                            ],
                            values: [
                              for (final entry in plotted)
                                entry.point.accuracy!,
                            ],
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [for (final label in dayLabels) Text(label)],
              ),
            ],
          ),
        ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({
    required this.plottedIndexes,
    required this.values,
    required this.color,
  });

  final List<int> plottedIndexes;
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final slots = plottedIndexes.last + 1;
    Offset slotOffset(int slot, double value) => Offset(
      slots == 1 ? size.width / 2 : (slot / (slots - 1)) * size.width,
      size.height * (1 - value.clamp(0.0, 1.0)),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    if (values.length == 1) {
      canvas.drawCircle(slotOffset(plottedIndexes.first, values.first), 4, paint..style = PaintingStyle.fill);
      return;
    }
    final path = Path()
      ..moveTo(
        slotOffset(plottedIndexes.first, values.first).dx,
        slotOffset(plottedIndexes.first, values.first).dy,
      );
    for (var i = 1; i < values.length; i++) {
      final to = slotOffset(plottedIndexes[i], values[i]);
      path.lineTo(to.dx, to.dy);
    }
    canvas.drawPath(path, paint);
    final dot = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(slotOffset(plottedIndexes[i], values[i]), 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.label, required this.count});
  final double height;
  final String label;
  final int count;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    value: '$count',
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 26,
          height: height,
          decoration: BoxDecoration(
            color: context.palette.communicate,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    ),
  );
}

/// What the observation dialog returns.
class _ObservationDraft {
  const _ObservationDraft({required this.note, required this.tag});

  final String note;
  final String tag;
}

/// Caregiver observation entry.
///
/// A `StatefulWidget` rather than a `StatefulBuilder` so the controller is
/// owned by an element Flutter disposes on unmount. A controller created by
/// the caller and disposed when `showDialog` resolves is disposed too early:
/// the route is still animating out and still rebuilding the field.
class _ObservationDialog extends StatefulWidget {
  const _ObservationDialog();

  @override
  State<_ObservationDialog> createState() => _ObservationDialogState();
}

class _ObservationDialogState extends State<_ObservationDialog> {
  final TextEditingController _controller = TextEditingController();
  String _tag = ObservationNote.knownTags.first;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.logObservation),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const ValueKey('observation-text'),
            controller: _controller,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(hintText: l10n.observationHint),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: const ValueKey('observation-tag'),
            initialValue: _tag,
            decoration: InputDecoration(labelText: l10n.observationTagLabel),
            items: [
              for (final known in ObservationNote.knownTags)
                DropdownMenuItem(
                  value: known,
                  child: Text(observationTagLabel(l10n, known)),
                ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _tag = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const ValueKey('observation-save'),
          onPressed: () {
            final text = _controller.text.trim();
            Navigator.of(context).pop(
              text.isEmpty ? null : _ObservationDraft(note: text, tag: _tag),
            );
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
