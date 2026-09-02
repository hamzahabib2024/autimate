import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_depth.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';

/// The app's intro animation.
///
/// Built against what the research actually says about this audience rather
/// than against what makes a flashy showreel:
///
/// * **Under two seconds.** A launch animation is seen hundreds of times by
///   a daily user; anything longer stops being a welcome and becomes a toll.
/// * **Motion stays in the middle third of the screen.** Large full-viewport
///   movement is disorienting for anyone with vestibular sensitivity, and
///   this app's users are more likely than most to have it.
/// * **Nothing flashes.** Every value moves once, in one direction, on a
///   decelerating curve. No pulse, no loop, no bounce, no strobe.
/// * **Skippable, and never a gate.** A tap ends it immediately. It also
///   ends itself — a child should never be stuck watching a logo.
/// * **Reduced motion collapses it to a single fade**, honouring both the
///   in-app sensory mode and the OS setting.
///
/// The sequence is staged rather than simultaneous, which is what makes a
/// slow animation read as composed instead of sluggish: ground settles →
/// mascot rises → halo opens → wordmark fades → tagline follows.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    required this.appState,
    required this.onComplete,
    super.key,
  });

  final AppState appState;
  final VoidCallback onComplete;

  /// Total run time. Comfortably inside the two-second guideline.
  static const Duration duration = Duration(milliseconds: 1900);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashScreen.duration,
  );

  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _finish();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    if (!mounted) return;
    if (AppMotion.reduced(
      context,
      sensoryMode: widget.appState.sensoryMode,
    )) {
      // Reduced motion still gets a beat of stillness — cutting straight to
      // the app is its own kind of jolt — but nothing moves.
      _controller.value = 1.0;
      Future<void>.delayed(const Duration(milliseconds: 450), _finish);
      return;
    }
    _controller.forward();
  }

  void _finish() {
    if (_finished || !mounted) return;
    _finished = true;
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Maps the master timeline onto one stage, so the phases overlap rather
  /// than queueing — overlapping is what keeps it feeling continuous.
  double _stage(double start, double end, {Curve curve = Curves.easeOutCubic}) {
    final t = ((_controller.value - start) / (end - start)).clamp(0.0, 1.0);
    return curve.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final reduced = AppMotion.reduced(
      context,
      sensoryMode: widget.appState.sensoryMode,
    );

    return Scaffold(
      backgroundColor: palette.canvas,
      body: GestureDetector(
        // Tap anywhere to skip. The whole surface, because a small skip
        // button is a target a child should not have to find.
        onTap: _finish,
        behavior: HitTestBehavior.opaque,
        child: Semantics(
          label: 'AutiMate',
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final rise = _stage(0.00, 0.55);
              final halo = _stage(0.20, 0.75);
              final word = _stage(0.42, 0.80);
              final tag = _stage(0.60, 1.00);

              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Halo opens outward once, behind the mascot.
                          Opacity(
                            opacity: reduced ? 0.5 : halo,
                            child: Transform.scale(
                              scale: reduced ? 1.0 : 0.7 + 0.3 * halo,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppDepth.halo(palette.communicate),
                                ),
                              ),
                            ),
                          ),
                          // The ring is drawn on, not spun. A spinner would
                          // read as "waiting"; this reads as "arriving".
                          CustomPaint(
                            size: const Size.square(190),
                            painter: _ArcPainter(
                              progress: reduced ? 1.0 : halo,
                              color: palette.communicate.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),
                          // Mascot rises a short distance and settles.
                          Transform.translate(
                            offset: Offset(0, reduced ? 0 : (1 - rise) * 26),
                            child: Opacity(
                              opacity: rise,
                              child: Transform.scale(
                                scale: reduced ? 1.0 : 0.88 + 0.12 * rise,
                                child: const _SplashMascot(size: 132),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Opacity(
                      opacity: word,
                      child: Transform.translate(
                        offset: Offset(0, reduced ? 0 : (1 - word) * 12),
                        child: Text(
                          'AutiMate',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: palette.communicate,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Opacity(
                      opacity: tag * 0.75,
                      child: Text(
                        'A calm place to talk, learn, and play',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
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

/// The splash mascot, drawn slightly larger and without the breathing loop.
class _SplashMascot extends StatelessWidget {
  const _SplashMascot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.card,
        boxShadow: AppDepth.tinted(palette.communicate),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.78,
          height: size * 0.78,
          // The shared Mascot, held still.
          child: const _StillMascot(),
        ),
      ),
    );
  }
}

class _StillMascot extends StatelessWidget {
  const _StillMascot();

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        return SizedBox(
          width: size,
          height: size,
          child: _MascotProxy(size: size),
        );
      });
}

/// Indirection so this file does not import the widget barrel, which would
/// create a cycle through `app_widgets.dart`.
class _MascotProxy extends StatelessWidget {
  const _MascotProxy({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _SplashFacePainter(context.palette)),
  );
}

/// A simplified, still rendering of the mascot for the intro.
class _SplashFacePainter extends CustomPainter {
  _SplashFacePainter(this.palette);

  final AppPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(size.width / 2, size.height / 2);
    final r = s * 0.34;
    final body = Paint()..color = palette.communicate;

    for (final dx in [-r * 0.62, r * 0.62]) {
      canvas.drawCircle(c + Offset(dx, -r * 0.78), r * 0.30, body);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c + Offset(0, s * 0.04),
          width: r * 1.9,
          height: r * 1.8,
        ),
        Radius.circular(r * 0.78),
      ),
      body,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: c + Offset(0, s * 0.07),
        width: r * 1.25,
        height: r * 1.15,
      ),
      Paint()..color = AppPalette.mix(palette.communicate, palette.card, 0.72),
    );

    final ink = Paint()..color = const Color(0xFF12221F);
    for (final dx in [-r * 0.34, r * 0.34]) {
      canvas.drawCircle(c + Offset(dx, -r * 0.05), s * 0.032, ink);
    }
    canvas.drawArc(
      Rect.fromCenter(
        center: c + Offset(0, r * 0.34),
        width: r * 0.52,
        height: r * 0.40,
      ),
      0.15 * math.pi,
      0.7 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.026
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF12221F),
    );
  }

  @override
  bool shouldRepaint(_SplashFacePainter old) => old.palette != palette;
}

/// Draws a ring on progressively, starting from the top.
class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.shortestSide / 2 - 3,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}
