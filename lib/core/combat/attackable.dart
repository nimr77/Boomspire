import 'targetable.dart';

/// A [Targetable] that also exposes destruction/HP-ratio state - lets
/// [EnemyComponent] pick between towers and friendly ally units with the
/// same targeting/scoring logic, without knowing which concrete type it
/// found.
abstract class Attackable implements Targetable {
  bool get destroyed;

  /// Current health as a fraction of max, 0-1 - used by the "weakest
  /// target" AI focus hint.
  double get healthRatio;
}
