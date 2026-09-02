import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/communication/domain/aac_catalog.dart';
import '../../features/communication/domain/sentence_realiser.dart';

/// Maps a card's word class to its Fitzgerald-key colour.
///
/// The Fitzgerald key is an established AAC convention, not decoration:
/// colour-coding by word class speeds visual scanning and teaches sentence
/// structure implicitly, long before the child can read. It is applied as a
/// band and a border so the symbol keeps a light, high-contrast ground —
/// and it is always redundant with the symbol and the label, so a
/// colour-blind child loses nothing.
Color wordClassColor(BuildContext context, AacCard card) {
  final p = context.palette;
  if (card.category == null) return p.wordCarrier;
  return switch (card.grammar.pos) {
    PartOfSpeech.verb => p.wordVerb,
    PartOfSpeech.adjective => p.wordDescriptor,
    PartOfSpeech.pronoun || PartOfSpeech.carrier => p.wordCarrier,
    _ => switch (card.category!) {
      AacCategory.people => p.wordPeople,
      AacCategory.activities => p.wordVerb,
      AacCategory.emotions => p.wordDescriptor,
      AacCategory.needs => p.wordNeed,
      _ => p.wordNoun,
    },
  };
}

/// One AAC vocabulary card.
///
/// Built around a single rule: the symbol is the content and the words are
/// the caption. The symbol well takes the majority of the tile — the
/// previous layout gave it about a quarter — because the primary user
/// cannot read the label.
///
/// The pressed state changes scale *and* border weight, because a subtle
/// tint shift is invisible to many of these users.
class SymbolTile extends StatefulWidget {
  const SymbolTile({
    required this.card,
    required this.onTap,
    required this.showUrdu,
    this.imagePath,
    this.onLongPress,
    super.key,
  });

  final AacCard card;
  final VoidCallback onTap;

  /// Caregiver-created cards carry a local image instead of a glyph.
  final String? imagePath;
  final bool showUrdu;
  final VoidCallback? onLongPress;

  @override
  State<SymbolTile> createState() => _SymbolTileState();
}

class _SymbolTileState extends State<SymbolTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = wordClassColor(context, widget.card);
    final grammar = widget.card.grammar;
    final primary = widget.showUrdu ? grammar.labelUr : grammar.labelEn;
    final secondary = widget.showUrdu ? grammar.labelEn : grammar.labelUr;

    return Semantics(
      button: true,
      label: '${grammar.labelEn}, ${grammar.labelUr}',
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.curve,
        child: Material(
          color: palette.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: AnimatedContainer(
              duration: AppMotion.fast,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: accent,
                  width: _pressed ? 4 : 2,
                ),
              ),
              child: Column(
                children: [
                  // Word-class band: the colour code, kept off the symbol.
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.lg - 2),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: widget.imagePath != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                              child: Image.file(
                                File(widget.imagePath!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => Icon(
                                  widget.card.icon,
                                  size: 56,
                                  color: accent,
                                ),
                              ),
                            )
                          : FittedBox(
                              child: Icon(
                                widget.card.icon,
                                size: 64,
                                color: accent,
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxs,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            primary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            secondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.25,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The one dominant action on a child screen.
///
/// Always the same size, always the same place. Predictability of the
/// primary control matters more here than visual variety.
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.accent,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final tint = accent ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 72,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 30),
        label: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: onPressed == null ? null : context.palette.onAccent,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: tint,
          foregroundColor: context.palette.onAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
}

/// A large child-tier tile for a module on the home screen.
class ChildActionCard extends StatelessWidget {
  const ChildActionCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: palette.accentTint(accent, 0.86),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            constraints: const BoxConstraints(minHeight: 132),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: accent, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(icon, size: 30, color: palette.onAccent),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 19,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.2,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The reward moment.
///
/// A star that grows and settles over roughly six hundred milliseconds.
/// Deliberately not confetti: the point is to mark the achievement without
/// producing an arousal spike. In sensory mode (or with the OS reduced-
/// motion setting on) it simply fades in.
class RewardStar extends StatelessWidget {
  const RewardStar({
    required this.sensoryMode,
    this.size = 72,
    this.color,
    super.key,
  });

  final bool sensoryMode;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.palette.progress;
    final reduced = AppMotion.reduced(context, sensoryMode: sensoryMode);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduced
          ? const Duration(milliseconds: 200)
          : AppMotion.reward,
      curve: AppMotion.curve,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(
          scale: reduced ? 1.0 : 0.6 + 0.4 * t,
          child: child,
        ),
      ),
      child: Icon(Icons.star_rounded, size: size, color: tint),
    );
  }
}

/// Friendly empty state. Never an error — just "nothing here yet".
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(icon, size: 40, color: scheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
