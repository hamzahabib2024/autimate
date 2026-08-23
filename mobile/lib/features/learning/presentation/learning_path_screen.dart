import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/presentation/parent_gate_screen.dart';
import '../domain/learning_models.dart';

/// Child-facing learning path: activities ordered by the caregiver-chosen
/// interests, each labelled with why it was chosen. Deterministic and
/// fully authored — nothing here is generated.
class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  Set<String> _interests = {};
  bool _loading = true;
  String? _loadedChildId;

  String get _childId => widget.appState.selectedChild.id;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final interests =
        await widget.appState.interestRepository.interestsFor(_childId);
    if (!mounted) return;
    setState(() {
      _interests = interests;
      _loading = false;
    });
  }

  void _ensureChildData() {
    if (_loadedChildId == _childId) return;
    _loadedChildId = _childId;
    _load();
  }

  Future<void> _openEditor() async {
    await InterestEditorScreen.openGated(context, widget.appState);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    _ensureChildData();
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        _ensureChildData();
        return _buildBody(context, AppLocalizations.of(context));
      },
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    final path = buildLearningPath(_interests);
    final locale = widget.appState.locale;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.learningPathTileTitle),
        actions: [
          IconButton(
            key: const ValueKey('learning-edit'),
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.learningEditorTitle,
            onPressed: _openEditor,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  l10n.oneStepAtATime,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final interest in interestCatalog)
                      if (_interests.contains(interest.id))
                        Chip(
                          key: ValueKey('interest-chip-${interest.id}'),
                          avatar: Icon(interest.icon, size: 16),
                          label: Text(interest.labelFor(locale)),
                        ),
                  ],
                ),
                const SizedBox(height: 16),
                if (path.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Column(
                      children: [
                        const Icon(Icons.explore_outlined, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          l10n.learningPathEmptyHint,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                else
                  for (var i = 0; i < path.length; i++) ...[
                    Card(
                      child: ListTile(
                        key: ValueKey('path-${path[i].activity.id}'),
                        leading: CircleAvatar(
                          child: Icon(path[i].activity.icon),
                        ),
                        title: Text(path[i].activity.titleFor(locale)),
                        subtitle: Text(
                          l10n.learningWhy(
                            widget.appState.selectedChild.name,
                            interestCatalog
                                .firstWhere(
                                  (interest) =>
                                      interest.id == path[i].viaInterestId,
                                  orElse: () => interestCatalog.first,
                                )
                                .labelFor(locale),
                          ),
                        ),
                        trailing: Text('${i + 1}'),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _ActivityRunner(
                              appState: widget.appState,
                              entry: path[i],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
              ],
            ),
    );
  }
}

class _ActivityRunner extends StatefulWidget {
  const _ActivityRunner({required this.appState, required this.entry});

  final AppState appState;
  final LearningPathEntry entry;

  @override
  State<_ActivityRunner> createState() => _ActivityRunnerState();
}

class _ActivityRunnerState extends State<_ActivityRunner> {
  int _questionIndex = 0;
  bool? _lastAnswerCorrect;
  bool _finished = false;

  Locale get _locale => widget.appState.locale;

  void _answer(int index) {
    final question =
        widget.entry.activity.questions[_questionIndex];
    setState(() {
      _lastAnswerCorrect = question.isCorrect(index);
      if (_lastAnswerCorrect ?? false) {
        // Clear praise on advance so it cannot linger (same rule as the
        // social story comprehension checks).
        _lastAnswerCorrect = null;
        if (_questionIndex < widget.entry.activity.questions.length - 1) {
          _questionIndex++;
        } else {
          widget.appState.awardStars(1);
          _finished = true;
        }
      }
    });
  }

  void _restart() {
    setState(() {
      _questionIndex = 0;
      _lastAnswerCorrect = null;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activity = widget.entry.activity;
    return Scaffold(
      appBar: AppBar(title: Text(activity.titleFor(_locale))),
      body: AnimatedBuilder(
        animation: widget.appState,
        builder: (context, _) {
          if (_finished) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events_outlined, size: 56),
                    const SizedBox(height: 12),
                    Text(
                      l10n.sessionComplete,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(l10n.starsEarned(widget.appState.stars)),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 64),
                      child: FilledButton(
                        onPressed: _restart,
                        child: Text(l10n.practiseAgain),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final question = activity.questions[_questionIndex];
          final feedback = _lastAnswerCorrect;
          return ListView(
            key: const ValueKey('quiz-page'),
            padding: const EdgeInsets.all(24),
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.learningQuestionProgress(
                    _questionIndex + 1,
                    activity.questions.length,
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                question.promptFor(_locale),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < question.optionsEn.length; i++) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: FilledButton.tonal(
                    key: ValueKey('answer-$i'),
                    onPressed: () => _answer(i),
                    child: Text(question.optionFor(_locale, i)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (feedback != null)
                Text(
                  feedback ? l10n.answerCorrect : l10n.answerIncorrect,
                  style: TextStyle(
                    color: feedback
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Caregiver-gated editor for the selected child's interests.
class InterestEditorScreen extends StatefulWidget {
  const InterestEditorScreen({required this.appState, super.key});

  final AppState appState;

  static Future<void> openGated(BuildContext context, AppState appState) async {
    final passed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ParentGateScreen(appState: appState),
      ),
    );
    if (passed == true && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InterestEditorScreen(appState: appState),
        ),
      );
    }
  }

  @override
  State<InterestEditorScreen> createState() => _InterestEditorScreenState();
}

class _InterestEditorScreenState extends State<InterestEditorScreen> {
  late Set<String> _selected = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final current = await widget.appState.interestRepository
        .interestsFor(widget.appState.selectedChild.id);
    if (!mounted) return;
    setState(() {
      _selected = current;
      _loading = false;
    });
  }

  Future<void> _saveAndClose() async {
    await widget.appState.interestRepository.setInterests(
      widget.appState.selectedChild.id,
      _selected,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = widget.appState.locale;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.learningEditorTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(l10n.learningPickHint),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final interest in interestCatalog)
                      FilterChip(
                        key: ValueKey('pick-${interest.id}'),
                        avatar: Icon(interest.icon),
                        label: Text(interest.labelFor(locale)),
                        selected: _selected.contains(interest.id),
                        onSelected: (value) {
                          setState(() {
                            value
                                ? _selected.add(interest.id)
                                : _selected.remove(interest.id);
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: FilledButton.icon(
                    key: const ValueKey('save-interests'),
                    onPressed: _saveAndClose,
                    icon: const Icon(Icons.check),
                    label: Text(l10n.save),
                  ),
                ),
              ],
            ),
    );
  }
}
