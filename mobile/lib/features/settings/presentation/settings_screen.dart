import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../home/presentation/feature_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.appState, super.key});

  final AppState appState;

  String _levelLabel(AppLocalizations l10n, String level) => switch (level) {
    'Intermediate' => l10n.intermediateSupportLevel,
    'Advanced' => l10n.advancedSupportLevel,
    _ => l10n.beginnerSupportLevel,
  };

  Future<void> _addChildDialog(BuildContext context, AppLocalizations l10n) {
    final nameController = TextEditingController();
    var level = 'Beginner';
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.addChildLabel),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const ValueKey('add-child-name'),
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.childNameLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final candidate in const [
                    'Beginner',
                    'Intermediate',
                    'Advanced',
                  ])
                    ChoiceChip(
                      label: Text(_levelLabel(l10n, candidate)),
                      selected: level == candidate,
                      onSelected: (_) =>
                          setDialogState(() => level = candidate),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              key: const ValueKey('add-child-save'),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                appState.addChild(name: name, supportLevel: level);
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

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
              const Divider(),
              SwitchListTile(
                key: const ValueKey('child-mode-switch'),
                secondary: const Icon(Icons.child_friendly_outlined),
                title: Text(l10n.childModeLabel),
                subtitle: Text(l10n.childModeSubtitle),
                value: appState.childMode,
                onChanged: appState.setChildMode,
              ),
              const Divider(),
              Text(
                l10n.profilesSectionTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              RadioGroup<String>(
                groupValue: appState.selectedChild.id,
                onChanged: (value) {
                  if (value != null) appState.selectChild(value);
                },
                child: Column(
                  children: [
                    for (final child in appState.children)
                      RadioListTile<String>(
                        key: ValueKey('child-option-${child.id}'),
                        value: child.id,
                        title: Text(child.name),
                        subtitle: Text(_levelLabel(l10n, child.supportLevel)),
                      ),
                  ],
                ),
              ),
              ListTile(
                key: const ValueKey('add-child-tile'),
                leading: const Icon(Icons.person_add_alt_outlined),
                title: Text(l10n.addChildLabel),
                onTap: () => _addChildDialog(context, l10n),
              ),
              const Divider(),
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
