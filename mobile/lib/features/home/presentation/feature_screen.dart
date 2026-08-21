import 'package:flutter/material.dart';

import '../../../shared/widgets/app_widgets.dart';

class FeatureScreen extends StatelessWidget {
  const FeatureScreen({
    required this.title,
    required this.description,
    required this.icon,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          StatePanel(
            title: 'Coming in the next phase',
            message: description,
            icon: icon,
          ),
          const SizedBox(height: 16),
          const StatePanel(
            title: 'Safe by design',
            message:
                'This module will use fixed, caregiver-approved content. Open-ended child chat is out of scope.',
            icon: Icons.shield_outlined,
          ),
        ],
      ),
    );
  }
}
