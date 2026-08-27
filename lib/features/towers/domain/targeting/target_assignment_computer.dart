import 'dart:math';

import '../../../../core/combat/unit_domain.dart';

const int _finishingBlowShots = 5;

const int _maxSharedTargeters = 3;

const double _nearDeathHealthRatio = 0.3;

/// Pure, side-effect-free re-implementation of `TowerComponent`'s
/// focus-fire scoring (same `_maxSharedTargeters`/`_nearDeathHealthRatio`/
/// `_finishingBlowShots` rules), run on a background isolate via
/// `compute()` (see `GameWorld._refreshTargetAssignments`) since scanning
/// every tower against every enemy is the one part of tower targeting that
/// actually scales with battlefield size. `TowerComponent._acquireTarget`
/// still keeps its own synchronous copy of this scoring as a fallback for
/// the brief window before the first result comes back (or if a tower's
/// suggestion has since gone stale/invalid), so gameplay never waits on an
/// isolate round-trip to react.
///
/// Returns, for each tower id, the id of the enemy it should acquire next -
/// `null` means "nothing suitable found in range", not "keep whatever it
/// had".
Map<int, int?> computeTargetAssignments(TargetingSnapshot snapshot) {
  final result = <int, int?>{};
  for (final tower in snapshot.towers) {
    TargetSnapshot? closest;
    var closestDist = tower.range;
    TargetSnapshot? bestSmart;
    var bestSmartDist = tower.range;

    for (final unit in snapshot.targets) {
      if (unit.teamId == tower.ownerId) continue;
      if (!tower.attackDomains.contains(unit.domain)) continue;
      final dx = unit.x - tower.x;
      final dy = unit.y - tower.y;
      final d = sqrt(dx * dx + dy * dy);
      if (d < tower.minRange) continue;
      if (d <= closestDist) {
        closest = unit;
        closestDist = d;
      }
      if (d <= bestSmartDist && _isGoodFocusFireTarget(unit, tower, snapshot)) {
        bestSmart = unit;
        bestSmartDist = d;
      }
    }
    result[tower.id] = (bestSmart ?? closest)?.id;
  }
  return result;
}

bool _hasFasterFinisherAssigned(
  TargetSnapshot unit,
  TowerSnapshot tower,
  TargetingSnapshot snapshot,
) {
  final myShots = (unit.health / tower.damage).ceil();
  for (final other in snapshot.towers) {
    if (other.id == tower.id || other.ownerId != tower.ownerId) continue;
    if (other.currentTargetId != unit.id) continue;
    final otherShots = (unit.health / other.damage).ceil();
    if (otherShots < _finishingBlowShots && otherShots < myShots) return true;
  }
  return false;
}

bool _isGoodFocusFireTarget(
  TargetSnapshot unit,
  TowerSnapshot tower,
  TargetingSnapshot snapshot,
) {
  if (unit.healthRatio <= _nearDeathHealthRatio) {
    return !_hasFasterFinisherAssigned(unit, tower, snapshot);
  }
  final targeters = snapshot.towers
      .where((t) => t.currentTargetId == unit.id)
      .length;
  return targeters < _maxSharedTargeters;
}

/// Everything [computeTargetAssignments] needs for one battlefield-wide
/// targeting pass - plain data only, so the whole thing can cross an
/// isolate boundary via `compute()`.
class TargetingSnapshot {
  final List<TowerSnapshot> towers;
  final List<TargetSnapshot> targets;

  const TargetingSnapshot({required this.towers, required this.targets});
}

/// Plain-data snapshot of one potential target - a mobile unit or an enemy
/// tower/building (buildings score exactly like a stationary ground unit;
/// only [TowerSnapshot.attackDomains]/domain filtering decides who can hit
/// them) - see [TowerSnapshot].
class TargetSnapshot {
  final int id;
  final double x;
  final double y;
  final double health;
  final double healthRatio;
  final int teamId;
  final UnitDomain domain;

  const TargetSnapshot({
    required this.id,
    required this.x,
    required this.y,
    required this.health,
    required this.healthRatio,
    required this.teamId,
    required this.domain,
  });
}

/// Plain-data snapshot of one tower, safe to send across an isolate boundary
/// via `compute()` (see [computeTargetAssignments]) - mirrors just the
/// fields `TowerComponent._acquireTarget`/`_isGoodFocusFireTarget`/
/// `_hasFasterFinisherAssigned` need to score candidate targets.
class TowerSnapshot {
  final int id;
  final double x;
  final double y;
  final double minRange;
  final double range;
  final double damage;
  final int ownerId;
  final int? currentTargetId;
  final Set<UnitDomain> attackDomains;

  const TowerSnapshot({
    required this.id,
    required this.x,
    required this.y,
    required this.minRange,
    required this.range,
    required this.damage,
    required this.ownerId,
    required this.currentTargetId,
    required this.attackDomains,
  });
}
