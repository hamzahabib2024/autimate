import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_depth.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';

export 'child_widgets.dart';
export 'entrance.dart';
export 'emotion_face.dart';
export 'mascot.dart';
export 'word_class_legend.dart';

/// A navigational tile on a caregiver surface, or — with [accent] set — a
/// child-tier module tile.
///
/// The accent is the module's identity colour. It arrives as a tinted icon
/// well plus a leading rule, never as a full fill, so the label keeps a
/// high-contrast ground.
class FeatureTile extends StatelessWidget {
  const FeatureTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.accent,
    this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final tint = accent ?? scheme.primary;
    return Semantics(
      button: true,
      label: title,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppDepth.card(
            context,
            sensoryMode: Theme.of(context).cardTheme.elevation == 0,
          ),
        ),
        child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppTouch.child),
            child: Row(
              children: [
                // The identity rule: a child scanning for "the green one"
                // finds it before reading a word.
                Container(width: 6, height: 88, color: tint),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.md,
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                  ),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: palette.accentTint(tint, 0.82),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(icon, size: 30, color: tint),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSpacing.md),
                  child: trailing ??
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

/// A centred informational panel — empty states, session summaries, and the
/// six expression-practice states.
class StatePanel extends StatelessWidget {
  const StatePanel({
    required this.title,
    required this.message,
    required this.icon,
    this.accent,
    this.action,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color? accent;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tint = accent ?? Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: palette.accentTint(tint, 0.82),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: tint),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Slim banner shown above the shell while the device is offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey('offline-banner'),
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud_off_outlined, size: 20),
              const SizedBox(width: AppSpacing.xs + 2),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section heading with an optional accent rule, used to break long
/// scrolls into scannable groups.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.accent,
    this.trailing,
    super.key,
  });

  final String title;
  final Color? accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tint = accent ?? Theme.of(context).colorScheme.primary;
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(width: AppSpacing.xs + 2),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// A labelled number on the caregiver dashboard.
class CaregiverStatTile extends StatelessWidget {
  const CaregiverStatTile({
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tint = accent ?? Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: palette.accentTint(tint, 0.82),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 22, color: tint),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700, color: tint),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated ring showing progress toward a milestone.
///
/// Promoted out of the gamification screen's private painter so the same
/// ring can be reused for routine completion and session progress.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    this.color,
    this.animate = true,
    this.child,
    super.key,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;
  final bool animate;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tint = color ?? Theme.of(context).colorScheme.primary;
    final clamped = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: animate ? 0 : clamped, end: clamped),
        duration: animate ? AppMotion.slow : Duration.zero,
        curve: AppMotion.curve,
        builder: (context, value, _) => CustomPaint(
          painter: _RingPainter(
            progress: value,
            color: tint,
            track: palette.sunken,
            strokeWidth: strokeWidth,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color track;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - strokeWidth / 2 - 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = track,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5707963,
      6.2831853 * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.track != track ||
      old.strokeWidth != strokeWidth;
}
