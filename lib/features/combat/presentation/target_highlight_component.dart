import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_target_highlight.dart';

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

  /// Base tint alpha once "locked in" - kept low so it reads as a subtle
  /// glow of the shooter's own color rather than fully repainting the
  /// target's silhouette.
  static const _baseAlpha = 0.35;

  Color _color = const Color(0x00000000);
  double _timer = 0;
  double _pulsePhase = 0;

  @override
  void render(Canvas canvas) => paintTargetHighlight(
    canvas,
    size: size,
    color: _color,
    timer: _timer,
    fadeDuration: _fadeDuration,
    baseAlpha: _baseAlpha,
    pulsePhase: _pulsePhase,
  );

  void trigger(Color color) {
    _color = color;
    _timer = _fadeDuration;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulsePhase += dt * 6;
    if (_timer > 0) _timer = (_timer - dt).clamp(0, _fadeDuration);
  }
}
