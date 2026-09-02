import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../settings/presentation/parent_gate_screen.dart';
import '../domain/aac_catalog.dart';
import '../domain/literacy_support.dart';

/// Caregiver control for Transition to Literacy.
///
/// Presented as a ladder with a live preview, because the difference between
/// rungs is visual and a list of names would not convey it. The caution is
/// on screen rather than buried in a manual: the published benefit varies
/// enormously between children, and a caregiver who pushes to the top rung
/// too early makes the board harder for someone who cannot say so.
class LiteracyScreen extends StatelessWidget {
  const LiteracyScreen({required this.appState, super.key});

  final AppState appState;

  /// Opens behind the parent lock — a child changing their own reading
  /// level by tapping around would undo weeks of graded progress.
  static Future<void> openGated(
    BuildContext context,
    AppState appState,
  ) async {
    if (appState.childMode) {
      final unlocked = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ParentGateScreen(appState: appState),
        ),
      );
      if (unlocked != true) return;
    }
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LiteracyScreen(appState: appState)),
    );
  }

  static String labelFor(AppLocalizations l10n, LiteracyLevel level) =>
      switch (level) {
        LiteracyLevel.off => l10n.literacyOff,
        LiteracyLevel.flash => l10n.literacyFlash,
        LiteracyLevel.emphasis => l10n.literacyEmphasis,
        LiteracyLevel.fading => l10n.literacyFading,
        LiteracyLevel.textOnly => l10n.literacyTextOnly,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final childId = appState.selectedChild.id;
        final current = appState.literacyFor(childId);
        final sample = cardById('apple') ?? aacDeck.first;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.literacyTitle)),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                l10n.literacySubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),

              // A live tile at the chosen rung. The rungs differ visually,
              // so showing one beats naming five.
              SectionHeader(
                title: l10n.literacyCurrent(labelFor(l10n, current)),
                accent: palette.communicate,
              ),
              Center(
                child: SizedBox(
                  width: 200,
                  height: 210,
                  child: SymbolTile(
                    key: ValueKey('literacy-preview-${current.name}'),
                    card: sample,
                    showUrdu: appState.locale.languageCode == 'ur',
                    literacy: current,
                    sensoryMode: appState.sensoryMode,
                    onTap: () {},
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              RadioGroup<LiteracyLevel>(
                groupValue: current,
                onChanged: (value) {
                  if (value == null) return;
                  appState.setLiteracyLevel(childId, value);
                },
                child: Column(
                  children: [
                    for (final level in LiteracyLevel.values)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Card(
                          key: ValueKey('literacy-${level.name}'),
                          child: RadioListTile<LiteracyLevel>(
                            value: level,
                            title: Text(labelFor(l10n, level)),
                            secondary: _LadderRung(
                              step: LiteracyLevel.values.indexOf(level),
                              total: LiteracyLevel.values.length,
                              active: current == level,
                              accent: palette.communicate,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),
              Card(
                color: palette.accentTint(palette.attention, 0.86),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: palette.attention,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.literacyCaution,
                          key: const ValueKey('literacy-caution'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A small climbing-bar glyph so the rungs read as an ordered progression
/// rather than five unrelated options.
class _LadderRung extends StatelessWidget {
  const _LadderRung({
    required this.step,
    required this.total,
    required this.active,
    required this.accent,
  });

  final int step;
  final int total;
  final bool active;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final outline = context.palette.outline;
    return SizedBox(
      width: 34,
      height: 34,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < total; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Container(
                width: 4,
                height: 8.0 + i * 6,
                decoration: BoxDecoration(
                  color: i <= step
                      ? (active ? accent : accent.withValues(alpha: 0.45))
                      : outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
