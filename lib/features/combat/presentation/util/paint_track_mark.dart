import 'dart:ui';

/// Paints `TrackMarkComponent`'s fading pair of tread prints.
void paintTrackMark(
  Canvas canvas, {
  required double age,
  required double duration,
}) {
  final fade = (1 - age / duration).clamp(0.0, 1.0);
  final paint = Paint()
    ..color = const Color(0xFF2B2B2B).withValues(alpha: 0.35 * fade);
  for (final dx in [-6.0, 6.0]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(dx, 0), width: 5, height: 14),
        const Radius.circular(2),
      ),
      paint,
    );
  }
}
