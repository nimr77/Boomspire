import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Pulsing pin shown at the point a player-controlled unit was just
/// ordered to move to - stays up (see `BoomspireGame._syncMoveOrderMarker`)
/// for as long as that unit is selected and still traveling there, and
/// disappears once it arrives or gets a new order.
class MoveOrderMarkerComponent extends PositionComponent {
  final Color color;

  double _phase = 0;
  MoveOrderMarkerComponent({required super.position, required this.color})
    : super(anchor: Anchor.center, priority: 20);

  @override
  void render(Canvas canvas) {
    final pulse = 0.5 + 0.5 * sin(_phase);
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

  @override
  void update(double dt) {
    super.update(dt);
    _phase += dt * 4;
  }
}
