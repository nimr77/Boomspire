import 'package:flame/game.dart';

import 'unit.dart';

/// Anything a projectile can fly toward and damage: towers and enemies both
/// implement this so combat components don't need to know which side fired.
/// Extends [Unit] so every targetable thing also carries a [Unit.domain]/
/// [Unit.attackDomains] pair for domain-aware targeting.
abstract class Targetable implements Unit {
  bool get isMounted;
  bool get isRemoving;
  Vector2 get position;
  void takeDamage(double amount);
}
