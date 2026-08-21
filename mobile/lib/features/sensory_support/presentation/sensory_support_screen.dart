import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';

class SensorySupportScreen extends StatelessWidget {
  const SensorySupportScreen({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sensorySupportTitle)),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.air),
              title: Text(l10n.sensoryMode),
              subtitle: Text(l10n.sensoryModeSubtitle),
              value: appState.sensoryMode,
              onChanged: appState.toggleSensoryMode,
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.volume_down),
                title: Text(l10n.ttsControlsTitle),
                subtitle: Text(l10n.ttsControlsMessage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
