import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';

/// Fades an element in with a short rise, optionally staggered by position.
///
/// Two rules from the motion-accessibility research shape this:
///
/// * The travel is **10 logical pixels**, not the 40–60 a marketing site
///   would use. Motion large enough to notice as motion is motion large
///   enough to disorient someone with vestibular sensitivity.
/// * The stagger is capped, so a long list never turns into a wave rolling
///   down the screen. After the cap everything simply arrives together.
///
/// Under reduced motion it becomes a plain opacity fade with no translation
/// at all, which the research recommends over removing the transition
/// entirely — an instant cut is its own kind of jolt.
class Entrance extends StatefulWidget {
  const Entrance({
    required this.child,
    this.index = 0,
    this.sensoryMode = false,
    this.delayStep = const Duration(milliseconds: 45),
    this.maxStaggered = 8,
    super.key,
  });

  final Widget child;

  /// Position in a list or grid. Later items start slightly later.
  final int index;

  final bool sensoryMode;
  final Duration delayStep;

  /// Beyond this index everything shares the last delay.
  final int maxStaggered;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  /// The stagger is an `Interval` on one controller rather than a delayed
  /// start. A `Future.delayed` or a `Timer` would outlive a widget disposed
  /// mid-animation — which is exactly what a fast scroll does, and what
  /// leaves pending timers behind in tests.
  late final int _steps = widget.index.clamp(0, widget.maxStaggered);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.base + widget.delayStep * _steps,
  )..forward();

  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      _controller.duration!.inMicroseconds == 0
          ? 0.0
          : (widget.delayStep * _steps).inMicroseconds /
              _controller.duration!.inMicroseconds,
      1.0,
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced =
        AppMotion.reduced(context, sensoryMode: widget.sensoryMode);
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        final t = _progress.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: reduced
              ? child
              : Transform.translate(
                  offset: Offset(0, (1 - t) * 10),
                  child: child,
                ),
        );
      },
      child: widget.child,
    );
  }
}

/// Cross-fades between two states in place, with no movement at all.
///
/// Used where content swaps rather than arrives — a question changing, a
/// panel replacing another. Predictability matters more than expressiveness
/// on those surfaces, so nothing slides.
class CalmSwitcher extends StatelessWidget {
  const CalmSwitcher({
    required this.child,
    this.sensoryMode = false,
    super.key,
  });

  final Widget child;
  final bool sensoryMode;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.resolve(
        context,
        sensoryMode: sensoryMode,
        duration: AppMotion.base,
        // A fade survives reduced motion; a jump cut does not read as a
        // change of state, it reads as a glitch.
        keepFade: true,
      ),
      switchInCurve: AppMotion.curve,
      switchOutCurve: AppMotion.curve,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: child,
    );
  }
}

/// Page transition that fades through the background rather than sliding.
///
/// Material's default shared-axis slide moves the entire viewport, which the
/// motion-sensitivity guidance specifically warns against. This keeps the
/// sense of a new surface arriving while holding the movement to a barely
/// perceptible scale change in the middle of the screen.
class CalmPageTransitionsBuilder extends PageTransitionsBuilder {
  const CalmPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fade = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: fade,
      child: AnimatedBuilder(
        animation: fade,
        builder: (context, inner) => Transform.scale(
          // 2% — enough to read as depth, far too little to read as zoom.
          scale: 0.98 + 0.02 * fade.value,
          child: inner,
        ),
        child: child,
      ),
    );
  }
}
