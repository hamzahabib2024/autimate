import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/emotion_recognition/domain/emotion_activity_engine.dart';

/// The parameters that define one facial expression.
///
/// Keeping the face as numbers rather than artwork buys three things this
/// project specifically needs: the six emotion stimuli and the Module 2
/// role-play character become the same widget, expressions can *tween*
/// between one another rather than cutting, and every expression is
/// assertable in a unit test. It also ships zero asset weight, which keeps
/// the offline-first build small.
@immutable
class FaceExpression {
  const FaceExpression({
    required this.browAngle,
    required this.browLift,
    required this.eyeOpenness,
    required this.mouthCurve,
    required this.mouthOpenness,
    this.blush = 0,
  });

  /// Inner-brow rotation in radians. Positive angles pull the inner ends
  /// down (anger); negative lifts them (sadness, fear).
  final double browAngle;

  /// Vertical brow offset as a fraction of face radius. Positive raises.
  final double browLift;

  /// 0 = closed, 1 = neutral, > 1 = widened.
  final double eyeOpenness;

  /// -1 = full frown, 0 = flat, 1 = full smile.
  final double mouthCurve;

  /// 0 = closed line, 1 = fully open.
  final double mouthOpenness;

  /// Cheek colour, used only for happiness. Warmth, not arousal.
  final double blush;

  static FaceExpression lerp(FaceExpression a, FaceExpression b, double t) =>
      FaceExpression(
        browAngle: _l(a.browAngle, b.browAngle, t),
        browLift: _l(a.browLift, b.browLift, t),
        eyeOpenness: _l(a.eyeOpenness, b.eyeOpenness, t),
        mouthCurve: _l(a.mouthCurve, b.mouthCurve, t),
        mouthOpenness: _l(a.mouthOpenness, b.mouthOpenness, t),
        blush: _l(a.blush, b.blush, t),
      );

  static double _l(double a, double b, double t) => a + (b - a) * t;

  @override
  bool operator ==(Object other) =>
      other is FaceExpression &&
      other.browAngle == browAngle &&
      other.browLift == browLift &&
      other.eyeOpenness == eyeOpenness &&
      other.mouthCurve == mouthCurve &&
      other.mouthOpenness == mouthOpenness &&
      other.blush == blush;

  @override
  int get hashCode => Object.hash(
    browAngle,
    browLift,
    eyeOpenness,
    mouthCurve,
    mouthOpenness,
    blush,
  );
}

/// The six target emotions from the scope document, drawn to be
/// unambiguous rather than subtle.
///
/// Two deliberate choices for this audience: expressions are exaggerated
/// enough to be separable at a glance, and *fear* is drawn as worry rather
/// than terror — a genuinely frightening stimulus has no place in a
/// child's learning activity.
const Map<EmotionLabel, FaceExpression> emotionExpressions = {
  EmotionLabel.happy: FaceExpression(
    browAngle: -0.05,
    browLift: 0.04,
    eyeOpenness: 0.75,
    mouthCurve: 0.9,
    mouthOpenness: 0.35,
    blush: 0.5,
  ),
  EmotionLabel.sad: FaceExpression(
    browAngle: -0.30,
    browLift: -0.02,
    eyeOpenness: 0.65,
    mouthCurve: -0.8,
    mouthOpenness: 0.05,
  ),
  EmotionLabel.angry: FaceExpression(
    browAngle: 0.42,
    browLift: -0.10,
    eyeOpenness: 0.85,
    mouthCurve: -0.55,
    mouthOpenness: 0.10,
  ),
  EmotionLabel.surprised: FaceExpression(
    browAngle: 0.0,
    browLift: 0.16,
    eyeOpenness: 1.35,
    mouthCurve: 0.05,
    mouthOpenness: 0.85,
  ),
  EmotionLabel.scared: FaceExpression(
    browAngle: -0.34,
    browLift: 0.12,
    eyeOpenness: 1.20,
    mouthCurve: -0.35,
    mouthOpenness: 0.45,
  ),
  EmotionLabel.neutral: FaceExpression(
    browAngle: 0.0,
    browLift: 0.0,
    eyeOpenness: 1.0,
    mouthCurve: 0.0,
    mouthOpenness: 0.0,
  ),
};

/// A face rendered from [FaceExpression], animating between expressions.
///
/// Used as the emotion-identification stimulus, the answer options, and the
/// Module 2 role-play character — one widget so the child meets a
/// consistent face everywhere, which matters more for learning than
/// illustration variety would.
class EmotionFace extends StatelessWidget {
  const EmotionFace({
    required this.emotion,
    this.size = 160,
    this.skin,
    this.animate = true,
    this.duration = const Duration(milliseconds: 400),
    super.key,
  });

