import 'dart:ui';

/// Paints one frame of `FirePulseComponent`'s ground shockwave ring.
void paintFirePulse(
  Canvas canvas, {
  required double age,
  required double duration,
  required double maxRadius,
  required Color color,
}) {
  final t = (age / duration).clamp(0.0, 1.0);
  final eased = 1 - (1 - t) * (1 - t);
  final ringRadius = maxRadius * (0.15 + eased * 0.85);
  final fade = 1 - t;

  canvas.drawOval(
    Rect.fromCenter(
      center: Offset.zero,
      width: ringRadius * 2,
      height: ringRadius * 1.1,
    ),
    Paint()
      ..color = color.withValues(alpha: 0.5 * fade)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * fade + 0.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
  );
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset.zero,
      width: ringRadius * 1.15,
      height: ringRadius * 0.62,
    ),
    Paint()
      ..color = color.withValues(alpha: 0.16 * fade)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
  );
}
