import 'package:flutter/material.dart';

import '../../home/presentation/feature_screen.dart';

class InterestLearningScreen extends StatelessWidget {
  const InterestLearningScreen({super.key});

  @override
  Widget build(BuildContext context) => const FeatureScreen(
    title: 'Interest-based learning',
    description:
        'Caregiver-selected interests will map deterministically to authored learning activities.',
    icon: Icons.lightbulb_outline,
  );
}
