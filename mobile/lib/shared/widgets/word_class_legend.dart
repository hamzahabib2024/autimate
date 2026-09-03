import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/generated/app_localizations.dart';

/// Explains the Fitzgerald-key colours.
///
/// The colour coding is the board's most useful feature and its least
/// self-evident one. A child absorbs it without explanation; an adult — a
/// teacher, a grandparent, a therapist meeting the board for the first time
/// — needs telling once. Without a legend the colours read as decoration,
/// which is the one thing they are not.
///
/// Collapsed by default, because on the child's own screen it is noise. The
/// caregiver opens it once, understands the system, and closes it.
class WordClassLegend extends StatelessWidget {
  const WordClassLegend({this.initiallyExpanded = false, super.key});

  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;

    final entries = <(Color, String)>[
      (palette.wordCarrier, l10n.legendCarrier),
      (palette.wordPeople, l10n.legendPeople),
      (palette.wordVerb, l10n.legendVerb),
      (palette.wordDescriptor, l10n.legendDescriptor),
      (palette.wordNoun, l10n.legendNoun),
      (palette.wordNeed, l10n.legendNeed),
    ];

    return Card(
      key: const ValueKey('word-class-legend'),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(Icons.palette_outlined, color: palette.communicate),
        title: Text(
          l10n.legendTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final entry in entries)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // A swatch plus a word: the legend itself never relies
                    // on colour alone, same rule as the board.
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: entry.$1,
                        borderRadius: BorderRadius.circular(AppRadius.sm / 3),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      entry.$2,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.legendHint,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
