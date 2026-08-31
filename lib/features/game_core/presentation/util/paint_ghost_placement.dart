import 'dart:ui';

/// Paints the pending-build footprint, pulsing range ring, and (if any)
/// dead-zone ring for [GhostPlacementComponent].
void paintGhostPlacement(
  Canvas canvas, {
  required Offset center,
  required double half,
  required Color accent,
  required double pulse,
  required double range,
  required double minRange,
}) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: half * 2, height: half * 2),
      const Radius.circular(6),
    ),
    Paint()..color = accent.withValues(alpha: 0.25),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: half * 2, height: half * 2),
      const Radius.circular(6),
    ),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = accent.withValues(alpha: 0.7),
  );

  if (range <= 0) return;

  canvas.drawCircle(
    center,
    range,
    Paint()..color = accent.withValues(alpha: 0.05 + pulse * 0.05),
  );
  canvas.drawCircle(
    center,
    range,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 + pulse
      ..color = accent.withValues(alpha: 0.4 + pulse * 0.3),
  );

  if (minRange > 0) {
    canvas.drawCircle(
      center,
      minRange,
      Paint()..color = const Color(0xFFE53935).withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      center,
      minRange,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFE53935).withValues(alpha: 0.6),
    );
  }
}
