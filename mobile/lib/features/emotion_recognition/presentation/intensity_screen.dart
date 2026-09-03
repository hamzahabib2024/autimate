import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../sensory_support/presentation/calm_activities_screen.dart';
import '../domain/emotion_activity_engine.dart';
import '../domain/emotion_intensity.dart';

/// "How strong is it?" — a five-point self-report after naming a feeling.
///
/// The value over a bare label is real: "angry" and "a bit annoyed" are the
/// same word and very different situations, and a child who can only report
/// the word has no way to say the difference before it escalates.
///
/// **What this screen refuses to do.** It does not store a trend, show an
/// average, or draw a chart. Those artefacts are what turn a communication
/// aid into a record of a child's emotional state, and the caution on screen
/// says as much to the caregiver reading over a shoulder.
class IntensityScreen extends StatefulWidget {
  const IntensityScreen({
    required this.appState,
    required this.emotion,
    this.onReported,
    super.key,
  });

  final AppState appState;
  final EmotionLabel emotion;

  /// Called with the report so a caller can act on it. Nothing is persisted
  /// by this screen.
  final void Function(IntensityReport report)? onReported;

  static String levelLabel(AppLocalizations l10n, IntensityLevel level) =>
      switch (level) {
        IntensityLevel.aLittle => l10n.intensityALittle,
        IntensityLevel.someWhat => l10n.intensitySomeWhat,
        IntensityLevel.quite => l10n.intensityQuite,
        IntensityLevel.very => l10n.intensityVery,
        IntensityLevel.tooMuch => l10n.intensityTooMuch,
      };

  @override
  State<IntensityScreen> createState() => _IntensityScreenState();
}

class _IntensityScreenState extends State<IntensityScreen> {
  IntensityLevel? _chosen;
  SupportSuggestion? _suggestion;

  void _choose(IntensityLevel level) {
    final report = IntensityReport(
      emotion: widget.emotion,
      level: level,
      reportedAt: DateTime.now(),
    );
    setState(() {
      _chosen = level;
      _suggestion = IntensityGuidance.suggest(report);
    });
    widget.onReported?.call(report);
  }

  String _emotionName(AppLocalizations l10n) => switch (widget.emotion) {
    EmotionLabel.happy => l10n.emotionHappy,
    EmotionLabel.sad => l10n.emotionSad,
    EmotionLabel.angry => l10n.emotionAngry,
    EmotionLabel.surprised => l10n.emotionSurprised,
    EmotionLabel.scared => l10n.emotionScared,
    EmotionLabel.neutral => l10n.emotionNeutral,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;

    return ChildTextScale(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.intensityTitle)),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Center(
              child: EmotionFace(emotion: widget.emotion, size: 140),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _emotionName(l10n),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.intensitySubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),

            // The scale itself: five steps, each a growing block. Size
            // carries the meaning so a child who cannot read the labels can
            // still point at the right one.
            for (final level in IntensityLevel.values)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: _IntensityOption(
                  key: ValueKey('intensity-${level.name}'),
                  level: level,
                  label: IntensityScreen.levelLabel(l10n, level),
                  selected: _chosen == level,
                  onTap: () => _choose(level),
                ),
              ),

            if (_suggestion != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Card(
                key: const ValueKey('intensity-support'),
                color: palette.accentTint(palette.sensory, 0.86),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      Text(
                        _suggestion == SupportSuggestion.breathing
                            ? l10n.intensitySupportBreathing
                            : l10n.intensitySupportTellSomeone,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (_suggestion == SupportSuggestion.breathing)
                        PrimaryActionButton(
                          key: const ValueKey('intensity-breathe'),
                          label: l10n.breathingTitle,
                          icon: Icons.air,
                          accent: palette.sensory,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BreathingScreen(
                                appState: widget.appState,
                              ),
                            ),
                          ),
                        ),
                      // Declining is always offered. A suggestion a child
                      // cannot refuse is an instruction.
                      TextButton(
                        key: const ValueKey('intensity-not-now'),
                        onPressed: () =>
                            setState(() => _suggestion = null),
                        child: Text(l10n.intensityNotNow),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.intensityCaution,
              key: const ValueKey('intensity-caution'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// One rung of the scale, drawn as a growing block.
class _IntensityOption extends StatelessWidget {
  const _IntensityOption({
    required this.level,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IntensityLevel level;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // Colour walks from the calm accent toward the attention one, but never
    // reaches red: a strong feeling is not an error state.
    final accent = Color.lerp(
      palette.sensory,
      palette.emotions,
      (level.value - 1) / 4,
    )!;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? palette.accentTint(accent, 0.72)
            : palette.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            constraints: const BoxConstraints(minHeight: AppTouch.child),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: accent,
                width: selected ? 3 : 1.5,
              ),
            ),
            child: Row(
              children: [
                // A block that grows with the level, so the scale reads
                // without any words at all.
                Container(
                  width: 14.0 + level.value * 10,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (selected) Icon(Icons.check_circle, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
