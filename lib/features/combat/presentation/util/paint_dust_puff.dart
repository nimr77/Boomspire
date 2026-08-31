import 'dart:math';
import 'dart:ui';

/// Paints one frame of a `DustPuffComponent`'s fading, drifting dust circle
/// at animation progress [t] (0..1), drifting along [driftAngle].
void paintDustPuff(
  Canvas canvas, {
  required double t,
  required double driftAngle,
}) {
  canvas.drawCircle(
    Offset(cos(driftAngle), sin(driftAngle)) * (t * 6),
    4 + t * 5,
    Paint()
      ..color = Color.lerp(
        const Color(0x66C9B183),
        const Color(0x00C9B183),
        t,
      )!,
  );
}
