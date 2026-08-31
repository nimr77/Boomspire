import 'dart:ui';

import 'package:flame/components.dart';

import 'util/paint_jet_flare.dart';

/// Bright engine exhaust flame trailing a plane-kind unit while it flies -
/// distinct from the condensation-streak `VaporConeComponent` (which every
/// swoop-style flyer already gets), this is specifically the jet's own
/// engine fire/afterburner glow.
class JetFlareComponent extends PositionComponent {
  static const _duration = 0.22;

  final double flareAngle;

  /// True while the plane is in "attack mode" (within boost range of its
  /// engaged target, see `_planeBoostRangeCells`) - renders a longer, blue
  /// afterburner streak instead of the plain yellow/orange exhaust flame.
  final bool boosted;
  double _age = 0;

  JetFlareComponent({
    required Vector2 position,
    required double angle,
    this.boosted = false,
  }) : flareAngle = angle,
       super(position: position, anchor: Anchor.center, priority: 4);

  @override
  void render(Canvas canvas) => paintJetFlare(
    canvas,
    age: _age,
    duration: _duration,
    flareAngle: flareAngle,
    boosted: boosted,
  );

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _duration) removeFromParent();
  }
}
