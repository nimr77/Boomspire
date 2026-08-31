import 'dart:ui';

/// Paints one frame of `JetFlareComponent`'s exhaust flame streak.
void paintJetFlare(
  Canvas canvas, {
  required double age,
  required double duration,
  required double flareAngle,
  required bool boosted,
}) {
  final t = (age / duration).clamp(0.0, 1.0);
  final fade = 1 - t;
  final length = (boosted ? 24 : 16) + t * (boosted ? 10 : 6);

  canvas.save();
  canvas.rotate(flareAngle + 3.14159);
  final path = Path()
    ..moveTo(0, -4)
    ..lineTo(length, 0)
    ..lineTo(0, 4)
    ..close();
  canvas.drawPath(
    path,
    Paint()
      ..color = Color.lerp(
        boosted ? const Color(0xFF80D8FF) : const Color(0xFFFFF176),
        boosted ? const Color(0x001565C0) : const Color(0x00FF7043),
        t,
      )!.withValues(alpha: 0.85 * fade)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
  );
  canvas.restore();
}
