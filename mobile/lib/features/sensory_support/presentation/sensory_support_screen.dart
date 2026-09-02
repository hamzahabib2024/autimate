import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/communication/domain/symbol_scale.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import 'calm_activities_screen.dart';

/// The quietest surface in the app: the controls that change how loud,
/// bright, and busy everything else is.
class SensorySupportScreen extends StatelessWidget {
  const SensorySupportScreen({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sensorySupportTitle)),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Card(
              child: SwitchListTile(
                secondary: Icon(Icons.air, color: palette.sensory),
                title: Text(l10n.sensoryMode),
                subtitle: Text(l10n.sensoryModeSubtitle),
                value: appState.sensoryMode,
                onChanged: appState.toggleSensoryMode,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Screen brightness sits with the other comfort controls rather
            // than in a style menu: a bright screen in a dim room is a
            // sensory complaint, not a preference.
            SectionHeader(
              title: l10n.displaySectionTitle,
              accent: palette.sensory,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.themeModeLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      l10n.themeModeSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final entry in <(ThemeMode, String, IconData)>[
                          (
                            ThemeMode.system,
                            l10n.themeModeSystem,
                            Icons.brightness_auto_outlined,
                          ),
                          (
                            ThemeMode.light,
                            l10n.themeModeLight,
                            Icons.light_mode_outlined,
                          ),
                          (
                            ThemeMode.dark,
                            l10n.themeModeDark,
                            Icons.dark_mode_outlined,
                          ),
                        ])
                          ChoiceChip(
                            key: ValueKey('theme-mode-${entry.$1.name}'),
                            avatar: Icon(entry.$3, size: 18),
                            label: Text(entry.$2),
                            selected: appState.themeMode == entry.$1,
                            onSelected: (_) =>
                                appState.setThemeMode(entry.$1),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Image magnification under the user's control is a repeated
            // recommendation in the AAC literature for this audience.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.symbolSizeLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      l10n.symbolSizeSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final entry in <(SymbolScale, String)>[
                          (SymbolScale.comfortable, l10n.symbolSizeComfortable),
                          (SymbolScale.large, l10n.symbolSizeLarge),
                          (SymbolScale.largest, l10n.symbolSizeLargest),
                        ])
                          ChoiceChip(
                            key: ValueKey('symbol-scale-${entry.$1.name}'),
                            label: Text(entry.$2),
                            selected: appState.symbolScale == entry.$1,
                            onSelected: (_) =>
                                appState.setSymbolScale(entry.$1),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            SectionHeader(
              title: l10n.calmingTitle,
              accent: palette.sensory,
            ),
            FeatureTile(
              key: const ValueKey('open-breathing'),
              title: l10n.breathingTitle,
              subtitle: l10n.sensoryBreathingSubtitle,
              icon: Icons.air,
              accent: palette.sensory,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BreathingScreen(appState: appState),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FeatureTile(
              key: const ValueKey('open-calming'),
              title: l10n.calmingTitle,
              subtitle: l10n.sensoryCalmingSubtitle,
              icon: Icons.blur_on,
              accent: palette.sensory,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CalmingScreen(appState: appState),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: ListTile(
                leading: Icon(Icons.volume_down, color: palette.sensory),
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
