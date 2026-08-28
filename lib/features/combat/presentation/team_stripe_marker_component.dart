import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/team.dart';

/// Static team-color stripe mounted on a plane's hull - the flying-wing
/// body type's analog of [VehiclePlayerMarkerComponent]'s roundel, which
/// doesn't read well on a shape with no flat "deck" to sit on.
class TeamStripeMarkerComponent extends PositionComponent {
  final Color accent;

  TeamStripeMarkerComponent({required Vector2 hullSize, required Team team})
    : accent = team.color,
      super(
        position: hullSize / 2,
        anchor: Anchor.center,
        size: Vector2(hullSize.x * 0.5, hullSize.y * 0.14),
        priority: 6,
      );

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size.y / 2)),
      Paint()..color = const Color(0xFF2B2E33),
    );
    final inner = rect.deflate(size.y * 0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner, Radius.circular(inner.height / 2)),
      Paint()..color = accent,
    );
  }
}
