import 'package:flutter/material.dart';

import '../../home/presentation/feature_screen.dart';

class SocialCommunicationScreen extends StatelessWidget {
  const SocialCommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) => const FeatureScreen(
    title: 'Social communication',
    description:
        'Fixed-branch social stories, conversation practice, and role-play will be authored here.',
    icon: Icons.people_outline,
  );
}
