import 'package:flutter/material.dart';

import '../../../shared/widgets/app_widgets.dart';

class EmotionScreen extends StatefulWidget {
  const EmotionScreen({super.key});

  @override
  State<EmotionScreen> createState() => _EmotionScreenState();
}

class _EmotionScreenState extends State<EmotionScreen> {
  int score = 0;
  final emotions = const ['Happy', 'Sad', 'Angry', 'Surprised'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emotion practice')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Which face feels happy?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Card(
            child: SizedBox(
              height: 180,
              child: Center(
                child: Icon(
                  Icons.sentiment_satisfied,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...emotions.map(
            (emotion) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilledButton.tonal(
                onPressed: () =>
                    setState(() => score += emotion == 'Happy' ? 1 : 0),
                child: Text(emotion),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Practice score: $score', textAlign: TextAlign.center),
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
}
