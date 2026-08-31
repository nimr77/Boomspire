import 'dart:math';
import 'dart:ui';

/// Paints `MoveOrderMarkerComponent`'s pulsing ring, dot, and pin tail.
void paintMoveOrderMarker(
  Canvas canvas, {
  required Color color,
  required double phase,
}) {
  final pulse = 0.5 + 0.5 * sin(phase);
  canvas.drawCircle(
    Offset.zero,
    9 + pulse * 7,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color.withValues(alpha: 0.25 + pulse * 0.35),
  );
  canvas.drawCircle(Offset.zero, 3.5, Paint()..color = color);
  final tail = Path()
    ..moveTo(-5, -9)
    ..lineTo(5, -9)
    ..lineTo(0, -20)
    ..close();
  canvas.drawPath(tail, Paint()..color = color);
}
