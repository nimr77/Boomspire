import 'dart:ui' as ui;

/// Smooths a polyline into a curved [ui.Path] by quadratic-bezier-ing
/// through the midpoint of every consecutive pair - a cheap way to avoid
/// sharp zig-zag joints between per-row samples.
ui.Path smoothPath(List<ui.Offset> points) {
  final path = ui.Path()..moveTo(points.first.dx, points.first.dy);
  for (var i = 0; i < points.length - 1; i++) {
    final p0 = points[i];
    final p1 = points[i + 1];
    final mid = ui.Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
    path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
  }
  path.lineTo(points.last.dx, points.last.dy);
  return path;
}
