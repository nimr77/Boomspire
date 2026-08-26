import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Rising "+Ng" text popup shown when an enemy is killed, reinforcing the
/// gold reward.
class FloatingTextComponent extends TextComponent {
  FloatingTextComponent({required super.text, required Vector2 position})
    : super(
        position: position,
        anchor: Anchor.center,
        priority: 40,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.amberAccent,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 3)],
          ),
        ),
      );

  double _age = 0;
  static const _duration = 0.8;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    position.y -= dt * 28;
    if (_age >= _duration) removeFromParent();
  }
}
