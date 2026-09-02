import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_widgets.dart';
import 'support_level_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.appState, super.key});

  final AppState appState;

  String _levelLabel(AppLocalizations l10n, String level) => switch (level) {
    'Intermediate' => l10n.intermediateSupportLevel,
    'Advanced' => l10n.advancedSupportLevel,
    _ => l10n.beginnerSupportLevel,
  };

  Future<void> _childDialog(
    BuildContext context,
    AppLocalizations l10n, {
    ChildProfile? existing,
  }) async {
    // The dialog owns its controller — see _ChildProfileDialog.
    final draft = await showDialog<_ChildDraft>(
      context: context,
      builder: (_) => _ChildProfileDialog(existing: existing),
    );
    if (draft == null) return;
    if (existing == null) {
      appState.addChild(name: draft.name, supportLevel: draft.level);
    } else {
      appState.updateChild(
        id: existing.id,
        name: draft.name,
        supportLevel: draft.level,
      );
    }
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
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              SectionHeader(
                title: l10n.displaySectionTitle,
                accent: context.palette.sensory,
              ),
              SwitchListTile(
                title: Text(l10n.sensoryMode),
                subtitle: Text(l10n.sensoryModeSubtitle),
                value: appState.sensoryMode,
                onChanged: appState.toggleSensoryMode,
              ),
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
                leading: Icon(Icons.tune, color: context.palette.learning),
                title: Text(l10n.supportLevel),
                subtitle: Text(l10n.supportLevelSubtitle),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SupportLevelScreen(appState: appState),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: l10n.parentLockTitle,
                accent: context.palette.routine,
              ),
              SwitchListTile(
                key: const ValueKey('child-mode-switch'),
                secondary: const Icon(Icons.child_friendly_outlined),
                title: Text(l10n.childModeLabel),
                subtitle: Text(l10n.childModeSubtitle),
                value: appState.childMode,
                onChanged: appState.setChildMode,
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: l10n.profilesSectionTitle,
                accent: context.palette.communicate,
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
                        secondary: IconButton(
                          key: ValueKey('edit-child-${child.id}'),
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: l10n.editProfileTitle,
                          onPressed: () =>
                              _childDialog(context, l10n, existing: child),
                        ),
                      ),
                  ],
                ),
              ),
              ListTile(
                key: const ValueKey('add-child-tile'),
                leading: const Icon(Icons.person_add_alt_outlined),
                title: Text(l10n.addChildLabel),
                onTap: () => _childDialog(context, l10n),
              ),
              const SizedBox(height: AppSpacing.lg),
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

/// What the child-profile dialog returns.
class _ChildDraft {
  const _ChildDraft({required this.name, required this.level});

  final String name;
  final String level;
}

/// Create or edit a child profile.
///
/// Owns its `TextEditingController` so Flutter disposes it on unmount. The
/// caller cannot safely dispose one when `showDialog` resolves — the route
/// is still animating out and still rebuilding the field at that point.
class _ChildProfileDialog extends StatefulWidget {
  const _ChildProfileDialog({this.existing});

  final ChildProfile? existing;

  @override
  State<_ChildProfileDialog> createState() => _ChildProfileDialogState();
}

class _ChildProfileDialogState extends State<_ChildProfileDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name);
  late String _level = widget.existing?.supportLevel ?? 'Beginner';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String _levelLabel(AppLocalizations l10n, String level) => switch (level) {
    'Intermediate' => l10n.intermediateSupportLevel,
    'Advanced' => l10n.advancedSupportLevel,
    _ => l10n.beginnerSupportLevel,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isNew = widget.existing == null;
    return AlertDialog(
      title: Text(isNew ? l10n.addChildLabel : l10n.editProfileTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: ValueKey(isNew ? 'add-child-name' : 'edit-child-name'),
            controller: _name,
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
                  selected: _level == candidate,
                  onSelected: (_) => setState(() => _level = candidate),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: ValueKey(isNew ? 'add-child-save' : 'edit-child-save'),
          onPressed: () {
            final name = _name.text.trim();
            if (name.isEmpty) return;
            Navigator.of(context).pop(_ChildDraft(name: name, level: _level));
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
