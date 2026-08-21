import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../domain/emotion_activity_engine.dart';

class EmotionScreen extends StatefulWidget {
  const EmotionScreen({super.key, this.appState});

  final AppState? appState;

  @override
  State<EmotionScreen> createState() => _EmotionScreenState();
}

class _EmotionScreenState extends State<EmotionScreen> {
  late final DeterministicEmotionActivityEngine _engine;
  EmotionQuestion? _question;
  AnswerOutcome? _outcome;
  SessionResult? _result;

  @override
  void initState() {
    super.initState();
    _engine = DeterministicEmotionActivityEngine(childId: 'demo-child');
    _question = _engine.start(level: SupportLevel.beginner);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final question = _question;
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.emotionPracticeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (result != null) ...[
            StatePanel(
              title: l10n.sessionComplete,
              message: l10n.sessionSummary(
                result.score,
                result.total,
                result.starsAwarded,
              ),
              icon: Icons.stars_outlined,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: FilledButton(
                onPressed: _restart,
                child: Text(l10n.practiseAgain),
              ),
            ),
          ] else if (question != null) ...[
            Text(
              l10n.questionProgress(question.index, question.total),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.whichFaceFeels(_label(l10n, question.answer)),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Card(
              child: SizedBox(
                height: 180,
                child: Center(
                  child: Icon(
                    _iconFor(question.answer),
                    size: 120,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            if (question.hintVisible)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(l10n.beginnerHint),
              ),
            const SizedBox(height: 20),
            ...question.choices.map(
              (emotion) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: FilledButton.tonal(
                    onPressed:
                        _outcome == null ? () => _answer(emotion) : null,
                    child: Text(_label(l10n, emotion)),
                  ),
                ),
              ),
            ),
            if (_outcome != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    _outcome!.correct
                        ? l10n.answerCorrect
                        : l10n.answerIncorrect,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 20),
          StatePanel(
            title: l10n.cameraPracticeTitle,
            message: l10n.cameraPracticeMessage,
            icon: Icons.camera_alt_outlined,
          ),
        ],
      ),
    );
  }

  void _answer(EmotionLabel emotion) {
    setState(() => _outcome = _engine.submit(emotion));
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (!mounted || _outcome == null) return;
      final next = _engine.next();
      setState(() {
        _outcome = null;
        _question = next;
        if (next == null) _result = _engine.finish();
      });
      if (_result != null && widget.appState != null) {
        widget.appState!.awardStars(_result!.starsAwarded);
        widget.appState!.recordSession(_result!);
      }
    });
  }

  void _restart() {
    setState(() {
      _result = null;
      _outcome = null;
      _question = _engine.start(level: SupportLevel.beginner);
    });
  }

  String _label(AppLocalizations l10n, EmotionLabel emotion) =>
      switch (emotion) {
        EmotionLabel.happy => l10n.emotionHappy,
        EmotionLabel.sad => l10n.emotionSad,
        EmotionLabel.angry => l10n.emotionAngry,
        EmotionLabel.surprised => l10n.emotionSurprised,
        EmotionLabel.scared => l10n.emotionScared,
        EmotionLabel.neutral => l10n.emotionNeutral,
      };

  IconData _iconFor(EmotionLabel emotion) => switch (emotion) {
    EmotionLabel.happy => Icons.sentiment_satisfied,
    EmotionLabel.sad => Icons.sentiment_dissatisfied,
    EmotionLabel.angry => Icons.mood_bad,
    EmotionLabel.surprised => Icons.sentiment_very_satisfied,
    EmotionLabel.scared => Icons.sentiment_very_dissatisfied,
    EmotionLabel.neutral => Icons.sentiment_neutral,
  };
}
