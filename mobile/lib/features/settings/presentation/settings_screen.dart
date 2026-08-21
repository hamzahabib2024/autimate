import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../home/presentation/feature_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isUrdu = appState.locale.languageCode == 'ur';
        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsTitle)),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SwitchListTile(
                title: Text(l10n.sensoryMode),
                subtitle: Text(l10n.sensoryModeSubtitle),
                value: appState.sensoryMode,
                onChanged: appState.toggleSensoryMode,
              ),
              const Divider(),
              ListTile(
                title: Text(l10n.languageLabel),
                subtitle: Text(isUrdu ? l10n.languageUrdu : l10n.languageEnglish),
                trailing: DropdownButton<Locale>(
                  value: appState.locale,
                  items: [
                    DropdownMenuItem(
                      value: const Locale('en'),
                      child: Text(l10n.languageEnglish),
                    ),
                    DropdownMenuItem(
                      value: const Locale('ur'),
                      child: Text(l10n.languageUrdu),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) appState.setLocale(value);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: Text(l10n.supportLevel),
                subtitle: Text(l10n.supportLevelSubtitle),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FeatureScreen(
                      title: l10n.supportLevel,
                      description: l10n.supportLevelDescription,
                      icon: Icons.tune,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.privacySafety),
                subtitle: Text(l10n.privacySafetySubtitle),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(l10n.signOut),
                onTap: appState.signOut,
              ),
            ],
          ),
        );
      },
    );
  }
}
