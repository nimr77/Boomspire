import 'mobile_unit_blueprint.dart';
import 'team.dart';
import 'unit_kind.dart';

/// Single shared catalog of every movable (non-tower) unit in the game -
/// both AI-enemy invaders and player-buildable ally units read their
/// shape/fire/range/domain stats from here, keyed by which [Team] is
/// asking, so the exact same [UnitKind] (e.g. `tank`) can carry different
/// balance numbers per side while still being "the same repo" the whole
/// roster is defined in.
abstract class MobileUnitRepository {
  MobileUnitBlueprint blueprintFor(Team team, UnitKind kind);

  /// Which kinds a unit of [team]'s side can be - the enemy AI only spawns
  /// its own roster, and the build menu only offers what a Training
  /// Center/War Factory can produce for the player.
  List<UnitKind> kindsFor(Team team);
}
