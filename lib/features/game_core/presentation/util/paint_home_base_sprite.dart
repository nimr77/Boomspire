import 'dart:ui' as ui;

/// Paints the home base "2D object model" - house silhouette, roof,
/// energy-core door glow, and antenna - tinted by [accent].
void paintHomeBaseSprite(ui.Canvas canvas, ui.Color accent) {
  const size = 96.0;
  const center = ui.Offset(size / 2, size / 2 + 6);

  canvas.drawOval(
    ui.Rect.fromCenter(
      center: center.translate(0, size * 0.34),
      width: size * 0.7,
      height: size * 0.16,
    ),
    ui.Paint()..color = const ui.Color(0x59000000),
  );

  final wallRect = ui.Rect.fromCenter(
    center: center.translate(0, size * 0.08),
    width: size * 0.62,
    height: size * 0.42,
  );
  canvas.drawRRect(
    ui.RRect.fromRectAndRadius(wallRect, const ui.Radius.circular(8)),
    ui.Paint()
      ..shader = ui.Gradient.linear(
        ui.Offset(wallRect.left, wallRect.top),
        ui.Offset(wallRect.left, wallRect.bottom),
        [const ui.Color(0xFF37474F), const ui.Color(0xFF1B242A)],
      ),
  );
  canvas.drawRRect(
    ui.RRect.fromRectAndRadius(wallRect, const ui.Radius.circular(8)),
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = accent.withValues(alpha: 0.6),
  );

  // Roof - a simple house silhouette so the base reads as "home".
  final roofPath = ui.Path()
    ..moveTo(center.dx - size * 0.38, wallRect.top + 2)
    ..lineTo(center.dx, wallRect.top - size * 0.24)
    ..lineTo(center.dx + size * 0.38, wallRect.top + 2)
    ..close();
  canvas.drawPath(roofPath, ui.Paint()..color = const ui.Color(0xFF263238));
  canvas.drawPath(
    roofPath,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = accent.withValues(alpha: 0.8),
  );

  // Energy-core door glow.
  final doorCenter = center.translate(0, size * 0.12);
  canvas.drawCircle(
    doorCenter,
    size * 0.1,
    ui.Paint()
      ..shader = ui.Gradient.radial(doorCenter, size * 0.1, [
        ui.Color.lerp(accent, const ui.Color(0xFFFFFFFF), 0.5)!,
        ui.Color.lerp(accent, const ui.Color(0xFF000000), 0.45)!,
      ]),
  );

  // Antenna.
  final antennaTop = ui.Offset(center.dx, wallRect.top - size * 0.38);
  canvas.drawLine(
    ui.Offset(center.dx, wallRect.top - size * 0.24),
    antennaTop,
    ui.Paint()
      ..color = accent
      ..strokeWidth = 2,
  );
  canvas.drawCircle(antennaTop, 3, ui.Paint()..color = accent);
}
