import 'dart:ui';

import 'package:flame/components.dart';

/// Drawn as the last child of a targetable combat component (a mobile unit
/// or a tower) so it renders on top of its sprite - fills the parent's own
/// silhouette (via [BlendMode.srcATop]) with whoever's currently locked
/// onto it as a target, so "who's being shot at right now" reads instantly
/// from across the battlefield. Shared by `MobileUnitComponent` and
/// `TowerComponent` - only triggered while the shooter is the player's
/// current [selectedTower]/[selectedUnit] selection, otherwise every
/// tower/unit on the map would be lighting up targets at once.
class TargetHighlightComponent extends PositionComponent {
  static const _fadeDuration = 0.35;

  Color _color = const Color(0x00000000);
  double _timer = 0;

  @override
  void render(Canvas canvas) {
    if (_timer <= 0) return;
    final ratio = _timer / _fadeDuration;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x * 0.55,
      Paint()
        ..color = _color.withValues(alpha: 0.7 * ratio)
        ..blendMode = BlendMode.srcATop,
    );
  }

  void trigger(Color color) {
    _color = color;
    _timer = _fadeDuration;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_timer > 0) _timer = (_timer - dt).clamp(0, _fadeDuration);
  }
}
