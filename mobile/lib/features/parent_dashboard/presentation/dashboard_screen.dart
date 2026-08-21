import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../progress/domain/progress_models.dart';
import '../domain/weekly_progress_aggregator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WeeklyProgressAggregator _aggregator = const WeeklyProgressAggregator();

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
    );
  }

  Future<void> _addObservation() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logObservation),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(hintText: l10n.observationHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              Navigator.of(context).pop(text.isEmpty ? null : text);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (note == null) return;
    await widget.appState.progressRepository.recordObservation(
      ObservationNote(
        childId: widget.appState.selectedChild.id,
        note: note,
        authorRole: 'parent',
        createdAt: DateTime.now(),
      ),
    );
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
      appBar: AppBar(title: Text(l10n.progressTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addObservation,
        icon: const Icon(Icons.edit_note),
        label: Text(l10n.observationButton),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.childWeekHeader(widget.appState.selectedChild.name),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
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
                  Row(
                    children: [
                      Expanded(
                        child: _Metric(
                          label: l10n.metricActivities,
                          value: '${data.activityCount}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Metric(
                          label: l10n.metricRoutine,
                          value: '${(data.routineRatio * 100).round()}%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Metric(
                          label: l10n.metricStars,
                          value: '${widget.appState.stars}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: SizedBox(
                      height: 190,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.activitiesThisWeek),
                            const Spacer(),
                            Row(
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
                          ],
                        ),
                      ),
                    ),
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
          Text(l10n.caregiverNotes, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (_observations.isEmpty)
            Text(l10n.noObservationsYet)
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
}

class _DashboardData {
  const _DashboardData({
    required this.buckets,
    required this.activityCount,
    required this.routineRatio,
    required this.stars,
  });

  _DashboardData.empty()
    : this(buckets: const [], activityCount: 0, routineRatio: 0, stars: 0);

  final List<DailyActivityBucket> buckets;
  final int activityCount;
  final double routineRatio;
  final int stars;
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
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
      children: [
        Container(
          width: 28,
          height: height,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    ),
  );
}

