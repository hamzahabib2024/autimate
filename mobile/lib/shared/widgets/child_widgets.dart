import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_depth.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/communication/domain/aac_catalog.dart';
import '../../features/communication/domain/literacy_support.dart';
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
    this.literacy = LiteracyLevel.off,
    this.sensoryMode = false,
    super.key,
  });

  final AacCard card;
  final VoidCallback onTap;

  /// Caregiver-created cards carry a local image instead of a glyph.
  final String? imagePath;
  final bool showUrdu;
  final VoidCallback? onLongPress;

  /// Transition-to-Literacy rung. Shifts weight from symbol to written word.
  final LiteracyLevel literacy;

  final bool sensoryMode;

  @override
  State<SymbolTile> createState() => _SymbolTileState();
}

class _SymbolTileState extends State<SymbolTile>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  /// Drives the word's rise on selection. Runs once per tap and settles —
  /// it never loops, because a repeating element on the board is exactly the
  /// ambient motion the design system rules out.
  late final AnimationController _flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.literacy.flashesOnSelect) {
      _flash
        ..reset()
        ..forward();
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = wordClassColor(context, widget.card);
    final sensory = Theme.of(context).cardTheme.elevation == 0;
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
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.curve,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            // The tile borrows its accent's hue for the shadow: a neutral
            // grey shadow under a colour-coded card reads as dirty.
            boxShadow: _pressed
                ? AppDepth.tinted(accent, sensoryMode: sensory)
                : AppDepth.card(context, sensoryMode: sensory),
          ),
          child: Material(
          color: palette.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: _handleTap,
            onLongPress: widget.onLongPress,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: AnimatedContainer(
              duration: AppMotion.fast,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                gradient: AppDepth.sheen(
                  palette.card,
                  sensoryMode: sensory,
                  strength: 0.7,
                ),
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
                  if (widget.literacy.showsSymbol)
                    Expanded(
                      flex: 7,
                      child: Opacity(
                        opacity: widget.literacy.symbolOpacity,
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
                    ),
                  Expanded(
                    flex: widget.literacy.showsSymbol ? 4 : 11,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxs,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LiteracyWord(
                            word: primary,
                            level: widget.literacy,
                            flash: _flash,
                            sensoryMode: widget.sensoryMode,
                          ),
                          // The second language drops away once the word is
                          // leading: two scripts at once defeats the point of
                          // narrowing attention onto one written form.
                          if (widget.literacy.wordWeight < 0.8)
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
      ),
    );
  }
}

/// The written word on an AAC tile, weighted by the T2L level.
///
/// On [LiteracyLevel.flash] and [LiteracyLevel.emphasis] the word lifts,
/// grows, and takes the accent colour briefly when the card is selected,
/// then settles — the published T2L condition.
///
/// Under reduced motion the word still brightens and holds for the same
/// beat but does not travel. The intervention is the *exposure to the
/// written form*, and that survives without the movement, which is why this
/// feature degrades far better than most animation does.
class _LiteracyWord extends StatelessWidget {
  const _LiteracyWord({
    required this.word,
    required this.level,
    required this.flash,
    required this.sensoryMode,
  });

  final String word;
  final LiteracyLevel level;
  final Animation<double> flash;
  final bool sensoryMode;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontSize: level.labelSize,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurface,
    );

    if (!level.flashesOnSelect) {
      return Text(
        word,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: base,
      );
    }

    final reduced = AppMotion.reduced(context, sensoryMode: sensoryMode);
    return AnimatedBuilder(
      animation: flash,
      builder: (context, _) {
        // Rise over the first third, hold, then settle back.
        final t = flash.value;
        final lift = t < 0.35
            ? Curves.easeOutCubic.transform(t / 0.35)
            : t > 0.75
            ? 1 - Curves.easeInCubic.transform((t - 0.75) / 0.25)
            : 1.0;
        final accent = context.palette.communicate;
        return Transform.translate(
          offset: reduced ? Offset.zero : Offset(0, -10 * lift),
          child: Transform.scale(
            scale: reduced ? 1.0 : 1 + 0.18 * lift,
            child: Text(
              word,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: base.copyWith(
                color: Color.lerp(base.color, accent, lift * 0.9),
              ),
            ),
          ),
        );
      },
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              // A short cell — a small phone, a large system text scale, or
              // a two-up grid on a narrow screen — drops the subtitle and
              // shrinks the icon rather than overflowing. The title and the
              // accent are what carry the meaning; the subtitle is a nicety.
              final tight = constraints.maxHeight.isFinite &&
                  constraints.maxHeight < 150;
              final glyph = tight ? 44.0 : 52.0;
              return Container(
            constraints: const BoxConstraints(minHeight: 132),
            padding: EdgeInsets.all(tight ? AppSpacing.sm : AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              gradient: AppDepth.sheen(
                palette.accentTint(accent, 0.86),
                sensoryMode: Theme.of(context).cardTheme.elevation == 0,
              ),
              border: Border.all(color: accent, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: glyph,
                  height: glyph,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    icon,
                    size: tight ? 26 : 30,
                    color: palette.onAccent,
                  ),
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
                      if (subtitle != null && !tight)
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
              );
            },
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
      child: SizedBox(
        width: size * 1.6,
        height: size * 1.6,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // A still halo, never a pulse: a repeating brightness change is
            // exactly the pattern this app exists to avoid.
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppDepth.halo(tint),
              ),
              child: SizedBox(width: size * 1.6, height: size * 1.6),
            ),
            Icon(Icons.star_rounded, size: size, color: tint),
          ],
        ),
      ),
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
