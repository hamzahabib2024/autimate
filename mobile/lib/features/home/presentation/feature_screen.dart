import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          StatePanel(
            title: l10n.comingNextPhase,
            message: description,
            icon: icon,
          ),
          const SizedBox(height: 16),
          StatePanel(
            title: l10n.safeByDesign,
            message: l10n.safeByDesignMessage,
            icon: Icons.shield_outlined,
          ),
        ],
      ),
    );
  }
}
