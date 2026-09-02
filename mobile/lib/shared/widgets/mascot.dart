import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// AutiMate's mascot — a small, calm companion.
///
/// Drawn in code for the same reasons as `EmotionFace`: no asset weight, it
/// recolours with the theme, and it can breathe gently rather than sitting
/// static. Deliberately soft geometry, no teeth, no wide staring eyes, no
/// sudden motion. It is the app's only piece of personality, and using the
/// same one in onboarding, empty states, reward moments, and role-play is
/// what makes the product feel designed rather than assembled.
class Mascot extends StatefulWidget {
  const Mascot({
    this.size = 96,
    this.color,
    this.breathing = false,
    this.happy = true,
    super.key,
  });

  final double size;
  final Color? color;

  /// A four-second rise and fall, **off by default**.
  ///
  /// In an app built for sensory-sensitive children, something moving
  /// perpetually in the corner of the screen is a cost rather than a
  /// delight, so ambient motion is opt-in and reserved for moments where
  /// the movement is the point. It also keeps the mascot from holding the
  /// frame scheduler open, which a continuous animation otherwise does.
  final bool breathing;
  final bool happy;

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void initState() {
    super.initState();
    if (widget.breathing) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(Mascot old) {
    super.didUpdateWidget(old);
    if (widget.breathing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.breathing && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final body = widget.color ?? palette.communicate;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: Size.square(widget.size),
        painter: _MascotPainter(
          body: body,
          belly: palette.accentTint(body, 0.72),
          ink: Theme.of(context).colorScheme.onSurface,
          // A 3% scale drift over four seconds: perceptible as calm, far
          // below any rate that could read as flashing.
          breath: Curves.easeInOut.transform(_controller.value),
          happy: widget.happy,
        ),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  const _MascotPainter({
    required this.body,
    required this.belly,
    required this.ink,
    required this.breath,
    required this.happy,
  });

  final Color body;
  final Color belly;
  final Color ink;
  final double breath;
  final bool happy;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(size.width / 2, size.height / 2);
    final scale = 1 + breath * 0.03;

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(scale);
    canvas.translate(-c.dx, -c.dy);

    final r = s * 0.34;

    // Ears — rounded, low-set, nothing pointed.
    for (final dx in [-r * 0.62, r * 0.62]) {
      canvas.drawCircle(
        c + Offset(dx, -r * 0.78),
        r * 0.30,
        Paint()..color = body,
      );
    }

    // Body.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c + Offset(0, s * 0.04),
          width: r * 1.9,
          height: r * 1.8,
        ),
        Radius.circular(r * 0.78),
      ),
      Paint()..color = body,
    );

    // Belly patch — the lighter field the face sits on.
    canvas.drawOval(
      Rect.fromCenter(
        center: c + Offset(0, s * 0.07),
        width: r * 1.25,
        height: r * 1.15,
      ),
      Paint()..color = belly,
    );

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.026
      ..strokeCap = StrokeCap.round
      ..color = ink;

    // Eyes — small, soft, never wide.
    for (final dx in [-r * 0.34, r * 0.34]) {
      canvas.drawCircle(
        c + Offset(dx, -r * 0.05),
        s * 0.032,
        Paint()..color = ink,
      );
    }

    // Mouth.
    final mouth = c + Offset(0, r * 0.34);
    if (happy) {
      canvas.drawArc(
        Rect.fromCenter(center: mouth, width: r * 0.52, height: r * 0.40),
        0.15 * math.pi,
        0.7 * math.pi,
        false,
        line,
      );
    } else {
      canvas.drawLine(
        mouth + Offset(-r * 0.18, 0),
        mouth + Offset(r * 0.18, 0),
        line,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_MascotPainter old) =>
      old.breath != breath ||
      old.body != body ||
      old.belly != belly ||
      old.ink != ink ||
      old.happy != happy;
}
