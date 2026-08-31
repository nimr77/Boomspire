import 'dart:ui';

import 'package:flame/components.dart';

/// Paints one frame of a `LaserBeamComponent`: the traveling pulse (glow +
/// jagged bolt) while `travelT` < 1, plus the muzzle and impact flares.
void paintLaserBeam(
  Canvas canvas, {
  required Vector2 start,
  required Vector2 end,
  required Color color,
  required double kinkSide,
  required double age,
  required double travelDuration,
  required double flareDuration,
  required double pulseLength,
}) {
  final direction = end - start;
  final length = direction.length;
  if (length <= 0) return;
  final unit = direction.normalized();
  final perp = Vector2(-unit.y, unit.x);

  final travelT = (age / travelDuration).clamp(0.0, 1.0);
  final flareT = ((age - travelDuration) / flareDuration).clamp(0.0, 1.0);
  const core = Color(0xFFF4FFFF);
  final electricAccent = Color.lerp(color, const Color(0xFFB388FF), 0.5)!;

  if (travelT < 1.0) {
    final traveled = start + unit * (length * travelT);
    canvas.drawLine(
      Offset(start.x, start.y),
      Offset(traveled.x, traveled.y),
      Paint()
        ..color = color.withValues(alpha: 0.16 * (1 - travelT * 0.5))
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );

    final head = traveled;
    final tail = head - unit * pulseLength;
    final kink = tail + unit * (pulseLength * 0.4) + perp * (4 * kinkSide);
    final bolt = Path()
      ..moveTo(tail.x, tail.y)
      ..lineTo(kink.x, kink.y)
      ..lineTo(head.x, head.y);
    canvas.drawPath(
      bolt,
      Paint()
        ..color = electricAccent.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(
      bolt,
      Paint()
        ..color = core.withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  paintLaserBeamFlare(
    canvas,
    start,
    (1 - travelT / 0.5).clamp(0.0, 1.0),
    electricAccent,
    core,
  );

  if (age >= travelDuration) {
    paintLaserBeamFlare(
      canvas,
      end,
      1 - flareT,
      electricAccent,
      core,
      scale: 1 + flareT * 0.7,
    );
  }
}

/// Paints a quick bright flare burst at [at], fading with [strength] (0..1)
/// and scaled by [scale]. Used for both the muzzle flare and the impact
/// flare of a `LaserBeamComponent`.
void paintLaserBeamFlare(
  Canvas canvas,
  Vector2 at,
  double strength,
  Color accent,
  Color core, {
  double scale = 1.0,
}) {
  if (strength <= 0) return;
  final center = Offset(at.x, at.y);
  canvas.drawCircle(
    center,
    8 * scale,
    Paint()
      ..color = accent.withValues(alpha: 0.4 * strength)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
  );
  canvas.drawCircle(
    center,
    3 * scale,
    Paint()..color = core.withValues(alpha: 0.9 * strength),
  );
}
