import 'package:flame/game.dart';

/// Anything a projectile can fly toward and damage: towers and enemies both
/// implement this so combat components don't need to know which side fired.
abstract class Targetable {
  Vector2 get position;
  bool get isRemoving;
  bool get isMounted;
  void takeDamage(double amount);
}
