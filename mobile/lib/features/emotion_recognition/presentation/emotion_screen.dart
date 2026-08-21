import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
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
    final question = _question;
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Emotion practice')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (result != null) ...[
            StatePanel(
              title: 'Session complete',
              message:
                  '${result.score} of ${result.total} correct • ${result.starsAwarded} stars earned',
              icon: Icons.stars_outlined,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _restart,
              child: const Text('Practise again'),
            ),
          ] else if (question != null) ...[
            Text(
              'Question ${question.index} of ${question.total}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Which face feels ${_label(question.answer)}?',
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
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Hint: look at the face and choose the matching feeling.',
                ),
              ),
            const SizedBox(height: 20),
            ...question.choices.map(
              (emotion) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FilledButton.tonal(
                  onPressed: _outcome == null ? () => _answer(emotion) : null,
                  child: Text(_label(emotion)),
                ),
              ),
            ),
            if (_outcome != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _outcome!.correct
                      ? 'That is right.'
                      : 'Let us try the next one.',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
          const SizedBox(height: 20),
          const StatePanel(
            title: 'Camera expression practice',
            message:
                'P1 placeholder. Future on-device ML Kit processing will stay in memory and never upload frames.',
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

  String _label(EmotionLabel emotion) => switch (emotion) {
    EmotionLabel.happy => 'Happy',
    EmotionLabel.sad => 'Sad',
    EmotionLabel.angry => 'Angry',
    EmotionLabel.surprised => 'Surprised',
    EmotionLabel.scared => 'Scared',
    EmotionLabel.neutral => 'Neutral',
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