  final EmotionLabel emotion;
  final double size;
  final Color? skin;

  /// Suppressed by sensory mode and by the OS reduced-motion setting.
  final bool animate;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final expression = emotionExpressions[emotion]!;
    final face = skin ?? palette.accentTint(palette.emotions, 0.62);
    final ink = Theme.of(context).colorScheme.onSurface;

    if (!animate) {
      return CustomPaint(
        size: Size.square(size),
        painter: FacePainter(
          expression: expression,
          skin: face,
          ink: ink,
          blushColor: palette.wordCarrier,
        ),
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      key: ValueKey(emotion),
      builder: (context, t, _) => CustomPaint(
        size: Size.square(size),
        painter: FacePainter(
          expression: FaceExpression.lerp(
            emotionExpressions[EmotionLabel.neutral]!,
            expression,
            t,
          ),
          skin: face,
          ink: ink,
          blushColor: palette.wordCarrier,
        ),
      ),
    );
  }
}

/// Paints one face. Public so golden tests can drive it directly.
class FacePainter extends CustomPainter {
  const FacePainter({
    required this.expression,
    required this.skin,
    required this.ink,
    required this.blushColor,
  });

  final FaceExpression expression;
  final Color skin;
  final Color ink;
  final Color blushColor;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = Offset(size.width / 2, size.height / 2);
    final stroke = r * 0.075;

    canvas.drawCircle(c, r * 0.94, Paint()..color = skin);
    canvas.drawCircle(
      c,
      r * 0.94,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 0.8
        ..color = ink.withValues(alpha: 0.55),
    );

    if (expression.blush > 0) {
      final blush = Paint()
        ..color = blushColor.withValues(alpha: 0.28 * expression.blush);
      canvas.drawOval(
        Rect.fromCenter(
          center: c + Offset(-r * 0.52, r * 0.22),
          width: r * 0.40,
          height: r * 0.26,
        ),
        blush,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: c + Offset(r * 0.52, r * 0.22),
          width: r * 0.40,
          height: r * 0.26,
        ),
        blush,
      );
    }

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = ink;

    // Eyes. Openness scales the vertical axis; a closed eye becomes a line
    // rather than vanishing, so it still reads as an eye.
    final eyeY = c.dy - r * 0.16;
    for (final dx in [-r * 0.36, r * 0.36]) {
      final eye = Offset(c.dx + dx, eyeY);
      final h = r * 0.20 * expression.eyeOpenness;
      if (h < r * 0.05) {
        canvas.drawLine(
          eye + Offset(-r * 0.16, 0),
          eye + Offset(r * 0.16, 0),
          line,
        );
      } else {
        canvas.drawOval(
          Rect.fromCenter(center: eye, width: r * 0.26, height: h * 2),
          Paint()..color = ink,
        );
      }
    }

    // Brows. Rotation is mirrored so both inner ends move together.
    final browY = eyeY - r * 0.40 - r * expression.browLift;
    for (final side in [-1.0, 1.0]) {
      final centre = Offset(c.dx + side * r * 0.36, browY);
      canvas.save();
      canvas.translate(centre.dx, centre.dy);
      canvas.rotate(side * expression.browAngle);
      canvas.drawLine(
        Offset(-r * 0.20, 0),
        Offset(r * 0.20, 0),
        line,
      );
      canvas.restore();
    }

    // Mouth. A closed mouth is an arc; an open one is an oval whose
    // vertical extent follows openness.
    final mouthC = Offset(c.dx, c.dy + r * 0.40);
    final w = r * 0.52;
    if (expression.mouthOpenness < 0.12) {
      final path = Path()
        ..moveTo(mouthC.dx - w, mouthC.dy)
        ..quadraticBezierTo(
          mouthC.dx,
          mouthC.dy + expression.mouthCurve * r * 0.42,
          mouthC.dx + w,
          mouthC.dy,
        );
      canvas.drawPath(path, line);
    } else {
      final h = r * 0.34 * expression.mouthOpenness;
      final rect = Rect.fromCenter(
        center: mouthC + Offset(0, expression.mouthCurve * r * 0.10),
        width: w * 2,
        height: h * 2,
      );
      canvas.drawArc(
        rect,
        expression.mouthCurve >= 0 ? 0 : math.pi,
        math.pi,
        false,
        Paint()..color = ink,
      );
      canvas.drawArc(
        rect,
        expression.mouthCurve >= 0 ? 0 : math.pi,
        math.pi,
        false,
        line,
      );
    }
  }

  @override
  bool shouldRepaint(FacePainter old) =>
      old.expression != expression ||
      old.skin != skin ||
      old.ink != ink ||
      old.blushColor != blushColor;
}
